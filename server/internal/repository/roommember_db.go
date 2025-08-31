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

// ------------------------------------------------------------------------------------------------------------------------------------------------------------------

func (r roomMemberRepositoryDB) FetchAllRoomMemberWithUserDetailsByRoomId(roomId int) ([]dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse, error) {
	var roomMembers []dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse
	err := r.db.Table("room_members").
		Select(`
			room_members.room_member_id,
			room_members.room_id,
			room_members.user_id,
			room_members.is_host,
			users.username,
			users.email,
			users.firstname,
			users.lastname,
			users.phone_number,
			users.user_picture,
			users.user_about_me`).
		Joins("LEFT JOIN users ON room_members.user_id = users.user_id").
		Where("room_members.room_id = ?", roomId).
		Scan(&roomMembers).Error
	return roomMembers, err
}

// //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func (r roomMemberRepositoryDB) CreateRoomMemberByRoomIdAndUserId(roomMember *entities.RoomMember) error {
	result := r.db.Create(roomMember)
	if result.Error != nil {
		return result.Error
	}
	return nil
}
