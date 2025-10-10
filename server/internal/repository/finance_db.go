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
	result := r.db.Find(&finances).Order("created_at")
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
	result := r.db.Find(&transactions).Order("created_at")
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func (r financeRepositoryDB) FetchAllUnpaidTransactionsWithFinanceDetailsByUserID(userID int) ([]entities.Transaction, error) {
	transactions := []entities.Transaction{}
	result := r.db.Where("debtor_id = ? AND transaction_status = ?", userID, false).
		Preload("Finance").
		Order("created_at").Find(&transactions)
	if result.Error != nil {
		return nil, result.Error
	}
	return transactions, nil
}

func (r financeRepositoryDB) FetchAllPaidTransactionHistoryByUserID(userID int) ([]entities.Transaction, error) {
	transactions := []entities.Transaction{}
	result := r.db.Where("debtor_id = ? AND transaction_status = ?", userID, true).
		Preload("Finance").
		Preload("Payer").
		Order("paid_at DESC").
		Find(&transactions)
	if result.Error != nil {
		return nil, result.Error
	}
	return transactions, nil
}
