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

func (r lifestyleRepositoryDB) GetLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyles := entities.Lifestyle{}
	result := r.db.Where("user_id = ?", userId).Find(&lifestyles)
	if result.Error != nil {
		return nil, result.Error
	}
	return &lifestyles, nil
}

///////////////////////////////////////////////////////////////////////////

func (r lifestyleRepositoryDB) CreateLifestyleByUserId(lifestyle *entities.Lifestyle) error {
	result := r.db.Create(lifestyle)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (r lifestyleRepositoryDB) GetUserLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyles := entities.Lifestyle{}
	result := r.db.Where("user_id = ?", userId).Find(&lifestyles)
	if result.Error != nil {
		return nil, result.Error
	}
	return &lifestyles, nil
}
