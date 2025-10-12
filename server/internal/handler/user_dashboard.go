package handler

import (
	"fairnest/internal/service"
	"fairnest/internal/utils"
	"strings"

	"github.com/gofiber/fiber/v2"
)

type userDashboardSplitHandler struct {
	service   service.UserDashboardService
	jwtSecret string
}

func NewUserDashboardSplitHandler(service service.UserDashboardService, jwtSecret string) userDashboardSplitHandler {
	return userDashboardSplitHandler{
		service:   service,
		jwtSecret: jwtSecret,
	}
}

// 1. GET /user/progress - Get user's progress data
func (h *userDashboardSplitHandler) GetUserProgress(c *fiber.Ctx) error {
	userID, err := h.extractUserID(c)
	if err != nil {
		return err
	}

	progress, err := h.service.GetUserProgress(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(progress)
}

// 2. GET /user/tasks/today - Get today's unfinished tasks and payments (SEPARATED)
func (h *userDashboardSplitHandler) GetUserTasksToday(c *fiber.Ctx) error {
	userID, err := h.extractUserID(c)
	if err != nil {
		return err
	}

	tasks, err := h.service.GetUserTasksToday(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(tasks)
}

// 3. GET /user/tasks/completed - Get completed tasks and payments from today (SEPARATED)
func (h *userDashboardSplitHandler) GetUserTasksCompleted(c *fiber.Ctx) error {
	userID, err := h.extractUserID(c)
	if err != nil {
		return err
	}

	tasks, err := h.service.GetUserTasksCompleted(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(tasks)
}

// 4. GET /user/tasks/upcoming - Get upcoming unfinished tasks and payments (next 7 days) (SEPARATED)
func (h *userDashboardSplitHandler) GetUserTasksUpcoming(c *fiber.Ctx) error {
	userID, err := h.extractUserID(c)
	if err != nil {
		return err
	}

	tasks, err := h.service.GetUserTasksUpcoming(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(tasks)
}

// Helper to extract user ID from JWT token
func (h *userDashboardSplitHandler) extractUserID(c *fiber.Ctx) (uint, error) {
	token := c.Get("Authorization")
	if token == "" {
		return 0, c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "missing authorization token",
		})
	}

	userID, err := utils.ExtractUserIDFromToken(strings.Replace(token, "Bearer ", "", 1), h.jwtSecret)
	if err != nil {
		return 0, c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "invalid token",
		})
	}

	return uint(userID), nil
}
