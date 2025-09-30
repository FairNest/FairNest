package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

type roomHandler struct {
	roomSer service.RoomService
}

func NewRoomHandler(roomSer service.RoomService) roomHandler {
	return roomHandler{roomSer: roomSer}
}

func (h *roomHandler) FetchAllRoom(c *fiber.Ctx) error {
	roomsResponse := make([]dtos.RoomDataResponse, 0)

	rooms, err := h.roomSer.FetchAllRoom()
	if err != nil {
		return err
	}

	for _, room := range rooms {
		roomsResponse = append(roomsResponse, dtos.RoomDataResponse{
			// RoomDetails
			RoomID:                 room.RoomID,
			RoomName:               room.RoomName,
			RoomType:               room.RoomType,
			RoomMaxCapacity:        room.RoomMaxCapacity,
			RoomCurrentCapacity:    room.RoomCurrentCapacity,
			RoomDescription:        room.RoomDescription,
			RoomCode:               room.RoomCode,
			RoomCompatibilityScore: room.RoomCompatibilityScore,
			RoomPicture:            room.RoomPicture,
			// LivingSpaceDetails
			LivingSpaceName:        room.LivingSpaceName,
			RentCost:               room.RentCost,
			ElectricityCostPerUnit: room.ElectricityCostPerUnit,
			WaterCostPerUnit:       room.WaterCostPerUnit,
			OtherUtilityDetails:    room.OtherUtilityDetails,
			// RoommateAgreements
			QuietHoursStart: room.QuietHoursStart,
			GuestStayOver:   room.GuestStayOver,
			HandleCleaning:  room.HandleCleaning,
			SharedSpace:     room.SharedSpace,
			SplitCosts:      room.SplitCosts,
			// Personality Averages
			AvgTidiness:       room.AvgTidiness,
			AvgNoiseActivity:  room.AvgNoiseActivity,
			AvgSchedule:       room.AvgSchedule,
			AvgGuestFrequency: room.AvgGuestFrequency,
			AvgTaskStructure:  room.AvgTaskStructure,
			AvgMoneyAttitude:  room.AvgMoneyAttitude,
		})
	}
	return c.JSON(roomsResponse)
}

func (h *roomHandler) FetchAllRoomWithRoomMembersDetails(c *fiber.Ctx) error {
	roomsResponse, err := h.roomSer.FetchAllRoomWithRoomMembersDetails()
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.JSON(roomsResponse)
}

func (h *roomHandler) FetchAllRoomSuitUserLifestyleByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	rooms, err := h.roomSer.FetchAllRoomSuitUserLifestyleByUserId(userIDReceive)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.JSON(rooms)
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func (h *roomHandler) CreateRoomByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	var req dtos.CreateRoomByUserIdRequest
	if err := c.BodyParser(&req); err != nil {
		return err
	}

	room, err := h.roomSer.CreateRoomByUserId(userIDReceive, req)
	if err != nil {
		return err
	}

	return c.JSON(room)
}

func (h *roomHandler) FetchAllPublicRoomSuitUserLifestyleByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	rooms, err := h.roomSer.FetchAllPublicRoomSuitUserLifestyleByUserId(userIDReceive)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.JSON(rooms)
}

func (h *roomHandler) FilterPublicRoomSuitUserLifestyleByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "Invalid user ID")
	}

	// Parse filter parameters
	filters := h.parseFilterParams(c)

	rooms, err := h.roomSer.FilterPublicRoomSuitUserLifestyleByUserId(userIDReceive, filters)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.JSON(rooms)
}

// Add this helper method to your handler
func (h *roomHandler) parseFilterParams(c *fiber.Ctx) map[string]interface{} {
	filters := make(map[string]interface{})

	// Parse numeric filters
	if maxCapacity := c.Query("maxCapacity"); maxCapacity != "" {
		if val, err := strconv.Atoi(maxCapacity); err == nil {
			filters["maxCapacity"] = val
		}
	}

	if minRent := c.Query("minRent"); minRent != "" {
		if val, err := strconv.ParseFloat(minRent, 64); err == nil {
			filters["minRent"] = val
		}
	}

	if maxRent := c.Query("maxRent"); maxRent != "" {
		if val, err := strconv.ParseFloat(maxRent, 64); err == nil {
			filters["maxRent"] = val
		}
	}

	if maxElectricity := c.Query("maxElectricity"); maxElectricity != "" {
		if val, err := strconv.ParseFloat(maxElectricity, 64); err == nil {
			filters["maxElectricity"] = val
		}
	}

	if maxWater := c.Query("maxWater"); maxWater != "" {
		if val, err := strconv.ParseFloat(maxWater, 64); err == nil {
			filters["maxWater"] = val
		}
	}

	// Parse time filter
	if quietHoursStart := c.Query("quietHoursStart"); quietHoursStart != "" {
		filters["quietHoursStart"] = quietHoursStart
	}

	// Parse minimum compatibility
	if minCompatibility := c.Query("minCompatibility"); minCompatibility != "" {
		if val, err := strconv.ParseFloat(minCompatibility, 64); err == nil {
			filters["minCompatibility"] = val
		}
	}

	return filters
}

func (h *roomHandler) GetMyRoomByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	room, err := h.roomSer.GetMyRoomByUserId(userIDReceive)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.JSON(room)
}

func (h *roomHandler) GetRoomDetailsByRoomId(c *fiber.Ctx) error {
	roomIdReceive, err := strconv.Atoi(c.Params("roomId"))
	if err != nil {
		return fiber.NewError(fiber.StatusBadRequest, "invalid room id")
	}

	room, err := h.roomSer.GetRoomDetailsByRoomId(roomIdReceive)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.JSON(room)
}

func (h *roomHandler) GetRoomDetailsByRoomCode(c *fiber.Ctx) error {
	roomCodeReceive := c.Params("RoomCode")
	if roomCodeReceive == "" {
		return fiber.NewError(fiber.StatusBadRequest, "invalid room code")
	}

	room, err := h.roomSer.GetRoomDetailsByRoomCode(roomCodeReceive)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.JSON(room)
}

func (h *roomHandler) GetHouseRulesByRoomId(c *fiber.Ctx) error {
	roomIDReceive, err := strconv.Atoi(c.Params("RoomID"))

	room, err := h.roomSer.GetHouseRulesByRoomId(roomIDReceive)
	if err != nil {
		return err
	}

	roomResponse := dtos.GetHouseRulesByRoomIdResponse{
		RoomID:          room.RoomID,
		QuietHoursStart: room.QuietHoursStart,
		GuestStayOver:   room.GuestStayOver,
		HandleCleaning:  room.HandleCleaning,
		SharedSpace:     room.SharedSpace,
		SplitCosts:      room.SplitCosts,
	}

	return c.JSON(roomResponse)
}

func (h *roomHandler) PatchEditHouseRulesByRoomId(c *fiber.Ctx) error {
	roomIDReceive, err := strconv.Atoi(c.Params("RoomID"))

	var req dtos.PatchEditHouseRulesByRoomIdRequest
	if err := c.BodyParser(&req); err != nil {
		return err
	}

	room, err := h.roomSer.PatchEditHouseRulesByRoomId(roomIDReceive, req)
	if err != nil {
		return err
	}

	roomResponse := dtos.PatchEditHouseRulesByRoomIdRequest{
		QuietHoursStart: room.QuietHoursStart,
		GuestStayOver:   room.GuestStayOver,
		HandleCleaning:  room.HandleCleaning,
		SharedSpace:     room.SharedSpace,
		SplitCosts:      room.SplitCosts,
	}

	return c.JSON(roomResponse)
}

func (h *roomHandler) GetRoomOverallLifestyleByRoomId(c *fiber.Ctx) error {
	roomIDReceive, err := strconv.Atoi(c.Params("RoomID"))

	room, err := h.roomSer.GetRoomOverallLifestyleByRoomId(roomIDReceive)
	if err != nil {
		return err
	}

	roomResponse := dtos.GetRoomOverallLifestyleByRoomIdResponse{
		RoomID:            room.RoomID,
		AvgTidiness:       room.AvgTidiness,
		AvgNoiseActivity:  room.AvgNoiseActivity,
		AvgSchedule:       room.AvgSchedule,
		AvgGuestFrequency: room.AvgGuestFrequency,
		AvgTaskStructure:  room.AvgTaskStructure,
		AvgMoneyAttitude:  room.AvgMoneyAttitude,
	}

	return c.JSON(roomResponse)
}

func (h *roomHandler) GetMyPendingRoomByUserID(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	room, err := h.roomSer.GetMyPendingRoomByUserID(userIDReceive)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.JSON(room)
}
