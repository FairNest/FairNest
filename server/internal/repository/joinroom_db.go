package repository

import (
	"fairnest/internal/entities"
	"gorm.io/gorm"
)

type roomJoinRepositoryDB struct {
	db *gorm.DB
}

func NewRoomJoinRepositoryDB(db *gorm.DB) roomJoinRepositoryDB {
	return roomJoinRepositoryDB{db: db}
}

// * room join request operations
func (r roomJoinRepositoryDB) CreateRoomJoinRequestByUserIdRoomId(request *entities.RoomJoinRequest) error {
	result := r.db.Create(request)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

// * check if user has pending request for room
func (r roomJoinRepositoryDB) GetUserHasPendingJoinRequestByUserIdRoomId(userID int, roomID int) (bool, error) {
	var count int64
	err := r.db.Model(&entities.RoomJoinRequest{}).
		Where("requester_user_id = ? AND room_id = ? AND status IS NULL", userID, roomID).
		Count(&count).Error
	return count > 0, err
}

// * voting operations
func (r roomJoinRepositoryDB) CreateRoomJoinVote(vote *entities.RoomJoinVote) error {
	result := r.db.Create(vote)
	if result.Error != nil {
		return result.Error
	}
	return nil
}
