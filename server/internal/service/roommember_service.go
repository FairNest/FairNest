package service

import (
	"errors"
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"log"
)

type roomMemberService struct {
	roomMemberRepo repository.RoomMemberRepository
	userSer        UserService
}

func NewRoomMemberService(roomMemberRepo repository.RoomMemberRepository, userSer UserService) roomMemberService {
	return roomMemberService{
		roomMemberRepo: roomMemberRepo,
		userSer:        userSer,
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
	members, err := s.roomMemberRepo.FetchAllRoomMemberByRoomId(roomId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	// Step 2: collect user IDs
	userIDs := make([]int, 0, len(members))
	for _, m := range members {
		userIDs = append(userIDs, v.UintToInt(v.UintValue(m.UserID)))
	}

	// Step 3: fetch users via UserService
	users, err := s.userSer.FetchAllUserByUserId(userIDs)
	if err != nil {
		return nil, err
	}

	// Step 4: build map
	userMap := make(map[int]entities.User)
	for _, u := range users {
		userMap[v.UintToInt(v.UintValue(u.UserID))] = u
	}

	// Step 5: merge into DTO
	responses := make([]dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse, 0, len(members))
	for _, m := range members {
		u := userMap[v.UintToInt(v.UintValue(m.UserID))]
		responses = append(responses, dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse{
			RoomMemberID: m.RoomMemberID,
			RoomID:       m.RoomID,
			UserID:       m.UserID,
			IsHost:       m.IsHost,
			Username:     u.Username,
			Email:        u.Email,
			Firstname:    u.Firstname,
			Lastname:     u.Lastname,
			PhoneNumber:  u.PhoneNumber,
			UserPicture:  u.UserPicture,
			UserAboutMe:  u.UserAboutMe,
		})
	}

	return responses, nil
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

func (s roomMemberService) CheckUserHasRoomOrNot(userId int) (bool, error) {
	res, err := s.roomMemberRepo.CheckUserHasRoomOrNot(userId)
	if err != nil {
		return false, err
	}

	// If user doesn't exist at all → explicit error
	if !res.UserExists {
		return false, errors.New("user not found")
	}

	// Otherwise return room membership flag
	return res.HasRoom, nil
}
