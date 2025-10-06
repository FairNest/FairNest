package repository

import "fairnest/internal/entities"

type FinanceRepository interface {
	FetchAllFinance() ([]entities.Room, error)
}
