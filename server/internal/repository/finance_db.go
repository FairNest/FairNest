package repository

import (
	"fairnest/internal/entities"
	"gorm.io/gorm"
)

type financeRepositoryDB struct {
	db *gorm.DB
}

func NewFinanceRepositoryDB(db *gorm.DB) financeRepositoryDB {
	return financeRepositoryDB{db: db}
}

func (r financeRepositoryDB) FetchAllFinance() ([]entities.Room, error) {
	finances := []entities.Room{}
	result := r.db.Find(&finances)
	if result.Error != nil {
		return nil, result.Error
	}
	return finances, nil
}
