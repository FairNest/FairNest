package service

import (
	"fairnest/internal/entities"
)

type RoomService interface {
	FetchRooms() ([]entities.Room, error)
	//GetRoomByRoomId(int) (*entities.Room, error)

	////////////////////////////////////////////////////////////////////
}
