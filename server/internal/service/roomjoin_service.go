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
		_, err = s.notificationSer.CreateVoteNotification(int(*requesterUser.UserID), int(*member.UserID), notification)
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
	joinRequest, err := s.roomJoinRepo.GetRoomJoinRequestByRequesterUserID(roomJoinRequestID)
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
	stats, err := s.roomJoinRepo.GetVotingStatisticsByRequesterID(roomJoinRequestID)
	if err != nil {
		return nil, err
	}

	// * determine final result
	finalResult := "pending"
	isCompleted := false
	if stats.RejectCount > 0 {
		finalResult = "rejected"
		isCompleted = true
	} else if stats.VotedCount == stats.TotalVoters && stats.ApproveCount == stats.TotalVoters {
		finalResult = "approved"
		isCompleted = true
	}

	// * get voter's own vote
	myVote := "pending"
	voterVote, err := s.roomJoinRepo.GetVoteByRoomJoinRequestIDVoterUserID(roomJoinRequestID, voterUserID)
	if err == nil && voterVote.Vote != nil {
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
		TotalVoters:  v.Ptr(stats.TotalVoters),
		VotedCount:   v.Ptr(stats.VotedCount),
		ApproveCount: v.Ptr(stats.ApproveCount),
		RejectCount:  v.Ptr(stats.RejectCount),
		PendingCount: v.Ptr(stats.PendingCount),
		IsCompleted:  v.Ptr(isCompleted),
		FinalResult:  v.Ptr(finalResult),

		// My vote
		MyVote:      v.Ptr(myVote),
		VoteDetails: voteDetails,
	}, nil
}
