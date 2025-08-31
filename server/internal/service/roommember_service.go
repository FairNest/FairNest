package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"log"
)

type roomMemberService struct {
	roomMemberRepo repository.RoomMemberRepository
}

func NewRoomMemberService(roomMemberRepo repository.RoomMemberRepository) roomMemberService {
	return roomMemberService{
		roomMemberRepo: roomMemberRepo,
	}
}

func (s roomMemberService) FetchAllRoomMemberByRoomId(roomId int) ([]entities.RoomMember, error) {
	roomMembers, err := s.roomMemberRepo.FetchAllRoomMemberByRoomId(roomId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	roomMemberResponses := []entities.RoomMember{}
	for _, roomMember := range roomMembers {
		roomMemberResponse := entities.RoomMember{
			RoomMemberID: roomMember.RoomMemberID,
			RoomID:       roomMember.RoomID,
			UserID:       roomMember.UserID,
			IsHost:       roomMember.IsHost,
		}
		roomMemberResponses = append(roomMemberResponses, roomMemberResponse)
	}
	return roomMemberResponses, nil
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------

func (s roomMemberService) FetchAllRoomMemberWithUserDetailsByRoomId(roomId int) ([]dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse, error) {
	roomMembers, err := s.roomMemberRepo.FetchAllRoomMemberWithUserDetailsByRoomId(roomId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	roomMemberResponses := []dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse{}
	for _, roomMember := range roomMembers {
		roomMemberResponse := dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse{
			RoomMemberID: roomMember.RoomMemberID,
			RoomID:       roomMember.RoomID,
			UserID:       roomMember.UserID,
			IsHost:       roomMember.IsHost,
			Username:     roomMember.Username,
			Email:        roomMember.Email,
			Firstname:    roomMember.Firstname,
			Lastname:     roomMember.Lastname,
			PhoneNumber:  roomMember.PhoneNumber,
			UserPicture:  roomMember.UserPicture,
			UserAboutMe:  roomMember.UserAboutMe,
		}
		roomMemberResponses = append(roomMemberResponses, roomMemberResponse)
	}
	return roomMemberResponses, nil
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func (s roomMemberService) CreateRoomMemberByRoomIdAndUserId(roomId int, userId int) (*entities.RoomMember, error) {

	roomMember := entities.RoomMember{
		RoomID: v.UintPtr(roomId),
		UserID: v.UintPtr(userId),
		IsHost: v.Ptr(true),
	}

	if err := s.roomMemberRepo.CreateRoomMemberByRoomIdAndUserId(&roomMember); err != nil {
		return nil, err
	}

	return &entities.RoomMember{
		RoomID: roomMember.RoomID,
		UserID: roomMember.UserID,
		IsHost: roomMember.IsHost,
	}, nil
}
