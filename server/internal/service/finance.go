package service

import (
	"fairnest/internal/entities"
)

type FinanceService interface {
	FetchAllFinance() ([]entities.Finance, error)
	GetFinanceByFinanceID(int) (*entities.Finance, error)

	////////////////////////////////////////////////////////////////////
}
