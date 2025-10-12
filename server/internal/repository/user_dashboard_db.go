package repository

import (
	"fairnest/internal/entities"
	"time"

	"gorm.io/gorm"
)

type userDashboardRepositoryDB struct {
	db *gorm.DB
}

func NewUserDashboardRepositoryDB(db *gorm.DB) UserDashboardRepository {
	return &userDashboardRepositoryDB{db: db}
}

// ==================== CHORE QUERIES ====================

// GetUserChoresForToday returns all chore assignments for user TODAY
func (r *userDashboardRepositoryDB) GetUserChoresForToday(userID uint) ([]entities.ChoreAssignment, error) {
	var assignments []entities.ChoreAssignment
	today := time.Now()
	startOfDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	endOfDay := startOfDay.AddDate(0, 0, 1)

	err := r.db.
		Preload("Chore").
		Preload("User").
		Where("user_id = ? AND assigned_date >= ? AND assigned_date < ?", userID, startOfDay, endOfDay).
		Order("due_date_time ASC").
		Find(&assignments).Error

	return assignments, err
}

// GetUserCompletedChoresForToday returns completed chore assignments for user TODAY
func (r *userDashboardRepositoryDB) GetUserCompletedChoresForToday(userID uint) ([]entities.ChoreAssignment, error) {
	var assignments []entities.ChoreAssignment
	today := time.Now()
	startOfDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	endOfDay := startOfDay.AddDate(0, 0, 1)

	err := r.db.
		Preload("Chore").
		Preload("User").
		Where("user_id = ? AND status = ? AND assigned_date >= ? AND assigned_date < ?",
			userID, "completed", startOfDay, endOfDay).
		Order("completed_at DESC").
		Find(&assignments).Error

	return assignments, err
}

// GetUserUpcomingChores returns unfinished chore assignments in the next 7 days (excluding today)
func (r *userDashboardRepositoryDB) GetUserUpcomingChores(userID uint, startDate, endDate time.Time) ([]entities.ChoreAssignment, error) {
	var assignments []entities.ChoreAssignment

	err := r.db.
		Preload("Chore").
		Preload("User").
		Where("user_id = ? AND status IN (?) AND assigned_date >= ? AND assigned_date < ?",
			userID, []string{"pending", "overdue"}, startDate, endDate).
		Order("assigned_date ASC, due_date_time ASC").
		Find(&assignments).Error

	return assignments, err
}

// ==================== FINANCE QUERIES ====================

// GetUserPaymentsDueToday returns all transactions where user is debtor and due TODAY
func (r *userDashboardRepositoryDB) GetUserPaymentsDueToday(userID uint) ([]entities.Transaction, error) {
	var transactions []entities.Transaction
	today := time.Now()
	startOfDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	endOfDay := startOfDay.AddDate(0, 0, 1)

	err := r.db.
		Preload("Finance").
		Preload("Payer").
		Joins("JOIN finances ON finances.finance_id = transactions.finance_id").
		Where("transactions.debtor_id = ? AND finances.due_date >= ? AND finances.due_date < ?",
			userID, startOfDay, endOfDay).
		Order("finances.due_date ASC").
		Find(&transactions).Error

	return transactions, err
}

// GetUserCompletedPaymentsDueToday returns settled transactions where user is debtor and due TODAY
func (r *userDashboardRepositoryDB) GetUserCompletedPaymentsDueToday(userID uint) ([]entities.Transaction, error) {
	var transactions []entities.Transaction
	today := time.Now()
	startOfDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	endOfDay := startOfDay.AddDate(0, 0, 1)

	err := r.db.
		Preload("Finance").
		Preload("Payer").
		Joins("JOIN finances ON finances.finance_id = transactions.finance_id").
		Where("transactions.debtor_id = ? AND transactions.transaction_status = ? AND finances.due_date >= ? AND finances.due_date < ?",
			userID, true, startOfDay, endOfDay).
		Order("transactions.paid_at DESC").
		Find(&transactions).Error

	return transactions, err
}

// GetUserUpcomingPayments returns unsettled transactions in the next 7 days (excluding today)
func (r *userDashboardRepositoryDB) GetUserUpcomingPayments(userID uint, startDate, endDate time.Time) ([]entities.Transaction, error) {
	var transactions []entities.Transaction

	err := r.db.
		Preload("Finance").
		Preload("Payer").
		Joins("JOIN finances ON finances.finance_id = transactions.finance_id").
		Where("transactions.debtor_id = ? AND transactions.transaction_status = ? AND finances.due_date >= ? AND finances.due_date < ?",
			userID, false, startDate, endDate).
		Order("finances.due_date ASC").
		Find(&transactions).Error

	return transactions, err
}
