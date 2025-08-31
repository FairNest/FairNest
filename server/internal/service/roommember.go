package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type RoomMemberService interface {
	FetchAllRoomMemberByRoomId(int) ([]entities.RoomMember, error)

	// --------------------------------------------------------------------------------------------------------------

	FetchAllRoomMemberWithUserDetailsByRoomId(int) ([]dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse, error)

	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	CreateRoomMemberByRoomIdAndUserId(int, int) (*entities.RoomMember, error)
}
