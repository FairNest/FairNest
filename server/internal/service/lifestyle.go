package service

import (
	"fairnest/internal/entities"
)

type LifestyleService interface {
	GetLifestyleByUserId(int) (*entities.Lifestyle, error)
}
