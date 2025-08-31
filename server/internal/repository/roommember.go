package repository

import "fairnest/internal/entities"

type RoomMemberRepository interface {
	GetRoomMemberByRoomId(int) (*entities.RoomMember, error)
	/////////////////////////////////////////////////////////////////
	CreateRoomMemberByRoomIdAndUserId(roomMember *entities.RoomMember) error
}
