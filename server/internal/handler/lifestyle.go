package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/repository"
	"fairnest/internal/service"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

type lifestyleHandler struct {
	lifestyleSer  service.LifestyleService
	lifestyleRepo repository.LifestyleRepository
}

func NewLifestyleHandler(lifestyleSer service.LifestyleService, lifestyleRepo repository.LifestyleRepository) lifestyleHandler {
	return lifestyleHandler{
		lifestyleSer:  lifestyleSer,
		lifestyleRepo: lifestyleRepo,
	}
}

func (h *lifestyleHandler) GetLifestyleByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid UserID")
	}

	lifestyle, err := h.lifestyleSer.GetLifestyleByUserId(userIDReceive)
	if err != nil {
		return err
	}

	lifestyleResponse := dtos.GetLifestyleByUserIdResponse{
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

func (h *lifestyleHandler) GetUserOverallLifestyleByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid UserID")
	}

	lifestyle, err := h.lifestyleSer.GetUserOverallLifestyleByUserId(userIDReceive)
	if err != nil {
		return err
	}

	lifestyleResponse := dtos.GetUserOverallLifestyleByUserIdResponse{
		LifestyleID:        lifestyle.LifestyleID,
		UserID:             lifestyle.UserID,
		UserTidiness:       lifestyle.UserTidiness,
		UserNoiseActivity:  lifestyle.UserNoiseActivity,
		UserSchedule:       lifestyle.UserSchedule,
		UserGuestFrequency: lifestyle.UserGuestFrequency,
		UserTaskStructure:  lifestyle.UserTaskStructure,
		UserMoneyAttitude:  lifestyle.UserMoneyAttitude,
	}

	return c.JSON(lifestyleResponse)
}

func (h lifestyleHandler) GetRoomAverageCompatibilityByRoomId(c *fiber.Ctx) error {
	roomIdStr := c.Params("RoomID")
	roomId, err := strconv.Atoi(roomIdStr)
	if err != nil || roomId <= 0 {
		return fiber.NewError(fiber.StatusBadRequest, "invalid RoomID")
	}

	// Get compatibility scores from service
	avgPct, best, worst, err := h.lifestyleSer.GetRoomAverageCompatibilityByRoomId(roomId)
	if err != nil {
		if fe, ok := err.(*fiber.Error); ok {
			return c.Status(fe.Code).JSON(fiber.Map{"error": fe.Message})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	// Get user names for the pairs
	users, err := h.lifestyleRepo.GetUsersInRoom(roomId)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	// Helper function to get username by ID
	getName := func(uid uint) string {
		for _, u := range users {
			if u != nil && u.UserID != nil && uint(*u.UserID) == uid && u.Username != nil {
				return *u.Username
			}
		}
		return ""
	}

	// Build response
	resp := dtos.RoomCompatibilitySummaryResponse{
		Score: avgPct,
		BestMatched: dtos.CompatibilityPair{
			UserAID:   best.UserAID,
			UserAName: getName(best.UserAID),
			UserBID:   best.UserBID,
			UserBName: getName(best.UserBID),
			Score:     best.ScorePct,
		},
		MostDivergent: dtos.CompatibilityPair{
			UserAID:   worst.UserAID,
			UserAName: getName(worst.UserAID),
			UserBID:   worst.UserBID,
			UserBName: getName(worst.UserBID),
			Score:     worst.ScorePct,
		},
	}

	return c.JSON(resp)
}

func (h lifestyleHandler) GetCompatibilityMatchesByRoomAndUser(c *fiber.Ctx) error {
	roomIdStr := c.Params("RoomID")
	userIdStr := c.Params("UserID")

	roomId, err := strconv.Atoi(roomIdStr)
	if err != nil || roomId <= 0 {
		return fiber.NewError(fiber.StatusBadRequest, "invalid RoomID")
	}
	userId, err := strconv.Atoi(userIdStr)
	if err != nil || userId <= 0 {
		return fiber.NewError(fiber.StatusBadRequest, "invalid UserID")
	}

	resp, err := h.lifestyleSer.GetCompatibilityMatchesByRoomAndUser(roomId, userId)
	if err != nil {
		if fe, ok := err.(*fiber.Error); ok {
			return c.Status(fe.Code).JSON(fiber.Map{"error": fe.Message})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(resp)
}
