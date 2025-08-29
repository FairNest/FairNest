package repository

import "fairnest/internal/entities"

type RoomRepository interface {
	FetchAllRoom() ([]entities.Room, error)
	////////////////////////////////////////////////////////////////
	CreateRoomByUserId(room *entities.Room) error
	ExistsByCode(code string) (bool, error) // To check if room code already exists
}
