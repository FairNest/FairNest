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

//////////////////////////////////////////////////////////////////////////////////////////////////////////

func (r roomRepositoryDB) CreateRoomByUserId(room *entities.Room) error {
	result := r.db.Create(room)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (r roomRepositoryDB) ExistsByCode(code string) (bool, error) {
	var count int64
	err := r.db.Model(&entities.Room{}).Where("room_code = ?", code).Count(&count).Error
	return count > 0, err
}
