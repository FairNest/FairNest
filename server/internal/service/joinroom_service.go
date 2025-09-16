package service

import (
	"encoding/json"
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"fmt"
	"log"
)

type roomJoinService struct {
	roomJoinRepo    repository.RoomJoinRepository
	roomMemberSer   RoomMemberService
	roomSer         RoomService
	userSer         UserService
	notificationSer NotificationService
}

func NewRoomJoinService(roomJoinRepo repository.RoomJoinRepository, roomMemberSer RoomMemberService, roomSer RoomService, userSer UserService, notificationSer NotificationService) roomJoinService {
	return roomJoinService{
		roomJoinRepo:    roomJoinRepo,
		roomMemberSer:   roomMemberSer,
		roomSer:         roomSer,
		userSer:         userSer,
		notificationSer: notificationSer,
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
