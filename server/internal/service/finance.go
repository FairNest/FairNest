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

	GetMyMonthlySnapshotByUserID(int) (*dtos.GetMyMonthlySnapshotByUserIDResponse, error)

	FetchAllOutstandingBalancesByUserID(int) ([]dtos.FetchAllOutstandingBalancesByUserIDResponse, error)
	FetchAllUpcomingPaymentByUserID(int) ([]dtos.FetchAllUpcomingPaymentByUserIDResponse, error)
	FetchAllPaidTransactionHistoryByUserID(int) ([]dtos.FetchAllPaidTransactionHistoryByUserIDResponse, error)

	CreateFinanceByPayerID(payerID int, req *dtos.CreateFinanceByPayerIDRequest) (*dtos.CreateFinanceByPayerIDResponse, error)

	FetchAllOverdueTransactions() ([]entities.Transaction, error)
	CheckOverduePenalty() error
}
