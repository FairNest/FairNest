package service

import (
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"log"
)

type choreService struct {
	choreRepo repository.ChoreRepository
}

func NewChoreService(choreRepo repository.ChoreRepository) choreService {
	return choreService{
		choreRepo: choreRepo,
	}
}

func (s choreService) FetchAllChore() ([]entities.Chore, error) {
	chores, err := s.choreRepo.FetchAllChore()
	if err != nil {
		log.Println(err)
		return nil, err
	}

	choreResponses := []entities.Chore{}
	for _, chore := range chores {
		choreResponse := entities.Chore{
			ChoreID:           chore.ChoreID,
			RoomID:            chore.RoomID,
			ChoreTitle:        chore.ChoreTitle,
			ChoreDescription:  chore.ChoreDescription,
			Category:          chore.Category,
			DueDayOfWeek:      chore.DueDayOfWeek,
			DueTime:           chore.DueTime,
			ReminderDayOfWeek: chore.ReminderDayOfWeek,
			ReminderTime:      chore.ReminderTime,
			Recurrence:        chore.Recurrence,
			AutoRotate:        chore.AutoRotate,
			ChoreScore:        chore.ChoreScore,
			CreatedAt:         chore.CreatedAt,
			UpdatedAt:         chore.UpdatedAt,
		}
		choreResponses = append(choreResponses, choreResponse)
	}
	return choreResponses, nil
}
