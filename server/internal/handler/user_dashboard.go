package handler

import (
	"fairnest/internal/service"
	"fairnest/internal/utils"
	"strings"

	"github.com/gofiber/fiber/v2"
)

type userDashboardHandler struct {
	userDashboardSer service.UserDashboardService
	jwtSecret        string
}

func NewUserDashboardHandler(userDashboardSer service.UserDashboardService, jwtSecret string) userDashboardHandler {
	return userDashboardHandler{
		userDashboardSer: userDashboardSer,
		jwtSecret:        jwtSecret,
	}
}

// GetUserDashboard godoc
// @Summary Get user dashboard data
// @Description Get personal dashboard data including progress and task summary for current user
// @Tags Dashboard
// @Accept json
// @Produce json
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} dtos.GetUserDashboardResponse
// @Failure 401 {object} map[string]string "Unauthorized"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /user/dashboard [get]
func (h *userDashboardHandler) GetUserDashboard(c *fiber.Ctx) error {
	// Extract user ID from JWT token
	token := c.Get("Authorization")
	if token == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "missing authorization token",
		})
	}

	userID, err := utils.ExtractUserIDFromToken(strings.Replace(token, "Bearer ", "", 1), h.jwtSecret)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "invalid token",
		})
	}

	// Get dashboard data for current user
	dashboard, err := h.userDashboardSer.GetUserDashboard(uint(userID))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(dashboard)
}
