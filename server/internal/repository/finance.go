package repository

import "fairnest/internal/entities"

type FinanceRepository interface {
	FetchAllFinance() ([]entities.Finance, error)
	GetFinanceByFinanceID(int) (*entities.Finance, error)

	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	FetchAllTransaction() ([]entities.Transaction, error)
	GetTransactionByTransactionID(int) (*entities.Transaction, error)

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	FetchAllUnpaidTransactionsWithFinanceDetailsByUserID(int) ([]entities.Transaction, error)
	//FetchAllTransactionHistoryByUserID(int) ([]entities.Transaction, error)
}
