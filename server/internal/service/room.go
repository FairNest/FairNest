package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type RoomService interface {
	FetchAllRoom() ([]entities.Room, error)
	// ----------------------------------------------------------------------------------------
	//FetchAllRoomWithRoomMembers() ([]dtos.FetchAllRoomWithRoomMembersResponse, error)
	//GetRoomByRoomId(int) (*entities.Room, error)

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	CreateRoomByUserId(int, dtos.CreateRoomByUserIdRequest) (*dtos.CreateRoomByUserIdResponse, error)
}
