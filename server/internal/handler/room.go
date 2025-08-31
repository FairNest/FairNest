package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"github.com/gofiber/fiber/v2"
	"strconv"
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
			RoomID: room.RoomID,
			// RoomDetails
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

func (h *roomHandler) FetchAllRoomWithRoomMembersDetails(c *fiber.Ctx) error {
	roomsResponse, err := h.roomSer.FetchAllRoomWithRoomMembersDetails()
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.JSON(roomsResponse)
}
