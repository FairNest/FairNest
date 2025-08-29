package repository

import (
	"fairnest/internal/entities"
	"gorm.io/gorm"
)

type templateRepositoryDB struct {
	db *gorm.DB
}

func NewTemplateRepositoryDB(db *gorm.DB) templateRepositoryDB {
	return templateRepositoryDB{db: db}
}

func (r roomRepositoryDB) FetchAllTemplate() ([]entities.Room, error) {
	rooms := []entities.Room{}
	result := r.db.Find(&rooms)
	if result.Error != nil {
		return nil, result.Error
	}
	return rooms, nil
}
