package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"github.com/gofiber/fiber/v2"
	"log"
)

type financeService struct {
	financeRepo repository.FinanceRepository
}

func NewFinanceService(financeRepo repository.FinanceRepository) financeService {
	return financeService{
		financeRepo: financeRepo,
	}
}

func (s financeService) FetchAllFinance() ([]entities.Finance, error) {
	finances, err := s.financeRepo.FetchAllFinance()
	if err != nil {
		log.Println(err)
		return nil, err
	}

	financeResponses := []entities.Finance{}
	for _, finance := range finances {
		financeResponse := entities.Finance{
			FinanceID: finance.FinanceID,
			TitleName: finance.TitleName,
			DueDate:   finance.DueDate,
			Category:  finance.Category,
			SplitType: finance.SplitType,
			CreatedAt: finance.CreatedAt,
		}
		financeResponses = append(financeResponses, financeResponse)
	}
	return financeResponses, nil
}

func (s financeService) GetFinanceByFinanceID(financeId int) (*entities.Finance, error) {
	finance, err := s.financeRepo.GetFinanceByFinanceID(financeId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if finance.FinanceID == nil &&
		finance.TitleName == nil &&
		finance.DueDate == nil &&
		finance.Category == nil &&
		finance.SplitType == nil &&
		finance.CreatedAt == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "finance data is not found")
	}

	financeResponse := entities.Finance{
		FinanceID: finance.FinanceID,
		TitleName: finance.TitleName,
		DueDate:   finance.DueDate,
		Category:  finance.Category,
		SplitType: finance.SplitType,
		CreatedAt: finance.CreatedAt,
	}
	return &financeResponse, nil
}

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

func (s financeService) FetchAllTransaction() ([]entities.Transaction, error) {
	transactions, err := s.financeRepo.FetchAllTransaction()
	if err != nil {
		log.Println(err)
		return nil, err
	}

	transactionResponses := []entities.Transaction{}
	for _, transaction := range transactions {
		transactionResponse := entities.Transaction{
			TransactionID:     transaction.TransactionID,
			FinanceID:         transaction.FinanceID,
			PayerID:           transaction.PayerID,
			DebtorID:          transaction.DebtorID,
			TotalAmount:       transaction.TotalAmount,
			TransactionStatus: transaction.TransactionStatus,
			QRCodeImage:       transaction.QRCodeImage,
			CreatedAt:         transaction.CreatedAt,
			PaidAt:            transaction.PaidAt,
		}
		transactionResponses = append(transactionResponses, transactionResponse)
	}
	return transactionResponses, nil
}

func (s financeService) GetTransactionByTransactionID(transactionID int) (*entities.Transaction, error) {
	transaction, err := s.financeRepo.GetTransactionByTransactionID(transactionID)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if transaction.TransactionID == nil &&
		transaction.FinanceID == nil &&
		transaction.PayerID == nil &&
		transaction.DebtorID == nil &&
		transaction.TotalAmount == nil &&
		transaction.TransactionStatus == nil &&
		transaction.QRCodeImage == nil &&
		transaction.CreatedAt == nil &&
		transaction.PaidAt == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "transaction data is not found")
	}

	transactionResponse := entities.Transaction{
		TransactionID:     transaction.TransactionID,
		FinanceID:         transaction.FinanceID,
		PayerID:           transaction.PayerID,
		DebtorID:          transaction.DebtorID,
		TotalAmount:       transaction.TotalAmount,
		TransactionStatus: transaction.TransactionStatus,
		QRCodeImage:       transaction.QRCodeImage,
		CreatedAt:         transaction.CreatedAt,
		PaidAt:            transaction.PaidAt,
	}
	return &transactionResponse, nil
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func (s financeService) GetMyMonthlySnapshotByUserID(userID int) (*dtos.GetMyMonthlySnapshotByUserIDResponse, error) {
	totalPaid, err := s.financeRepo.GetTotalPaidByUserIDAndMonth(userID)
	if err != nil {
		log.Printf("Error fetching total paid for user %d: %v", userID, err)
		return nil, err
	}

	totalOwedToMe, err := s.financeRepo.GetTotalOwedToUserByMonth(userID)
	if err != nil {
		log.Printf("Error fetching total owed to user %d: %v", userID, err)
		return nil, err
	}

	totalOwedByMe, err := s.financeRepo.GetTotalOwedByUserByMonth(userID)
	if err != nil {
		log.Printf("Error fetching total owed by user %d: %v", userID, err)
		return nil, err
	}

	snapshot := &dtos.GetMyMonthlySnapshotByUserIDResponse{
		TotalPaidByMe: totalPaid,
		TotalOwedToMe: totalOwedToMe,
		TotalOwedByMe: totalOwedByMe,
	}

	return snapshot, nil
}

func (s financeService) FetchAllOutstandingBalancesByUserID(currentUserID int) ([]dtos.FetchAllOutstandingBalancesByUserIDResponse, error) {
	transactions, err := s.financeRepo.FetchAllUnsettledTransactionsByUserID(currentUserID)
	if err != nil {
		log.Printf("Error fetching unsettled transactions for user %d: %v", currentUserID, err)
		return nil, err
	}

	// Map to hold the calculated net balance and user details, keyed by the other user's ID
	// A positive balance means the current user is owed. A negative balance means the current user owes.
	balancesMap := make(map[uint]*dtos.FetchAllOutstandingBalancesByUserIDResponse)

	// 1. Aggregate the net balances from all unsettled transactions
	for _, t := range transactions {
		// Identify the roommate involved in the transaction
		otherUser := getOtherUser(currentUserID, t)
		if otherUser == nil || otherUser.UserID == nil || v.IntValue(v.UintToIntPtr(otherUser.UserID)) == currentUserID {
			log.Printf("Skipping transaction %d: Invalid or self-transaction data.", t.TransactionID)
			continue
		}

		otherUserID := *otherUser.UserID
		amount := v.IntValue(t.TotalAmount)

		// Initialize the balance entry if it doesn't exist
		if _, exists := balancesMap[otherUserID]; !exists {
			balancesMap[otherUserID] = &dtos.FetchAllOutstandingBalancesByUserIDResponse{
				UserID:      otherUser.UserID,
				Username:    otherUser.Username,
				UserPicture: otherUser.UserPicture,
				NetBalance:  v.Ptr(0),
			}
		}

		// Calculate the running net balance
		currentNetBalance := v.IntValue(balancesMap[otherUserID].NetBalance)

		// If current user is Payer, the other user owes us (add to net balance)
		if v.IntValue(v.UintToIntPtr(t.PayerID)) == currentUserID {
			balancesMap[otherUserID].NetBalance = v.Ptr(currentNetBalance + amount)
		} else {
			// If current user is Debtor, we owe the other user (subtract from net balance)
			balancesMap[otherUserID].NetBalance = v.Ptr(currentNetBalance - amount)
		}
	}

	// 2. Convert the map values to a slice of DTOs and set the status
	var outstandingBalances []dtos.FetchAllOutstandingBalancesByUserIDResponse
	for _, balance := range balancesMap {
		// Only include non-zero balances
		if v.IntValue(balance.NetBalance) != 0 {
			balance.BalanceStatus = v.Ptr(getBalanceStatus(v.IntValue(balance.NetBalance)))
			outstandingBalances = append(outstandingBalances, *balance)
		}
	}

	return outstandingBalances, nil
}

func (s financeService) FetchAllUpcomingPaymentByUserID(userID int) ([]dtos.FetchAllUpcomingPaymentByUserIDResponse, error) {
	transactions, err := s.financeRepo.FetchAllUnpaidTransactionsWithFinanceDetailsByUserID(userID)
	if err != nil {
		return nil, err
	}

	var upcomingPayments []dtos.FetchAllUpcomingPaymentByUserIDResponse
	for _, transaction := range transactions {
		payment := dtos.FetchAllUpcomingPaymentByUserIDResponse{
			FinanceID:         transaction.FinanceID,
			TransactionID:     transaction.TransactionID,
			TitleName:         transaction.Finance.TitleName,
			DueDate:           v.TimePtrToRFC3339Ptr(transaction.Finance.DueDate),
			Category:          transaction.Finance.Category,
			TotalAmount:       transaction.TotalAmount,
			TransactionStatus: transaction.TransactionStatus,
			QRCodeImage:       transaction.QRCodeImage,
		}
		upcomingPayments = append(upcomingPayments, payment)
	}

	return upcomingPayments, nil
}

func (s financeService) FetchAllPaidTransactionHistoryByUserID(userID int) ([]dtos.FetchAllPaidTransactionHistoryByUserIDResponse, error) {
	transactions, err := s.financeRepo.FetchAllPaidTransactionHistoryByUserID(userID)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	var paidTransactionHistory []dtos.FetchAllPaidTransactionHistoryByUserIDResponse

	for _, transaction := range transactions {
		if transaction.Payer == nil {
			log.Printf("Payer details not found for transaction ID: %d", *transaction.TransactionID)
			continue
		}

		historyItem := dtos.FetchAllPaidTransactionHistoryByUserIDResponse{
			FinanceID:         transaction.FinanceID,
			TransactionID:     transaction.TransactionID,
			TitleName:         transaction.Finance.TitleName,
			Category:          transaction.Finance.Category,
			TotalAmount:       transaction.TotalAmount,
			TransactionStatus: transaction.TransactionStatus,
			PaidAt:            v.TimePtrToRFC3339Ptr(transaction.PaidAt),

			// Paid to User Details
			PaidToUserID:      transaction.PayerID,
			PaidToUsername:    transaction.Payer.Username,
			PaidToUserPicture: transaction.Payer.UserPicture,
		}
		paidTransactionHistory = append(paidTransactionHistory, historyItem)
	}

	return paidTransactionHistory, nil
}

// ----------------------------------------- Private Helper Functions -----------------------------------------//
// Helper function to determine the balance status string
func getBalanceStatus(balance int) string {
	if balance > 0 {
		return "You Are Owed" // The current user is owed a positive amount (money coming in)
	} else if balance < 0 {
		return "You Owe" // The current user owes a negative amount (money going out)
	}
	return "Settled"
}

// Helper function to get the User object for the "other" person in the transaction
func getOtherUser(currentUserID int, t entities.Transaction) *entities.User {
	if v.UintToIntPtr(t.PayerID) != nil && v.IntValue(v.UintToIntPtr(t.PayerID)) == currentUserID {
		// Current user is Payer, the other user is the Debtor
		return t.Debtor
	}
	// Current user is Debtor, the other user is the Payer
	return t.Payer
}
