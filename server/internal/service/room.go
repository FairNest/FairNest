package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type RoomService interface {
	FetchRooms() ([]entities.Room, error)
	//GetRoomByRoomId(int) (*entities.Room, error)

	////////////////////////////////////////////////////////////////////////////////////////////////////////
	CreateRoomByUserId(int, dtos.CreateRoomByUserIdRequest) (*dtos.CreateRoomByUserIdResponse, error)
}
