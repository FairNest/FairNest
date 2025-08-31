package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type RoomService interface {
	FetchAllRoom() ([]entities.Room, error)

	FetchAllRoomWithRoomMembersDetails() ([]dtos.FetchAllRoomWithRoomMembersResponse, error)
	FetchAllRoomSuitUserLifestyleByUserId(int) ([]dtos.FetchAllRoomSuitUserLifestyleByUserIdResponse, error)
	//GetRoomByRoomId(int) (*entities.Room, error)

	////////////////////////////////////////////////////////////////////////////////////////////////////////

	CreateRoomByUserId(int, dtos.CreateRoomByUserIdRequest) (*dtos.CreateRoomByUserIdResponse, error)

	FetchAllPublicRoomSuitUserLifestyleByUserId(int) ([]dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse, error)
	FetchAllMyRoomByUserId(int) ([]dtos.FetchAllMyRoomByUserIdResponse, error)
}
