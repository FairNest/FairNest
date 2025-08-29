package service

import (
	"log"

	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"github.com/gofiber/fiber/v2"
)

type lifestyleService struct {
	lifestyleRepo repository.LifestyleRepository
}

func NewLifestyleService(lifestyleRepo repository.LifestyleRepository) lifestyleService {
	return lifestyleService{
		lifestyleRepo: lifestyleRepo,
	}
}

func (s lifestyleService) GetLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyle, err := s.lifestyleRepo.GetLifestyleByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if lifestyle.LifestyleID == nil &&
		lifestyle.UserID == nil &&
		lifestyle.Q1 == nil &&
		lifestyle.Q2 == nil &&
		lifestyle.Q3 == nil &&
		lifestyle.Q4 == nil &&
		lifestyle.Q5 == nil &&
		lifestyle.Q6 == nil &&
		lifestyle.Q7 == nil &&
		lifestyle.Q8 == nil &&
		lifestyle.Q9 == nil &&
		lifestyle.Q10 == nil &&
		lifestyle.Q11 == nil &&
		lifestyle.Q12 == nil &&
		lifestyle.UserTidiness == nil &&
		lifestyle.UserNoiseActivity == nil &&
		lifestyle.UserSchedule == nil &&
		lifestyle.UserGuestFrequency == nil &&
		lifestyle.UserTaskStructure == nil &&
		lifestyle.UserMoneyAttitude == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "lifestyle data is not found")
	}

	lifestyleResponse := entities.Lifestyle{
		LifestyleID:        lifestyle.LifestyleID,
		UserID:             lifestyle.UserID,
		Q1:                 lifestyle.Q1,
		Q2:                 lifestyle.Q2,
		Q3:                 lifestyle.Q3,
		Q4:                 lifestyle.Q4,
		Q5:                 lifestyle.Q5,
		Q6:                 lifestyle.Q6,
		Q7:                 lifestyle.Q7,
		Q8:                 lifestyle.Q8,
		Q9:                 lifestyle.Q9,
		Q10:                lifestyle.Q10,
		Q11:                lifestyle.Q11,
		Q12:                lifestyle.Q12,
		UserTidiness:       lifestyle.UserTidiness,
		UserNoiseActivity:  lifestyle.UserNoiseActivity,
		UserSchedule:       lifestyle.UserSchedule,
		UserGuestFrequency: lifestyle.UserGuestFrequency,
		UserTaskStructure:  lifestyle.UserTaskStructure,
		UserMoneyAttitude:  lifestyle.UserMoneyAttitude,
	}
	return &lifestyleResponse, nil
}
