package service

import (
	"fairnest/internal/entities"
	"fairnest/internal/repository"
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
