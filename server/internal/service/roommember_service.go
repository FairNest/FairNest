package service

import (
	"log"

	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"github.com/gofiber/fiber/v2"
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
