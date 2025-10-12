package service

import (
	"encoding/base64"
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"github.com/stripe/stripe-go/v83"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/skip2/go-qrcode"
)

type financeService struct {
	financeRepo   repository.FinanceRepository
	userSer       UserService
	stripeService StripeService
}

func NewFinanceService(financeRepo repository.FinanceRepository, userSer UserService, stripeService StripeService) financeService {
	return financeService{
		financeRepo:   financeRepo,
		userSer:       userSer,
		stripeService: stripeService,
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
			QRCodeLinkImage:   transaction.QRCodeLinkImage,
			PaymentLink:       transaction.PaymentLink,
			OverduePenalty:    transaction.OverduePenalty,
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
		transaction.PaymentLink == nil &&
		transaction.QRCodeLinkImage == nil &&
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
		QRCodeLinkImage:   transaction.QRCodeLinkImage,
		PaymentLink:       transaction.PaymentLink,
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

	// Check and apply overdue penalties if any
	err = s.CheckOverduePenalty()
	if err != nil {
		log.Printf("Error checking overdue penalties: %v", err)
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
			QRCodeLinkImage:   transaction.QRCodeLinkImage,
			PaymentLink:       transaction.PaymentLink,
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

func (s financeService) CreateFinanceByPayerID(payerID int, req *dtos.CreateFinanceByPayerIDRequest) (*dtos.CreateFinanceByPayerIDResponse, error) {
	dueDate, err := time.Parse(time.RFC3339, *req.DueDate)
	if err != nil {
		log.Printf("Error parsing due_date: %v", err)
		return nil, fiber.NewError(fiber.StatusBadRequest, "Invalid due_date format. Must be RFC3339 (e.g., 2025-10-10T12:00:00Z)")
	}

	// 1. Prepare the Finance and Transaction entities
	finance := &entities.Finance{
		TitleName: req.TitleName,
		DueDate:   &dueDate,
		Category:  req.Category,
		SplitType: req.SplitType,
	}

	transactions := make([]entities.Transaction, len(req.Transactions))
	for i, tReq := range req.Transactions {
		transactions[i] = entities.Transaction{
			PayerID:           v.Ptr(uint(payerID)),
			DebtorID:          tReq.DebtorID,
			TotalAmount:       tReq.TotalAmount,
			TransactionStatus: v.Ptr(false),
			OverduePenalty:    v.Ptr(false),
		}
	}

	// 2. Create the finance and all transactions in a single database transaction.
	// The transaction IDs will be populated in the `transactions` slice after this call.
	if err := s.financeRepo.CreateFinanceByPayerID(finance, transactions); err != nil {
		log.Printf("Error creating finance and transactions in repository: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to create finance record")
	}

	// 3. Now, iterate through the transactions (which now have their IDs)
	// to generate payment links and QR codes.
	responseTransactions := make([]dtos.CreatedTransactionResponse, len(transactions))
	for i, t := range transactions {
		// Use the newly populated transaction ID to create the payment link.
		paymentLinkURL, err := s.stripeService.CreatePaymentLink(*req.TitleName, *t.TotalAmount*100, int(*t.TransactionID))
		if err != nil {
			log.Printf("Failed to create Stripe Payment Link for transaction %d: %v", *t.TransactionID, err)
			return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to create payment link")
		}

		// Generate QR code image from the payment link URL.
		qrCode, err := qrcode.New(paymentLinkURL, qrcode.Medium)
		if err != nil {
			log.Printf("Failed to generate QR code: %v", err)
			return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to generate QR code")
		}

		qrBytes, err := qrCode.PNG(256)
		if err != nil {
			log.Printf("Failed to encode QR code to PNG: %v", err)
			return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to encode QR code to PNG")
		}

		qrBase64 := "data:image/png;base64," + base64.StdEncoding.EncodeToString(qrBytes)

		// Update the transaction record with the payment link and QR code image.
		addPaymentInfo := &entities.Transaction{
			TransactionID:   t.TransactionID,
			PaymentLink:     v.Ptr(paymentLinkURL),
			QRCodeLinkImage: v.Ptr(qrBase64),
		}

		if err := s.financeRepo.PatchAddPaymentLinkAndQRCodeByTransactionID(addPaymentInfo); err != nil {
			log.Printf("Failed to update transaction %d with payment info: %v", *t.TransactionID, err)
			return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to update transaction with payment info")
		}

		responseTransactions[i] = dtos.CreatedTransactionResponse{
			TransactionID:     t.TransactionID,
			DebtorID:          t.DebtorID,
			PayerID:           t.PayerID,
			TotalAmount:       t.TotalAmount,
			TransactionStatus: t.TransactionStatus,
			QRCodeLinkImage:   v.Ptr(qrBase64),
			PaymentLink:       v.Ptr(paymentLinkURL),
			CreatedAt:         v.TimePtrToRFC3339Ptr(t.CreatedAt),
		}
	}

	return &dtos.CreateFinanceByPayerIDResponse{
		FinanceID:    finance.FinanceID,
		TitleName:    finance.TitleName,
		DueDate:      v.Ptr(finance.DueDate.Format(time.RFC3339)),
		Category:     finance.Category,
		SplitType:    finance.SplitType,
		CreatedAt:    v.Ptr(finance.CreatedAt.Format(time.RFC3339)),
		Transactions: responseTransactions,
	}, nil
}

func (s financeService) FetchAllOverdueTransactions() ([]entities.Transaction, error) {
	transactions, err := s.financeRepo.FetchAllOverdueTransactions()
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
			QRCodeLinkImage:   transaction.QRCodeLinkImage,
			PaymentLink:       transaction.PaymentLink,
			OverduePenalty:    transaction.OverduePenalty,
			CreatedAt:         transaction.CreatedAt,
			PaidAt:            transaction.PaidAt,
		}
		transactionResponses = append(transactionResponses, transactionResponse)
	}
	return transactionResponses, nil
}

func (s financeService) CheckOverduePenalty() error {
	// Find all transactions that are overdue and haven't been penalized yet
	overdueTransactions, err := s.financeRepo.FetchAllOverdueTransactions()
	if err != nil {
		log.Printf("Error fetching overdue transactions: %v", err)
		return err
	}

	if len(overdueTransactions) == 0 {
		log.Println("No overdue transactions to penalize.")
		return nil
	}

	for _, transaction := range overdueTransactions {
		// Check if the transaction's due date is in the past
		// The query already handles this, but a double-check is good practice.
		if transaction.Finance != nil && transaction.Finance.DueDate.Before(time.Now()) {
			// Get the current roommate score of the debtor
			debtorID := *transaction.DebtorID

			// Deduct 10 points from the score
			DeductScore := 10.0

			// Update the user's roommate score in the database
			if _, err := s.userSer.UpdateRoommateScorePenalty(debtorID, DeductScore); err != nil {
				log.Printf("Error updating roommate score for user %d: %v", debtorID, err)
				continue
			}

			currentScore, err := s.userSer.GetCurrentRoommateScore(debtorID)
			if err != nil {
				log.Printf("Error fetching roommate score for user %d: %v", debtorID, err)
				continue // Skip to the next transaction
			}

			// Mark the transaction as penalized to prevent future deductions
			if err := s.financeRepo.SetOverduePenalty(*transaction.TransactionID); err != nil {
				log.Printf("Error setting overdue penalty for transaction %d: %v", *transaction.TransactionID, err)
				// Continue even on error to ensure other penalties are applied
			}
			log.Printf("Applied 10-point penalty to user %d for overdue transaction %d. New score: %.2f", debtorID, *transaction.TransactionID, *currentScore)
		}
	}

	return nil
}

func (s financeService) PatchPaidByTransactionID(transactionID int) (*entities.Transaction, error) {
	finance := &entities.Transaction{
		TransactionID:     v.UintPtr(transactionID),
		TransactionStatus: v.Ptr(true), // Mark as paid
		PaidAt:            v.Ptr(time.Now()),
	}

	err := s.financeRepo.UpdateTransactionStatusPaid(finance)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	return finance, nil
}

// GetPaymentIntentByTransactionID retrieves the PaymentIntent object from Stripe using the custom
// transaction_id stored in the metadata.
func (s financeService) GetPaymentStatusByTransactionID(transactionID int) (*stripe.PaymentIntent, error) {
	pi, err := s.stripeService.SearchPaymentStatusByTransactionID(transactionID)
	if err != nil {
		// Log the underlying error from the Stripe service
		log.Printf("Error searching Stripe PaymentStatus for transaction %d: %v", transactionID, err)

		// Return a Fiber error to be handled by the API controller.
		// The underlying Stripe error should contain details about whether it was 'not found'.
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to retrieve payment status from Stripe (Not Found or other error)")
	}

	if pi == nil {
		// This case is typically covered by the Stripe service returning a specific error,
		// but serves as a safeguard.
		return nil, fiber.NewError(fiber.StatusNotFound, "Payment status not found for this transaction ID")
	}

	if pi.Status == "succeeded" {
		log.Printf("PaymentStatus for transaction %d has already succeeded.", transactionID)
		_, err := s.PatchPaidByTransactionID(transactionID)
		if err != nil {
			log.Printf("Failed to update transaction %d as paid: %v", transactionID, err)
			return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to update transaction status")
		}
	} else {
		log.Printf("PaymentStatus for transaction %d found with status: %s", transactionID, pi.Status)
	}

	return pi, nil
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
