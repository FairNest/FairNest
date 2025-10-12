package handler

import (
	"fairnest/internal/service"
	"fairnest/internal/utils"
	"strconv"
	"strings"

	"github.com/gofiber/fiber/v2"
)

type dashboardHandler struct {
	dashboardSer service.DashboardService
	jwtSecret    string
}

func NewDashboardHandler(dashboardSer service.DashboardService, jwtSecret string) dashboardHandler {
	return dashboardHandler{
		dashboardSer: dashboardSer,
		jwtSecret:    jwtSecret,
	}
}

// GetRoomDashboard godoc
// @Summary Get room dashboard data
// @Description Get comprehensive dashboard data including room status and roommate overview
// @Tags Dashboard
// @Accept json
// @Produce json
// @Param roomID path int true "Room ID"
// @Param Authorization header string true "Bearer token"
// @Success 200 {object} dtos.GetRoomDashboardResponse
// @Failure 400 {object} map[string]string "Invalid room ID"
// @Failure 401 {object} map[string]string "Unauthorized"
// @Failure 500 {object} map[string]string "Internal server error"
// @Router /rooms/{roomID}/dashboard [get]
func (h *dashboardHandler) GetRoomDashboard(c *fiber.Ctx) error {
	// Parse room ID from path parameter
	roomID, err := strconv.ParseUint(c.Params("roomID"), 10, 32)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid room id",
		})
	}

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

	// Get dashboard data
	dashboard, err := h.dashboardSer.GetRoomDashboard(uint(roomID), uint(userID))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(dashboard)
}
