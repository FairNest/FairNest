package repository

import "fairnest/internal/entities"

type FinanceRepository interface {
	FetchAllFinance() ([]entities.Finance, error)
	GetFinanceByFinanceID(int) (*entities.Finance, error)

	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	FetchAllTransaction() ([]entities.Transaction, error)
	GetTransactionByTransactionID(int) (*entities.Transaction, error)

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	FetchAllUnsettledTransactionsByUserID(int) ([]entities.Transaction, error)
	FetchAllUnpaidTransactionsWithFinanceDetailsByUserID(int) ([]entities.Transaction, error)
	FetchAllPaidTransactionHistoryByUserID(int) ([]entities.Transaction, error)
}
