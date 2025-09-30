package repository

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type RoomRepository interface {
	FetchAllRoom() ([]entities.Room, error)
	////////////////////////////////////////////////////////////////
	CreateRoomByUserId(room *entities.Room) error
	ExistsByCode(code string) (bool, error) // To check if room code already exists

	FetchAllPublicRoom() ([]entities.Room, error)
	GetMyRoomByUserId(userId int) (*entities.Room, error)

	GetRoomDetailsByRoomId(roomId int) (*entities.Room, error)
	GetRoomDetailsByRoomCode(roomCode string) (*entities.Room, error)

	GetHouseRulesByRoomId(roomId int) (*entities.Room, error)
	PatchEditHouseRulesByRoomId(room *entities.Room) error

	GetRoomOverallLifestyleByRoomId(roomId int) (*entities.Room, error)

	GetMyPendingRoomByUserID(userID int) (*dtos.GetMyPendingRoomByUserIDResponse, error)
}
