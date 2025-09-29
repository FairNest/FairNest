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

	return c.Status(fiber.StatusCreated).JSON(roomJoinRequest)
}

func (h *roomJoinHandler) GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserID(c *fiber.Ctx) error {
	roomJoinRequestID, err := strconv.Atoi(c.Params("roomJoinRequestID"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid requester room join request id",
		})
	}

	voterUserID, err := strconv.Atoi(c.Params("voterUserID"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid voter user id",
		})
	}

	response, err := h.roomJoinSer.GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserID(roomJoinRequestID, voterUserID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(response)
}
