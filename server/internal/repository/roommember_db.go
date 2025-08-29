package repository

import (
	"fairnest/internal/entities"
	"gorm.io/gorm"
)

type roomMemberRepositoryDB struct {
	db *gorm.DB
}

func NewRoomMemberRepositoryDB(db *gorm.DB) roomMemberRepositoryDB {
	return roomMemberRepositoryDB{db: db}
}

func (r roomMemberRepositoryDB) GetRoomMemberByRoomId(roomId int) (*entities.RoomMember, error) {
	roomMembers := entities.RoomMember{}
	result := r.db.Where("room_id = ?", roomId).Find(&roomMembers)
	if result.Error != nil {
		return nil, result.Error
	}
	return &roomMembers, nil
}

func (r roomMemberRepositoryDB) CreateRoomMember(roomMember *entities.RoomMember) error {
	result := r.db.Create(roomMember)
	if result.Error != nil {
		return result.Error
	}
	return nil
}
