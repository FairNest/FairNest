package service

import (
	"fairnest/internal/entities"
)

type RoomMemberService interface {
	GetRoomMemberByRoomId(int) (*entities.RoomMember, error)
}
