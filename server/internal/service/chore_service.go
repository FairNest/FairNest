package service

import (
	"fairnest/internal/repository"
)

type choreService struct {
	choreRepo repository.ChoreRepository
}

func NewChoreService(choreRepo repository.ChoreRepository) choreService {
	return choreService{
		choreRepo: choreRepo,
	}
}
