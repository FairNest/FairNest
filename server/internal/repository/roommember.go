package repository

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type RoomMemberRepository interface {
	FetchAllRoomMemberByRoomId(int) ([]entities.RoomMember, error)

	/////////////////////////////////////////////////////////////////

	CreateRoomMemberByRoomIdAndUserId(roomMember *entities.RoomMember) error
	GetCheckUserHasRoomOrNotByUserId(userID int) (*dtos.UserRoomCheck, error)
	GetUsersBasicByRoomId(roomID int) ([]dtos.RoomUserInfo, error)

	IncrementRoomCurrentCapacityByRoomID(roomID int) error
}
