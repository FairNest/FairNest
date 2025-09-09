package repository

import (
	"fairnest/internal/entities"

	"gorm.io/gorm"
)

type choreRepositoryDB struct {
	db *gorm.DB
}

func NewChoreRepositoryDB(db *gorm.DB) choreRepositoryDB {
	return choreRepositoryDB{db: db}
}

func (r choreRepositoryDB) FetchAllChore() ([]entities.Chore, error) {
	chores := []entities.Chore{}
	result := r.db.Find(&chores)
	if result.Error != nil {
		return nil, result.Error
	}
	return chores, nil
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
