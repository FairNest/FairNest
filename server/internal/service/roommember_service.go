package service

import (
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"github.com/gofiber/fiber/v2"
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

func (s roomMemberService) GetRoomMemberByRoomId(roomId int) (*entities.RoomMember, error) {
	roomMember, err := s.roomMemberRepo.GetRoomMemberByRoomId(roomId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if roomMember.RoomMemberID == nil &&
		roomMember.RoomID == nil &&
		roomMember.UserID == nil &&
		roomMember.IsHost == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "Room member data is not found")
	}

	roomMemberResponse := entities.RoomMember{
		RoomMemberID: roomMember.RoomMemberID,
		RoomID:       roomMember.RoomID,
		UserID:       roomMember.UserID,
		IsHost:       roomMember.IsHost,
	}
	return &roomMemberResponse, nil
}

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
