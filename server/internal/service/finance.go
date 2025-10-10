package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type FinanceService interface {
	FetchAllFinance() ([]entities.Finance, error)
	GetFinanceByFinanceID(int) (*entities.Finance, error)

	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	FetchAllTransaction() ([]entities.Transaction, error)
	GetTransactionByTransactionID(int) (*entities.Transaction, error)

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	FetchAllUpcomingPaymentByUserID(int) ([]dtos.FetchAllUpcomingPaymentByUserIDResponse, error)
	FetchAllPaidTransactionHistoryByUserID(int) ([]dtos.FetchAllPaidTransactionHistoryByUserIDResponse, error)
}
