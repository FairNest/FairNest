package repository

import "fairnest/internal/entities"

type RoomRepository interface {
	FetchAllRoom() ([]entities.Room, error)
}
