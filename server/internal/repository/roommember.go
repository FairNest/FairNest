package repository

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type RoomMemberRepository interface {
	FetchAllRoomMemberByRoomId(int) ([]entities.RoomMember, error)

	// ----------------------------------------------------------------------------------------

	FetchAllRoomMemberWithUserDetailsByRoomId(int) ([]dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse, error)

	/////////////////////////////////////////////////////////////////

	CreateRoomMemberByRoomIdAndUserId(roomMember *entities.RoomMember) error
}
