package repository

import (
	"fairnest/internal/entities"
	"gorm.io/gorm"
)

type roomRepositoryDB struct {
	db *gorm.DB
}

func NewRoomRepositoryDB(db *gorm.DB) roomRepositoryDB {
	return roomRepositoryDB{db: db}
}

func (r roomRepositoryDB) FetchAllRoom() ([]entities.Room, error) {
	rooms := []entities.Room{}
	result := r.db.Find(&rooms)
	if result.Error != nil {
		return nil, result.Error
	}
	return rooms, nil
}
