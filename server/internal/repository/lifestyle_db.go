package repository

import (
	"fairnest/internal/entities"
	"gorm.io/gorm"
)

type lifestyleRepositoryDB struct {
	db *gorm.DB
}

func NewLifestyleRepositoryDB(db *gorm.DB) lifestyleRepositoryDB {
	return lifestyleRepositoryDB{db: db}
}

func (r lifestyleRepositoryDB) GetLifestyleByUserId(userid int) (*entities.Lifestyle, error) {
	lifestyles := entities.Lifestyle{}
	result := r.db.Where("user_id = ?", userid).Find(&lifestyles)
	if result.Error != nil {
		return nil, result.Error
	}
	return &lifestyles, nil
}
