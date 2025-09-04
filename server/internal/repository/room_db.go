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

func (r roomRepositoryDB) FetchAllPublicRoom() ([]entities.Room, error) {
	var rooms []entities.Room
	result := r.db.
		Where("room_type = ?", true).
		Where("room_max_capacity > room_current_capacity").
		Find(&rooms)

	if result.Error != nil {
		return nil, result.Error
	}
	return rooms, nil
}

func (r roomRepositoryDB) GetMyRoomByUserId(userId int) (*entities.Room, error) {
	room := entities.Room{}

	result := r.db.
		Joins("JOIN room_members ON room_members.room_id = rooms.room_id").
		Where("room_members.user_id = ? AND room_members.is_host = ?", userId, true).
		First(&room) // <- first matching row

	if result.Error != nil {
		return nil, result.Error
	}
	return &room, nil
}

func (r roomRepositoryDB) GetRoomDetailsByRoomId(roomId int) (*entities.Room, error) {
	room := entities.Room{}
	err := r.db.
		Preload("RoomMembers.User").
		Where("room_id = ?", roomId).
		First(&room).Error

	if err != nil {
		return nil, err
	}
	return &room, nil
}

func (r roomRepositoryDB) GetRoomDetailsByRoomCode(roomCode string) (*entities.Room, error) {
	room := entities.Room{}
	err := r.db.
		Preload("RoomMembers.User").
		Where("room_code = ?", roomCode).
		First(&room).Error

	if err != nil {
		return nil, err
	}
	return &room, nil
}

func (r roomRepositoryDB) GetHouseRulesByRoomId(roomId int) (*entities.Room, error) {
	room := entities.Room{}
	if err := r.db.First(&room, roomId).Error; err != nil {
		return nil, err
	}
	return &room, nil
}

func (r roomRepositoryDB) PatchEditHouseRulesByRoomId(room *entities.Room) error {
	result := r.db.Updates(room)
	if result.Error != nil {
		return result.Error
	}

	return nil
}

func (r roomRepositoryDB) GetRoomOverallLifestyleByRoomId(roomId int) (*entities.Room, error) {
	room := entities.Room{}
	result := r.db.Where("room_id = ?", roomId).First(&room)
	if result.Error != nil {
		return nil, result.Error
	}
	return &room, nil
}
