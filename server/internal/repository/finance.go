package repository

import "fairnest/internal/entities"

type FinanceRepository interface {
	FetchAllFinance() ([]entities.Finance, error)
	GetFinanceByFinanceID(int) (*entities.Finance, error)
}
