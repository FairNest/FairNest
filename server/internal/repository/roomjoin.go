package repository

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type RoomJoinRepository interface {
	// * room join request operations
	CreateRoomJoinRequestByUserIdRoomId(request *entities.RoomJoinRequest) error
	GetRoomJoinRequestByRequesterUserID(requesterUserID int) (*entities.RoomJoinRequest, error)

	// * check if user has pending request for room
	GetUserHasPendingJoinRequestByUserIdRoomId(int, int) (bool, error)

	//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	// * voting operations
	CreateRoomJoinVote(vote *entities.RoomJoinVote) error
	GetVoteByRoomJoinRequestIDVoterUserID(roomJoinRequestID int, voterUserID int) (*entities.RoomJoinVote, error)

	GetVotesByRoomJoinRequestID(roomJoinRequestID int) ([]entities.RoomJoinVote, error)

	// * get voting statistics
	GetVotingStatisticsByRequesterID(requesterID int) (*dtos.VotingStats, error)
}
