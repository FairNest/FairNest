package repository

import "fairnest/internal/entities"

type RoomMemberRepository interface {
	GetRoomMemberByRoomId(int) (*entities.RoomMember, error)
	/////////////////////////////////////////////////////////////////
	CreateRoomMember(roomMember *entities.RoomMember) error
}
