package service

import (
	"fairnest/internal/entities"
)

type RoomMemberService interface {
	FetchAllRoomMemberByRoomId(int) (*entities.RoomMember, error)
	/////////////////////////////////////////////////////////////////
	CreateRoomMemberByRoomIdAndUserId(int, int) (*entities.RoomMember, error)
}
