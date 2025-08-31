package repository

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type RoomMemberRepository interface {
	FetchAllRoomMemberByRoomId(int) ([]entities.RoomMember, error)

	/////////////////////////////////////////////////////////////////

	CreateRoomMemberByRoomIdAndUserId(roomMember *entities.RoomMember) error
	CheckUserHasRoomOrNot(userId int) (*dtos.UserRoomCheck, error)
}
