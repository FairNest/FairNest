package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"fairnest/internal/utils"
	"fairnest/internal/utils/v"
	"strconv"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
)

type choreHandler struct {
	choreSer  service.ChoreService
	jwtSecret string
}

func NewChoreHandler(choreSer service.ChoreService, jwtSecret string) choreHandler {
	return choreHandler{choreSer: choreSer, jwtSecret: jwtSecret}
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
			CreatedAt:         v.Ptr(chore.CreatedAt),
			UpdatedAt:         v.Ptr(chore.UpdatedAt),
		})
	}
	return c.JSON(choresResponse)
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// * create new chore
func (h *choreHandler) CreateChore(c *fiber.Ctx) error {
	roomID, err := strconv.ParseUint(c.Params("roomID"), 10, 32)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid room id",
		})
	}

	var request *dtos.CreateChoreRequest
	if err := c.BodyParser(&request); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid request body",
		})
	}

	response, err := h.choreSer.CreateChore(uint(roomID), request)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(response)
}

// * get all chores for room
func (h *choreHandler) GetChoresByRoomID(c *fiber.Ctx) error {
	roomID, err := strconv.ParseUint(c.Params("roomID"), 10, 32)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid room id",
		})
	}

	chores, err := h.choreSer.GetChoresByRoomID(uint(roomID))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(chores)
}

// * get calendar view of chores
func (h *choreHandler) GetChoreCalendar(c *fiber.Ctx) error {
	roomID, err := strconv.ParseUint(c.Params("roomID"), 10, 32)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid room id",
		})
	}

	// * parse date range from query params
	startDateStr := c.Query("start_date")
	endDateStr := c.Query("end_date")

	var startDate, endDate time.Time
	if startDateStr != "" {
		startDate, err = time.Parse("2006-01-02", startDateStr)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "invalid start_date format, use YYYY-MM-DD",
			})
		}
	} else {
		// * default to start of current month
		now := time.Now()
		startDate = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	}

	if endDateStr != "" {
		endDate, err = time.Parse("2006-01-02", endDateStr)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "invalid end_date format, use YYYY-MM-DD",
			})
		}
	} else {
		// * default to end of current month
		startDate = time.Date(startDate.Year(), startDate.Month(), 1, 0, 0, 0, 0, startDate.Location())
		endDate = startDate.AddDate(0, 1, -1) // * last day of current month
	}

	calendar, err := h.choreSer.GetChoreCalendar(uint(roomID), startDate, endDate)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(calendar)
}

// * get today's chores
func (h *choreHandler) GetTodayChores(c *fiber.Ctx) error {
	roomID, err := strconv.ParseUint(c.Params("roomID"), 10, 32)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid room id",
		})
	}

	// * extract user id from jwt token
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

	chores, err := h.choreSer.GetTodayChores(uint(roomID), uint(userID))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(chores)
}

// * mark chore as completed
func (h *choreHandler) MarkChoreComplete(c *fiber.Ctx) error {
	// * extract user id from jwt token
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

	var request dtos.MarkChoreCompleteRequest
	if err := c.BodyParser(&request); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid request body",
		})
	}

	if request.ChoreAssignmentID == nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "chore_assignment_id is required",
		})
	}

	response, err := h.choreSer.MarkChoreComplete(uint(userID), *request.ChoreAssignmentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(response)
}

// * update chore
func (h *choreHandler) UpdateChore(c *fiber.Ctx) error {
	choreID, err := strconv.ParseUint(c.Params("choreID"), 10, 32)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid chore id",
		})
	}

	var request *dtos.EditChoreRequest
	if err := c.BodyParser(&request); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid request body",
		})
	}

	response, err := h.choreSer.UpdateChore(uint(choreID), request)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(response)
}

// * delete chore
func (h *choreHandler) DeleteChore(c *fiber.Ctx) error {
	choreID, err := strconv.ParseUint(c.Params("choreID"), 10, 32)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid chore id",
		})
	}

	err = h.choreSer.DeleteChore(uint(choreID))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(dtos.DeleteChoreResponse{
		Message: v.Ptr("chore deleted successfully"),
		ChoreID: v.Ptr(uint(choreID)),
	})
}

func (h choreHandler) GetRoomTasksForDate(c *fiber.Ctx) error {
	roomID, err := strconv.Atoi(c.Params("roomID"))
	if err != nil || roomID <= 0 {
		return fiber.NewError(fiber.StatusBadRequest, "invalid room id")
	}

	dateStr := c.Query("date")
	if dateStr == "" {
		return fiber.NewError(fiber.StatusBadRequest, "date is required (YYYY-MM-DD)")
	}
	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid date format, use YYYY-MM-DD")
	}

	items, err := h.choreSer.GetRoomTasksForDate(uint(roomID), date)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}
	return c.JSON(items)
}

func (h choreHandler) GetMyTasksForDate(c *fiber.Ctx) error {
	roomID, err := strconv.Atoi(c.Params("roomID"))
	if err != nil || roomID <= 0 {
		return fiber.NewError(fiber.StatusBadRequest, "invalid room id")
	}

	dateStr := c.Query("date")
	if dateStr == "" {
		return fiber.NewError(fiber.StatusBadRequest, "date is required (YYYY-MM-DD)")
	}
	day, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid date format, use YYYY-MM-DD")
	}

	// Get bearer token
	token := c.Get("Authorization")
	if token == "" {
		return fiber.NewError(fiber.StatusUnauthorized, "missing authorization token")
	}

	// Extract user id from token (returns int in your utils)
	intUserID, err := utils.ExtractUserIDFromToken(strings.Replace(token, "Bearer ", "", 1), h.jwtSecret)
	if err != nil {
		return fiber.NewError(fiber.StatusUnauthorized, "invalid token")
	}
	if intUserID <= 0 {
		return fiber.NewError(fiber.StatusUnauthorized, "invalid user id in token")
	}
	userID := uint(intUserID) // <-- convert int -> uint

	items, err := h.choreSer.GetMyTasksForDate(uint(roomID), userID, day)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}
	return c.JSON(items)
}

func (h *choreHandler) GetChoreDetailByID(c *fiber.Ctx) error {
	choreID, err := strconv.ParseUint(c.Params("choreID"), 10, 32)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid chore id",
		})
	}

	choreDetail, err := h.choreSer.GetChoreDetailByID(uint(choreID))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(choreDetail)
}
