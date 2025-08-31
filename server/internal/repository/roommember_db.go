package repository

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"gorm.io/gorm"
)

type roomMemberRepositoryDB struct {
	db *gorm.DB
}

func NewRoomMemberRepositoryDB(db *gorm.DB) roomMemberRepositoryDB {
	return roomMemberRepositoryDB{db: db}
}

func (r roomMemberRepositoryDB) FetchAllRoomMemberByRoomId(roomId int) ([]entities.RoomMember, error) {
	roomMembers := []entities.RoomMember{}
	result := r.db.Where("room_id = ?", roomId).Find(&roomMembers)
	if result.Error != nil {
		return nil, result.Error
	}
	return roomMembers, nil
}

// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func (r roomMemberRepositoryDB) CreateRoomMemberByRoomIdAndUserId(roomMember *entities.RoomMember) error {
	result := r.db.Create(roomMember)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (r roomMemberRepositoryDB) CheckUserHasRoomOrNot(userId int) (*dtos.UserRoomCheck, error) {
	var result dtos.UserRoomCheck

	err := r.db.
		Table("users").
		Select(`
        EXISTS(SELECT 1 FROM users WHERE user_id = ?) AS user_exists,
        EXISTS(SELECT 1 FROM room_members WHERE user_id = ?) AS has_room
    `, userId, userId).
		Scan(&result).Error
	if err != nil {
		return nil, err
	}
	return &result, nil
}
