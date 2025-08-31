package repository

import (
	"fairnest/internal/entities"
)

type RoomMemberRepository interface {
	FetchAllRoomMemberByRoomId(int) ([]entities.RoomMember, error)

	/////////////////////////////////////////////////////////////////

	CreateRoomMemberByRoomIdAndUserId(roomMember *entities.RoomMember) error
}
