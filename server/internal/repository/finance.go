package repository

import "fairnest/internal/entities"

type FinanceRepository interface {
	FetchAllFinance() ([]entities.Finance, error)
	GetFinanceByFinanceID(int) (*entities.Finance, error)

	//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
	FetchAllTransaction() ([]entities.Transaction, error)
	GetTransactionByTransactionID(int) (*entities.Transaction, error)

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	GetTotalPaidByUserIDAndMonth(userID int) (*int, error) // PayerID=UserID, Status=true
	GetTotalOwedToUserByMonth(userID int) (*int, error)    // PayerID=UserID, Status=false
	GetTotalOwedByUserByMonth(userID int) (*int, error)    // DebtorID=UserID, Status=false

	FetchAllUnsettledTransactionsByUserID(int) ([]entities.Transaction, error)
	FetchAllUnpaidTransactionsWithFinanceDetailsByUserID(int) ([]entities.Transaction, error)
	FetchAllPaidTransactionHistoryByUserID(int) ([]entities.Transaction, error)

	CreateFinanceByPayerID(finance *entities.Finance, transactions []entities.Transaction) error

	FetchAllOverdueTransactions() ([]entities.Transaction, error)
	SetOverduePenalty(transactionID uint) error
}
