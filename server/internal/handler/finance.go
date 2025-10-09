package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"fairnest/internal/utils/v"
	"github.com/gofiber/fiber/v2"
	"strconv"
)

type financeHandler struct {
	financeSer service.FinanceService
}

func NewFinanceHandler(financeSer service.FinanceService) financeHandler {
	return financeHandler{financeSer: financeSer}
}

func (h *financeHandler) FetchAllFinance(c *fiber.Ctx) error {
	financesResponse := make([]dtos.FinanceDataResponse, 0)

	finances, err := h.financeSer.FetchAllFinance()
	if err != nil {
		return err
	}

	for _, finance := range finances {
		financesResponse = append(financesResponse, dtos.FinanceDataResponse{
			FinanceID: finance.FinanceID,
			TitleName: finance.TitleName,
			DueDate:   v.TimePtrToRFC3339Ptr(finance.DueDate),
			Category:  finance.Category,
			SplitType: finance.SplitType,
			CreatedAt: v.TimePtrToRFC3339Ptr(finance.CreatedAt),
		})
	}
	return c.JSON(financesResponse)
}

func (h *financeHandler) GetFinanceByFinanceID(c *fiber.Ctx) error {
	financeIDReceive, err := strconv.Atoi(c.Params("FinanceID"))

	finance, err := h.financeSer.GetFinanceByFinanceID(financeIDReceive)
	if err != nil {
		return err
	}

	financeResponse := dtos.FinanceByFinanceIDDataResponse{
		FinanceID: finance.FinanceID,
		TitleName: finance.TitleName,
		DueDate:   v.TimePtrToRFC3339Ptr(finance.DueDate),
		Category:  finance.Category,
		SplitType: finance.SplitType,
		CreatedAt: v.TimePtrToRFC3339Ptr(finance.CreatedAt),
	}

	return c.JSON(financeResponse)
}

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

func (h *financeHandler) FetchAllTransaction(c *fiber.Ctx) error {
	transactionsResponse := make([]dtos.TransactionDataResponse, 0)

	transactions, err := h.financeSer.FetchAllTransaction()
	if err != nil {
		return err
	}

	for _, transaction := range transactions {
		transactionsResponse = append(transactionsResponse, dtos.TransactionDataResponse{
			TransactionID:     transaction.TransactionID,
			FinanceID:         transaction.FinanceID,
			PayerID:           transaction.PayerID,
			DebtorID:          transaction.DebtorID,
			TotalAmount:       transaction.TotalAmount,
			TransactionStatus: transaction.TransactionStatus,
			QRCodeImage:       transaction.QRCodeImage,
			CreatedAt:         v.TimePtrToRFC3339Ptr(transaction.CreatedAt),
			PaidAt:            v.TimePtrToRFC3339Ptr(transaction.PaidAt),
		})
	}
	return c.JSON(transactionsResponse)
}

func (h *financeHandler) GetTransactionByTransactionID(c *fiber.Ctx) error {
	transactionIDReceive, err := strconv.Atoi(c.Params("TransactionID"))

	transaction, err := h.financeSer.GetTransactionByTransactionID(transactionIDReceive)
	if err != nil {
		return err
	}

	transactionResponse := dtos.TransactionByTransactionIDDataResponse{
		TransactionID:     transaction.TransactionID,
		FinanceID:         transaction.FinanceID,
		PayerID:           transaction.PayerID,
		DebtorID:          transaction.DebtorID,
		TotalAmount:       transaction.TotalAmount,
		TransactionStatus: transaction.TransactionStatus,
		QRCodeImage:       transaction.QRCodeImage,
		CreatedAt:         v.TimePtrToRFC3339Ptr(transaction.CreatedAt),
		PaidAt:            v.TimePtrToRFC3339Ptr(transaction.PaidAt),
	}

	return c.JSON(transactionResponse)
}
