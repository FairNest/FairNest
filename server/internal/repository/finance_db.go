package repository

import (
	"fairnest/internal/entities"
	"gorm.io/gorm"
	"time"
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

func (r financeRepositoryDB) GetTotalPaidByUserIDAndMonth(userID int) (*int, error) {
	startOfMonth := getStartOfCurrentMonth()
	var total int

	// PayerID=UserID, Status=true
	result := r.db.Model(&entities.Transaction{}).
		Select("COALESCE(SUM(total_amount), 0)").
		Where("payer_id = ? AND transaction_status = ? AND created_at >= ?", userID, true, startOfMonth).
		Row().Scan(&total)

	if result != nil {
		return nil, result
	}
	return &total, nil
}

func (r financeRepositoryDB) GetTotalOwedToUserByMonth(userID int) (*int, error) {
	startOfMonth := getStartOfCurrentMonth()
	var total int

	// PayerID=UserID, Status=false
	result := r.db.Model(&entities.Transaction{}).
		Select("COALESCE(SUM(total_amount), 0)").
		Where("payer_id = ? AND transaction_status = ? AND created_at >= ?", userID, false, startOfMonth).
		Row().Scan(&total)

	if result != nil {
		return nil, result
	}
	return &total, nil
}

func (r financeRepositoryDB) GetTotalOwedByUserByMonth(userID int) (*int, error) {
	startOfMonth := getStartOfCurrentMonth()
	var total int

	// DebtorID=UserID, Status=false
	result := r.db.Model(&entities.Transaction{}).
		Select("COALESCE(SUM(total_amount), 0)").
		Where("debtor_id = ? AND transaction_status = ? AND created_at >= ?", userID, false, startOfMonth).
		Row().Scan(&total)

	if result != nil {
		return nil, result
	}
	return &total, nil
}

func (r financeRepositoryDB) FetchAllUnsettledTransactionsByUserID(userID int) ([]entities.Transaction, error) {
	transactions := []entities.Transaction{}

	result := r.db.
		Where("transaction_status = ?", false).
		Where("payer_id = ? OR debtor_id = ?", userID, userID).
		Preload("Payer").
		Preload("Debtor").
		Order("created_at DESC").
		Find(&transactions)

	if result.Error != nil {
		return nil, result.Error
	}
	return transactions, nil
}

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

func (r financeRepositoryDB) CreateFinanceByPayerID(finance *entities.Finance, transactions []entities.Transaction) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if result := tx.Create(finance); result.Error != nil {
			return result.Error
		}

		financeID := finance.FinanceID
		for i := range transactions {
			transactions[i].FinanceID = financeID
		}

		if result := tx.Create(&transactions); result.Error != nil {
			return result.Error
		}

		return nil
	})
}

func (r financeRepositoryDB) FetchAllOverdueTransactions() ([]entities.Transaction, error) {
	var transactions []entities.Transaction

	result := r.db.Model(&entities.Transaction{}).
		Joins("left join finances on transactions.finance_id = finances.finance_id").
		Where("transactions.transaction_status = ? AND (transactions.overdue_penalty = ? OR transactions.overdue_penalty IS NULL) AND finances.due_date < ?", false, false, time.Now()).
		Preload("Finance").
		Preload("Debtor").
		Find(&transactions)

	if result.Error != nil {
		return nil, result.Error
	}

	return transactions, nil
}

func (r financeRepositoryDB) PatchPaidByTransactionID(transaction *entities.Transaction) error {
	result := r.db.Updates(transaction)
	if result.Error != nil {
		return result.Error
	}

	return nil
}

// ----------------------------------------- Private Helper Functions -----------------------------------------//
// Helper function to get the start of the current month
func getStartOfCurrentMonth() time.Time {
	now := time.Now()
	// Sets day to 1 and time to 00:00:00
	return time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
}

// SetOverduePenalty updates the overdue_penalty field for a specific transaction.
func (r financeRepositoryDB) SetOverduePenalty(transactionID uint) error {
	result := r.db.Model(&entities.Transaction{}).Where("transaction_id = ?", transactionID).Update("overdue_penalty", true)
	return result.Error
}
