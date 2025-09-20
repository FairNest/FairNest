package repository

import "fairnest/internal/entities"

type LifestyleRepository interface {
	GetLifestyleByUserId(int) (*entities.Lifestyle, error)
	/////////////////////////////////////////////////////////////////
	CreateLifestyleByUserId(lifestyle *entities.Lifestyle) error
	GetUserLifestyleByUserId(int) (*entities.Lifestyle, error)

	GetUserOverallLifestyleByUserId(int) (*entities.Lifestyle, error)
	GetLifestylesByRoomId(roomId int) ([]*entities.Lifestyle, error)

	// NEW: room members’ basic user info (id, name, avatar)
	GetUsersInRoom(roomId int) ([]*entities.User, error)
}
