package service

import (
	"fairnest/internal/entities"
)

type LifestyleService interface {
	GetLifestyleByUserId(int) (*entities.Lifestyle, error)
	///////////////////////////////////////////////////////////////////////////
	CreateLifestyle(userId int, request *entities.Lifestyle) (*entities.Lifestyle, error)
	GetUserLifestyleByUserId(int) (*entities.Lifestyle, error)
}
