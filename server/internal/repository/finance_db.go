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

func (r financeRepositoryDB) FetchAllFinance() ([]entities.Finance, error) {
	finances := []entities.Finance{}
	result := r.db.Find(&finances)
	if result.Error != nil {
		return nil, result.Error
	}
	return finances, nil
}

func (r financeRepositoryDB) GetFinanceByFinanceID(financeId int) (*entities.Finance, error) {
	finance := entities.Finance{}
	result := r.db.Where("finance_id = ?", financeId).First(&finance)
	if result.Error != nil {
		return nil, result.Error
	}
	return &finance, nil
}
