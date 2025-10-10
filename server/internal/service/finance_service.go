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
