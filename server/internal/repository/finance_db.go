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
	result := r.db.Find(&finances).Order("created_at DESC")
	if result.Error != nil {
		return nil, result.Error
	}
	return finances, nil
}

func (r financeRepositoryDB) GetFinanceByFinanceID(financeID int) (*entities.Finance, error) {
	finance := entities.Finance{}
	result := r.db.Where("finance_id = ?", financeID).First(&finance)
	if result.Error != nil {
		return nil, result.Error
	}
	return &finance, nil
}

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

func (r financeRepositoryDB) FetchAllTransaction() ([]entities.Transaction, error) {
	transactions := []entities.Transaction{}
	result := r.db.Find(&transactions).Order("created_at DESC")
	if result.Error != nil {
		return nil, result.Error
	}
	return transactions, nil
}

func (r financeRepositoryDB) GetTransactionByTransactionID(transactionID int) (*entities.Transaction, error) {
	transaction := entities.Transaction{}
	result := r.db.Where("transaction_id = ?", transactionID).First(&transaction)
	if result.Error != nil {
		return nil, result.Error
	}
	return &transaction, nil
}
