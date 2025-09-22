package repository

import (
	"fairnest/internal/dtos"
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

func (r roomJoinRepositoryDB) GetRoomJoinRequestByRequesterUserID(requesterUserID int) (*entities.RoomJoinRequest, error) {
	var request entities.RoomJoinRequest
	result := r.db.First(&request, "room_join_request_id = ?", requesterUserID)
	if result.Error != nil {
		return nil, result.Error
	}
	return &request, nil
}

//----------------------------------------------------------------------------------------------------------------------

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

func (r roomJoinRepositoryDB) GetVoteByRoomJoinRequestIDVoterUserID(roomJoinRequestID int, voterUserID int) (*entities.RoomJoinVote, error) {
	var vote entities.RoomJoinVote
	result := r.db.Where("room_join_request_id = ? AND voter_user_id = ?", roomJoinRequestID, voterUserID).First(&vote)
	if result.Error != nil {
		return nil, result.Error
	}

	return &vote, nil
}

func (r roomJoinRepositoryDB) GetVotesByRoomJoinRequestID(roomJoinRequestID int) ([]entities.RoomJoinVote, error) {
	var votes []entities.RoomJoinVote
	result := r.db.Where("room_join_request_id = ?", roomJoinRequestID).
		Order("created_at ASC").
		Find(&votes)
	if result.Error != nil {
		return nil, result.Error
	}
	return votes, nil
}

//------------------------------------------------------------------------------------------------------------------------------

func (r roomJoinRepositoryDB) GetVotingStatisticsByRequesterID(requesterID int) (*dtos.VotingStats, error) {
	stats := &dtos.VotingStats{}

	// * get total voters
	err := r.db.Model(&entities.RoomJoinVote{}).
		Where("room_join_request_id = ?", requesterID).
		Count(&[]int64{int64(stats.TotalVoters)}[0]).Error
	if err != nil {
		return nil, err
	}

	// * get approve count
	err = r.db.Model(&entities.RoomJoinVote{}).
		Where("room_join_request_id = ? AND vote = ?", requesterID, true).
		Count(&[]int64{int64(stats.ApproveCount)}[0]).Error
	if err != nil {
		return nil, err
	}

	// * get reject count
	err = r.db.Model(&entities.RoomJoinVote{}).
		Where("room_join_request_id = ? AND vote = ?", requesterID, false).
		Count(&[]int64{int64(stats.RejectCount)}[0]).Error
	if err != nil {
		return nil, err
	}

	// * get pending count
	err = r.db.Model(&entities.RoomJoinVote{}).
		Where("room_join_request_id = ? AND vote IS NULL", requesterID).
		Count(&[]int64{int64(stats.PendingCount)}[0]).Error
	if err != nil {
		return nil, err
	}

	stats.VotedCount = stats.ApproveCount + stats.RejectCount

	return stats, nil
}
