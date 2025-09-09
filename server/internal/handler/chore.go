package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"fairnest/internal/utils/v"
	"github.com/gofiber/fiber/v2"
)

type choreHandler struct {
	choreSer service.ChoreService
}

func NewChoreHandler(choreSer service.ChoreService) choreHandler {
	return choreHandler{choreSer: choreSer}
}

func (h *choreHandler) FetchAllChore(c *fiber.Ctx) error {
	choresResponse := make([]dtos.ChoreDataResponse, 0)

	chores, err := h.choreSer.FetchAllChore()
	if err != nil {
		return err
	}

	for _, chore := range chores {
		choresResponse = append(choresResponse, dtos.ChoreDataResponse{
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
			CreatedAt:         v.TimePtrToRFC3339Ptr(chore.CreatedAt),
			UpdatedAt:         v.TimePtrToRFC3339Ptr(chore.UpdatedAt),
		})
	}
	return c.JSON(choresResponse)
}
