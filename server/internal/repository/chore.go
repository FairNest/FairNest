package repository

import "fairnest/internal/entities"

type ChoreRepository interface {
	FetchAllChore() ([]entities.Chore, error)
}
