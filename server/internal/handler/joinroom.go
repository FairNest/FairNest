package handler

import (
	"fairnest/internal/service"
	"github.com/gofiber/fiber/v2"
	"strconv"
)

type roomJoinHandler struct {
	roomJoinSer service.RoomJoinService
}

func NewRoomJoinHandler(roomJoinSer service.RoomJoinService) roomJoinHandler {
	return roomJoinHandler{
		roomJoinSer: roomJoinSer,
	}
}

func (h *roomJoinHandler) CreateRoomJoinRequestByUserIdRoomId(c *fiber.Ctx) error {
	requesterUserID, err := strconv.Atoi(c.Params("UserID"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid user id",
		})
	}

	requestedRoomID, err := strconv.Atoi(c.Params("RoomID"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid room id",
		})
	}

	roomJoinRequest, err := h.roomJoinSer.CreateRoomJoinRequestByUserIdRoomId(requesterUserID, requestedRoomID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(roomJoinRequest)
	//return c.Status(fiber.StatusCreated).JSON(roomJoinRequest)
}
