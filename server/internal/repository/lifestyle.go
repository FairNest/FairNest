package repository

import "fairnest/internal/entities"

type LifestyleRepository interface {
	GetLifestyleByUserId(int) (*entities.Lifestyle, error)
	/////////////////////////////////////////////////////////////////
	CreateLifestyleByUserId(lifestyle *entities.Lifestyle) error
	GetUserLifestyleByUserId(int) (*entities.Lifestyle, error)
}
