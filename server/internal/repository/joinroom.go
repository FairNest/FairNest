package repository

import (
	"fairnest/internal/entities"
)

type RoomJoinRepository interface {
	// * room join request operations
	CreateRoomJoinRequestByUserIdRoomId(request *entities.RoomJoinRequest) error

	// * check if user has pending request for room
	GetUserHasPendingJoinRequestByUserIdRoomId(int, int) (bool, error)

	// * voting operations
	CreateRoomJoinVote(vote *entities.RoomJoinVote) error
}
