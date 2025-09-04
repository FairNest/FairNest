package service

import (
	"fairnest/internal/utils/v"
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

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

func (s lifestyleService) GetUserLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyle, err := s.lifestyleRepo.GetUserLifestyleByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if lifestyle.LifestyleID == nil &&
		lifestyle.UserID == nil &&
		lifestyle.UserTidiness == nil &&
		lifestyle.UserNoiseActivity == nil &&
		lifestyle.UserSchedule == nil &&
		lifestyle.UserGuestFrequency == nil &&
		lifestyle.UserTaskStructure == nil &&
		lifestyle.UserMoneyAttitude == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user lifestyle data is not found")
	}

	lifestyleResponse := entities.Lifestyle{
		LifestyleID:        lifestyle.LifestyleID,
		UserID:             lifestyle.UserID,
		UserTidiness:       lifestyle.UserTidiness,
		UserNoiseActivity:  lifestyle.UserNoiseActivity,
		UserSchedule:       lifestyle.UserSchedule,
		UserGuestFrequency: lifestyle.UserGuestFrequency,
		UserTaskStructure:  lifestyle.UserTaskStructure,
		UserMoneyAttitude:  lifestyle.UserMoneyAttitude,
	}
	return &lifestyleResponse, nil
}

func (s lifestyleService) CreateLifestyleByUserId(userId int, request *entities.Lifestyle) (*entities.Lifestyle, error) {
	lifestyle := entities.Lifestyle{
		UserID:             v.UintPtr(userId),
		Q1:                 request.Q1,
		Q2:                 request.Q2,
		Q3:                 request.Q3,
		Q4:                 request.Q4,
		Q5:                 request.Q5,
		Q6:                 request.Q6,
		Q7:                 request.Q7,
		Q8:                 request.Q8,
		Q9:                 request.Q9,
		Q10:                request.Q10,
		Q11:                request.Q11,
		Q12:                request.Q12,
		UserTidiness:       request.UserTidiness,
		UserNoiseActivity:  request.UserNoiseActivity,
		UserSchedule:       request.UserSchedule,
		UserGuestFrequency: request.UserGuestFrequency,
		UserTaskStructure:  request.UserTaskStructure,
		UserMoneyAttitude:  request.UserMoneyAttitude,
	}

	if err := s.lifestyleRepo.CreateLifestyleByUserId(&lifestyle); err != nil {
		return nil, err
	}

	return &entities.Lifestyle{
		UserID:             v.UintPtr(userId),
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
	}, nil
}

func (s lifestyleService) GetUserOverallLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyle, err := s.lifestyleRepo.GetUserOverallLifestyleByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if lifestyle.LifestyleID == nil &&
		lifestyle.UserID == nil &&
		lifestyle.UserTidiness == nil &&
		lifestyle.UserNoiseActivity == nil &&
		lifestyle.UserSchedule == nil &&
		lifestyle.UserGuestFrequency == nil &&
		lifestyle.UserTaskStructure == nil &&
		lifestyle.UserMoneyAttitude == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user overall lifestyle data is not found")
	}

	lifestyleResponse := entities.Lifestyle{
		LifestyleID:        lifestyle.LifestyleID,
		UserID:             lifestyle.UserID,
		UserTidiness:       lifestyle.UserTidiness,
		UserNoiseActivity:  lifestyle.UserNoiseActivity,
		UserSchedule:       lifestyle.UserSchedule,
		UserGuestFrequency: lifestyle.UserGuestFrequency,
		UserTaskStructure:  lifestyle.UserTaskStructure,
		UserMoneyAttitude:  lifestyle.UserMoneyAttitude,
	}
	return &lifestyleResponse, nil
}
