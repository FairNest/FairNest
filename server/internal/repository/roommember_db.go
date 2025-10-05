package repository

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fmt"

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

func (r roomMemberRepositoryDB) GetCheckUserHasRoomOrNotByUserId(userID int) (*dtos.UserRoomCheck, error) {
	var result dtos.UserRoomCheck

	err := r.db.
		Table("users").
		Select(`
        EXISTS(SELECT 1 FROM users WHERE user_id = ?) AS user_exists,
        EXISTS(SELECT 1 FROM room_members WHERE user_id = ?) AS has_room
    `, userID, userID).
		Scan(&result).Error
	if err != nil {
		return nil, err
	}
	return &result, nil
}

func (r roomMemberRepositoryDB) GetUsersBasicByRoomId(roomID int) ([]dtos.RoomUserInfo, error) {
	var rows []struct {
		UserID      *uint
		Username    *string
		UserPicture *string
	}

	err := r.db.
		Table("users").
		Select("users.user_id AS user_id, users.username AS username, users.user_picture AS user_picture").
		Joins("JOIN room_members ON room_members.user_id = users.user_id").
		Where("room_members.room_id = ?", roomID).
		Scan(&rows).Error
	if err != nil {
		return nil, err
	}

	out := make([]dtos.RoomUserInfo, 0, len(rows))
	for _, r := range rows {
		out = append(out, dtos.RoomUserInfo{
			UserID:      r.UserID,
			Username:    r.Username,
			UserPicture: r.UserPicture,
		})
	}
	return out, nil
}

func (r roomMemberRepositoryDB) IncrementRoomCurrentCapacityByRoomID(roomID int) error {
	result := r.db.Model(&entities.Room{}).
		Where("room_id = ?", roomID).
		UpdateColumn("room_current_capacity", gorm.Expr("room_current_capacity + ?", 1))
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("room with ID %d not found", roomID)
	}
	return nil
}
