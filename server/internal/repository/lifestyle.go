package repository

import "fairnest/internal/entities"

type LifestyleRepository interface {
	GetLifestyleByUserId(int) (*entities.Lifestyle, error)
	/////////////////////////////////////////////////////////////////
	CreateLifestyle(lifestyle *entities.Lifestyle) error
	GetUserLifestyleByUserId(int) (*entities.Lifestyle, error)
}
