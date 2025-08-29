package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"github.com/gofiber/fiber/v2"
	"strconv"
)

type lifestyleHandler struct {
	lifestyleSer service.LifestyleService
}

func NewLifestyleHandler(lifestyleSer service.LifestyleService) lifestyleHandler {
	return lifestyleHandler{lifestyleSer: lifestyleSer}
}

func (h *lifestyleHandler) GetLifestyleByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	lifestyle, err := h.lifestyleSer.GetLifestyleByUserId(userIDReceive)
	if err != nil {
		return err
	}

	lifestyleResponse := dtos.LifestyleByUserIdResponse{
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

	return c.JSON(lifestyleResponse)
}
