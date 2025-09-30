package service

import (
	"encoding/json"
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils"
	"fairnest/internal/utils/v"
	"fmt"
	"log"
	"time"
)

type roomJoinService struct {
	roomJoinRepo    repository.RoomJoinRepository
	roomMemberSer   RoomMemberService
	roomSer         RoomService
	userSer         UserService
	notificationSer NotificationService
	lifestyleSer    LifestyleService
}

func NewRoomJoinService(roomJoinRepo repository.RoomJoinRepository, roomMemberSer RoomMemberService, roomSer RoomService, userSer UserService, notificationSer NotificationService, lifestyleSer LifestyleService) roomJoinService {
	return roomJoinService{
		roomJoinRepo:    roomJoinRepo,
		roomMemberSer:   roomMemberSer,
		roomSer:         roomSer,
		userSer:         userSer,
		notificationSer: notificationSer,
		lifestyleSer:    lifestyleSer,
	}
}

// * create join request and send notifications to all room members
func (s roomJoinService) CreateRoomJoinRequestByUserIdRoomId(requesterUserID int, requestedRoomID int) (*dtos.CreateRoomJoinRequestByUserIdResponse, error) {
	// Check if user already has pending request for this room
	hasPending, err := s.roomJoinRepo.GetUserHasPendingJoinRequestByUserIdRoomId(requesterUserID, requestedRoomID)
	if err != nil {
		return nil, err
	}
	if hasPending {
		return nil, fmt.Errorf("you already have a pending join request for this room")
	}

	// Check if user is already member of this room
	userHasRoom, err := s.roomMemberSer.GetCheckUserHasRoomOrNotByUserId(requesterUserID)
	if err != nil {
		return nil, err
	}
	if userHasRoom {
		return nil, fmt.Errorf("you are already a member of a room")
	}

	// Get all room members (eligible voters)
	roomMembers, err := s.roomMemberSer.FetchAllRoomMemberByRoomId(requestedRoomID)
	if err != nil {
		return nil, err
	}
	if len(roomMembers) == 0 {
		return nil, fmt.Errorf("room has no members")
	}

	// Get room details for validation
	roomDetails, err := s.roomSer.GetRoomDetailsByRoomId(requestedRoomID)
	if err != nil {
		return nil, fmt.Errorf("room not found")
	}

	// Check if room has space
	if roomDetails.RoomCurrentCapacity != nil && roomDetails.RoomMaxCapacity != nil {
		if *roomDetails.RoomCurrentCapacity >= *roomDetails.RoomMaxCapacity {
			return nil, fmt.Errorf("room is full")
		}
	}

	// Create voter IDs JSON for snapshot
	voterIDs := make([]uint, len(roomMembers))
	for i, member := range roomMembers {
		voterIDs[i] = *member.UserID
	}
	voterIDsJSON, err := json.Marshal(voterIDs)
	if err != nil {
		return nil, err
	}

	joinRequest := &entities.RoomJoinRequest{
		RoomID:             v.Ptr(uint(requestedRoomID)),
		RequesterUserID:    v.Ptr(uint(requesterUserID)),
		Status:             nil, // * pending
		EligibleVoterCount: v.Ptr(len(roomMembers)),
		EligibleVoterIDs:   v.Ptr(string(voterIDsJSON)),
	}

	err = s.roomJoinRepo.CreateRoomJoinRequestByUserIdRoomId(joinRequest)
	if err != nil {
		return nil, err
	}

	// Create voting entries for all room members
	for _, member := range roomMembers {
		vote := &entities.RoomJoinVote{
			RoomJoinRequestID: joinRequest.RoomJoinRequestID,
			VoterUserID:       member.UserID,
			Vote:              nil, // * pending
		}
		err = s.roomJoinRepo.CreateRoomJoinVote(vote)
		if err != nil {
			log.Printf("failed to create vote entry for user %d: %v", *member.UserID, err)
		}
	}

	// Get requester info for notification
	requesterUser, err := s.userSer.GetUserByUserId(requesterUserID)
	if err != nil {
		return nil, err
	}

	// Send notifications to all room members
	notificationMessage := fmt.Sprintf("%s %s wants to join your room '%s'. Please review and vote.",
		v.StringValue(requesterUser.Firstname),
		v.StringValue(requesterUser.Lastname),
		v.StringValue(roomDetails.RoomName))

	for _, member := range roomMembers {
		notification := dtos.CreateVoteNotificationRequest{
			NotificationMessage: v.Ptr(notificationMessage),
		}

		// Create notification
		_, err = s.notificationSer.CreateVoteNotification(int(*requesterUser.UserID), int(*member.UserID), notification, int(*joinRequest.RoomJoinRequestID))
		if err != nil {
			log.Printf("failed to create notification for user %d: %v", *member.UserID, err)
		}
	}

	return &dtos.CreateRoomJoinRequestByUserIdResponse{
		RoomJoinRequestID:  joinRequest.RoomJoinRequestID,
		RoomID:             joinRequest.RoomID,
		RequesterUserID:    joinRequest.RequesterUserID,
		Status:             v.Ptr("pending"),
		EligibleVoterCount: joinRequest.EligibleVoterCount,
		CreatedAt:          v.TimePtrToRFC3339Ptr(joinRequest.CreatedAt),
	}, nil
}

// * get join request details for voting, including room details, requester details, compatibility, voting stats, my vote, and all votes
func (s roomJoinService) GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserID(roomJoinRequestID int, voterUserID int) (*dtos.GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserIDResponse, error) {
	// * get join request
	joinRequest, err := s.roomJoinRepo.GetRoomJoinRequestByRoomJoinRequestID(roomJoinRequestID)
	if err != nil {
		return nil, fmt.Errorf("join request not found")
	}

	// * get room details manually (since no GORM relations)
	roomDetails, err := s.roomSer.GetRoomDetailsByRoomId(int(*joinRequest.RoomID))
	if err != nil {
		return nil, fmt.Errorf("room not found: %v", err)
	}

	// * get requester info with lifestyle
	requesterUser, err := s.userSer.GetProfileOfCurrentUserByUserId(int(*joinRequest.RequesterUserID))
	if err != nil {
		return nil, err
	}

	// * calculate compatibility
	requesterLifestyle, err := s.lifestyleSer.GetUserLifestyleByUserId(int(*joinRequest.RequesterUserID))
	if err != nil {
		return nil, err
	}

	// * use room details for compatibility calculation
	roomEntity := entities.Room{
		AvgTidiness:       roomDetails.AvgTidiness,
		AvgNoiseActivity:  roomDetails.AvgNoiseActivity,
		AvgSchedule:       roomDetails.AvgSchedule,
		AvgGuestFrequency: roomDetails.AvgGuestFrequency,
		AvgTaskStructure:  roomDetails.AvgTaskStructure,
		AvgMoneyAttitude:  roomDetails.AvgMoneyAttitude,
	}
	compatibilityPercent := utils.CalculateCompatibility(*requesterLifestyle, roomEntity)

	// * get voting statistics
	stats, err := s.roomJoinRepo.GetVotingStatisticsByRoomJoinRequestID(roomJoinRequestID)
	if err != nil {
		return nil, err
	}

	// * determine final result
	finalResult := "pending"
	isCompleted := false
	if *stats.RejectCount > 0 {
		finalResult = "rejected"
		isCompleted = true
	} else if *stats.VotedCount == *stats.TotalVoters && *stats.ApproveCount == *stats.TotalVoters && *stats.TotalVoters > 0 {
		finalResult = "approved"
		isCompleted = true
	}

	// * get voter's own vote
	myVote := "pending"
	voterVote, err := s.roomJoinRepo.GetVoteByRoomJoinRequestIDVoterUserID(roomJoinRequestID, voterUserID)
	if err != nil {
		return nil, fmt.Errorf("you're not eligible to vote on this request")
	}
	if voterVote.Vote != nil {
		if *voterVote.Vote {
			myVote = "approve"
		} else {
			myVote = "reject"
		}
	}

	// * get all vote details
	votes, err := s.roomJoinRepo.GetVotesByRoomJoinRequestID(roomJoinRequestID)
	if err != nil {
		return nil, err
	}

	voteDetails := make([]dtos.RoomJoinVoteDetail, len(votes))
	for i, vote := range votes {
		voteStatus := "pending"
		var votedAt *string
		if vote.Vote != nil {
			if *vote.Vote {
				voteStatus = "approve"
			} else {
				voteStatus = "reject"
			}
			votedAt = v.Ptr(vote.CreatedAt.Format(time.RFC3339))
		}

		// * get voter username manually since no GORM preload
		voterUser, err := s.userSer.GetUserByUserId(int(*vote.VoterUserID))
		voterUsername := ""
		if err == nil {
			voterUsername = v.StringValue(voterUser.Username)
		}

		voteDetails[i] = dtos.RoomJoinVoteDetail{
			VoterUserID:   vote.VoterUserID,
			VoterUsername: v.Ptr(voterUsername), // * manually fetched
			Vote:          v.Ptr(voteStatus),
			VotedAt:       votedAt,
		}
	}

	// * determine status string
	status := "pending"
	if joinRequest.Status != nil {
		if *joinRequest.Status {
			status = "approved"
		} else {
			status = "rejected"
		}
	}

	return &dtos.GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserIDResponse{
		RoomJoinRequestID:  joinRequest.RoomJoinRequestID,
		RoomID:             joinRequest.RoomID,
		RequesterUserID:    joinRequest.RequesterUserID,
		Status:             v.Ptr(status),
		EligibleVoterCount: joinRequest.EligibleVoterCount,
		CreatedAt:          v.Ptr(joinRequest.CreatedAt.Format(time.RFC3339)),

		// Room details (manually fetched)
		RoomName:    roomDetails.RoomName,
		RoomPicture: roomDetails.RoomPicture,

		// Requester details
		UserID:               requesterUser.UserID,
		Username:             requesterUser.Username,
		Firstname:            requesterUser.Firstname,
		Lastname:             requesterUser.Lastname,
		UserPicture:          requesterUser.UserPicture,
		UserAboutMe:          requesterUser.UserAboutMe,
		UserTidiness:         requesterUser.UserTidiness,
		UserNoiseActivity:    requesterUser.UserNoiseActivity,
		UserSchedule:         requesterUser.UserSchedule,
		UserGuestFrequency:   requesterUser.UserGuestFrequency,
		UserTaskStructure:    requesterUser.UserTaskStructure,
		UserMoneyAttitude:    requesterUser.UserMoneyAttitude,
		CompatibilityPercent: v.Ptr(compatibilityPercent),

		// Voting statistics
		TotalVoters:  stats.TotalVoters,
		VotedCount:   stats.VotedCount,
		ApproveCount: stats.ApproveCount,
		RejectCount:  stats.RejectCount,
		PendingCount: stats.PendingCount,
		IsCompleted:  v.Ptr(isCompleted),
		FinalResult:  v.Ptr(finalResult),

		// My vote
		MyVote:      v.Ptr(myVote),
		VoteDetails: voteDetails,
	}, nil
}

// * submit vote (approve/reject)
func (s roomJoinService) SubmitVoteByRoomJoinRequestIDVoterUserID(roomJoinRequestID int, voterUserID int, request *dtos.SubmitRoomJoinVoteRequest) (*dtos.SubmitRoomJoinVoteResponse, error) {
	// * get existing vote
	vote, err := s.roomJoinRepo.GetVoteByRoomJoinRequestIDVoterUserID(roomJoinRequestID, voterUserID)
	if err != nil {
		return nil, fmt.Errorf("vote not found or you're not eligible to vote on this request")
	}

	// * check if already voted
	if vote.Vote != nil {
		return nil, fmt.Errorf("you have already voted on this request")
	}

	vote.Vote = request.Vote

	err = s.roomJoinRepo.UpdateVote(vote)
	if err != nil {
		return nil, err
	}

	// * check if voting is complete and finalize if needed
	err = s.CheckAndFinalizeVoting(roomJoinRequestID)
	if err != nil {
		log.Printf("error finalizing voting: %v", err)
	}

	// * get updated voting statistics
	stats, err := s.roomJoinRepo.GetVotingStatisticsByRoomJoinRequestID(roomJoinRequestID)
	if err != nil {
		return nil, err
	}

	// * determine final result
	finalResult := "pending"
	isCompleted := false
	if *stats.RejectCount > 0 {
		finalResult = "rejected"
		isCompleted = true
	} else if *stats.VotedCount == *stats.TotalVoters && *stats.ApproveCount == *stats.TotalVoters && *stats.TotalVoters > 0 {
		finalResult = "approved"
		isCompleted = true
	}

	votingStatus := &dtos.VotingStatus{
		TotalVoters:  stats.TotalVoters,
		VotedCount:   stats.VotedCount,
		ApproveCount: stats.ApproveCount,
		RejectCount:  stats.RejectCount,
		PendingCount: stats.PendingCount,
		IsCompleted:  v.Ptr(isCompleted),
		FinalResult:  v.Ptr(finalResult),
	}

	voteString := "reject"
	if *request.Vote {
		voteString = "approve"
	}

	message := fmt.Sprintf("Vote submitted successfully. You voted to %s this request.", voteString)
	if isCompleted {
		if finalResult == "approved" {
			message += " The request has been approved and the user has been added to the room."
		} else {
			message += " The request has been rejected."
		}
	}

	return &dtos.SubmitRoomJoinVoteResponse{
		RoomJoinVoteID:    vote.RoomJoinVoteID,
		RoomJoinRequestID: vote.RoomJoinRequestID,
		VoterUserID:       vote.VoterUserID,
		Vote:              v.Ptr(voteString),
		VotedAt:           v.Ptr(vote.CreatedAt.Format(time.RFC3339)),
		VotingStatus:      votingStatus,
		Message:           v.Ptr(message),
	}, nil
}

// * get votes by room join request ID
func (s roomJoinService) FetchAllVotesByRoomJoinRequestID(roomJoinRequestID int) ([]entities.RoomJoinVote, error) {
	votes, err := s.roomJoinRepo.FetchAllVotesByRoomJoinRequestID(roomJoinRequestID)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	voteResponses := []entities.RoomJoinVote{}
	for _, vote := range votes {
		voteResponse := entities.RoomJoinVote{
			RoomJoinVoteID:    vote.RoomJoinVoteID,
			RoomJoinRequestID: vote.RoomJoinRequestID,
			VoterUserID:       vote.VoterUserID,
			Vote:              vote.Vote,
			CreatedAt:         vote.CreatedAt,
		}
		voteResponses = append(voteResponses, voteResponse)
	}

	return voteResponses, nil
}

// ----------------------------------------- Private Helper Functions -----------------------------------------//
// * check and finalize voting if complete
func (s roomJoinService) CheckAndFinalizeVoting(roomJoinRequestID int) error {
	stats, err := s.roomJoinRepo.GetVotingStatisticsByRoomJoinRequestID(roomJoinRequestID)
	if err != nil {
		return err
	}

	// * if any rejection, reject the request
	if *stats.RejectCount > 0 {
		return s.ProcessJoinRequest(roomJoinRequestID, false)
	}

	// * if all voted and all approved, approve the request
	if *stats.VotedCount == *stats.TotalVoters && *stats.ApproveCount == *stats.TotalVoters && *stats.TotalVoters > 0 {
		return s.ProcessJoinRequest(roomJoinRequestID, true)
	}

	// * still pending
	return nil
}

// * process final join request result
func (s roomJoinService) ProcessJoinRequest(roomJoinRequestID int, isApproved bool) error {
	// * get join request
	joinRequest, err := s.roomJoinRepo.GetRoomJoinRequestByRoomJoinRequestID(roomJoinRequestID)
	if err != nil {
		return err
	}

	joinRequest.Status = v.Ptr(isApproved)

	log.Println(joinRequest)

	// * update request status
	err = s.roomJoinRepo.UpdateRoomJoinRequestStatusByRoomJoinRequestID(joinRequest)
	if err != nil {
		return err
	}

	if isApproved {
		// * add user to room as member (not host)
		roomMember := &entities.RoomMember{
			RoomID: joinRequest.RoomID,
			UserID: joinRequest.RequesterUserID,
			IsHost: v.Ptr(false), // * new member, not host
		}

		_, err = s.roomMemberSer.CreateRoomMemberByRoomIdAndUserId(int(*roomMember.RoomID), int(*roomMember.UserID))
		if err != nil {
			return fmt.Errorf("failed to add user to room: %v", err)
		}

		// * get room details for notification
		roomDetails, _ := s.roomSer.GetRoomDetailsByRoomId(int(*joinRequest.RoomID))
		roomName := "the room"
		if roomDetails != nil && roomDetails.RoomName != nil {
			roomName = *roomDetails.RoomName
		}

		// * send approval notification to requester
		notificationMessage := fmt.Sprintf("Congratulations! Your request to join room '%s' has been approved by all members. Welcome to the room!", roomName)

		approvalNotification := dtos.CreateNotificationRequest{
			NotificationMessage: v.Ptr(notificationMessage),
		}

		_, err = s.notificationSer.CreateNotification(1, int(*joinRequest.RequesterUserID), approvalNotification)
		if err != nil {
			log.Printf("failed to create approval notification: %v", err)
		}

		log.Printf("user %d successfully joined room %d", *joinRequest.RequesterUserID, *joinRequest.RoomID)
	} else {
		// * get room details for notification
		roomDetails, _ := s.roomSer.GetRoomDetailsByRoomId(int(*joinRequest.RoomID))
		roomName := "the room"
		if roomDetails != nil && roomDetails.RoomName != nil {
			roomName = *roomDetails.RoomName
		}

		// * send rejection notification to requester
		notificationMessage := fmt.Sprintf("Sorry, your request to join room '%s' has been declined by the room members.", roomName)

		rejectionNotification := dtos.CreateNotificationRequest{
			NotificationMessage: v.Ptr(notificationMessage),
		}

		_, err = s.notificationSer.CreateNotification(1, int(*joinRequest.RequesterUserID), rejectionNotification)
		if err != nil {
			log.Printf("failed to create rejection notification: %v", err)
		}

		log.Printf("user %d's request to join room %d was rejected", *joinRequest.RequesterUserID, *joinRequest.RoomID)

		_, err = s.notificationSer.PutMarkAllAsReadByRoomJoinRequestID(roomJoinRequestID)
		if err != nil {
			log.Printf("failed to mark notifications as read for roomJoinRequest %d: %v", roomJoinRequestID, err)
		}
	}

	return nil
}
