package repository

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/utils/v"
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

func (r roomJoinRepositoryDB) GetRoomJoinRequestByRoomJoinRequestID(roomJoinRequestID int) (*entities.RoomJoinRequest, error) {
	var request entities.RoomJoinRequest
	result := r.db.First(&request, "room_join_request_id = ?", roomJoinRequestID)
	if result.Error != nil {
		return nil, result.Error
	}
	return &request, nil
}

func (r roomJoinRepositoryDB) UpdateRoomJoinRequestStatusByRoomJoinRequestID(vote *entities.RoomJoinRequest) error {
	result := r.db.Updates(vote)
	if result.Error != nil {
		return result.Error
	}
	return nil
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

func (r roomJoinRepositoryDB) UpdateVote(vote *entities.RoomJoinVote) error {
	result := r.db.Updates(vote)
	if result.Error != nil {
		return result.Error
	}

	return nil
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

func (r roomJoinRepositoryDB) GetVotingStatisticsByRoomJoinRequestID(roomJoinRequestID int) (*dtos.VotingStatus, error) {
	stats := &dtos.VotingStatus{}

	var totalVoters, approveCount, rejectCount, pendingCount int64

	// total voters
	err := r.db.Model(&entities.RoomJoinVote{}).
		Where("room_join_request_id = ?", roomJoinRequestID).
		Count(&totalVoters).Error
	if err != nil {
		return nil, err
	}

	// approve count
	err = r.db.Model(&entities.RoomJoinVote{}).
		Where("room_join_request_id = ? AND vote = ?", roomJoinRequestID, true).
		Count(&approveCount).Error
	if err != nil {
		return nil, err
	}

	// reject count
	err = r.db.Model(&entities.RoomJoinVote{}).
		Where("room_join_request_id = ? AND vote = ?", roomJoinRequestID, false).
		Count(&rejectCount).Error
	if err != nil {
		return nil, err
	}

	// pending count
	err = r.db.Model(&entities.RoomJoinVote{}).
		Where("room_join_request_id = ? AND vote IS NULL", roomJoinRequestID).
		Count(&pendingCount).Error
	if err != nil {
		return nil, err
	}

	// assign to pointers
	stats.TotalVoters = v.Ptr(int(totalVoters))
	stats.ApproveCount = v.Ptr(int(approveCount))
	stats.RejectCount = v.Ptr(int(rejectCount))
	stats.PendingCount = v.Ptr(int(pendingCount))

	voted := int(approveCount + rejectCount)
	stats.VotedCount = v.Ptr(voted)

	return stats, nil
}

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

func (r roomJoinRepositoryDB) FetchAllVotesByRoomJoinRequestID(roomJoinRequestID int) ([]entities.RoomJoinVote, error) {
	votes := []entities.RoomJoinVote{}
	result := r.db.
		Where("room_join_request_id = ?", roomJoinRequestID).
		Order("room_join_vote_id ASC").
		Find(&votes)
	if result.Error != nil {
		return nil, result.Error
	}
	return votes, nil
}
