package repository

import (
	"fairnest/internal/entities"
	"time"
)

type UserDashboardRepository interface {
	// Chore queries
	GetUserChoresForToday(userID uint) ([]entities.ChoreAssignment, error)
	GetUserCompletedChoresForToday(userID uint) ([]entities.ChoreAssignment, error)
	GetUserUpcomingChores(userID uint, startDate, endDate time.Time) ([]entities.ChoreAssignment, error)

	// Finance queries
	GetUserPaymentsDueToday(userID uint) ([]entities.Transaction, error)
	GetUserCompletedPaymentsDueToday(userID uint) ([]entities.Transaction, error)
	GetUserUpcomingPayments(userID uint, startDate, endDate time.Time) ([]entities.Transaction, error)
}
