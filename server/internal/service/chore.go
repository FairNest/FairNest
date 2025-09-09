package service

import "fairnest/internal/entities"

type ChoreService interface {
	FetchAllChore() ([]entities.Chore, error)
}
