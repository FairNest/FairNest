package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"github.com/gofiber/fiber/v2"
	"strconv"
)

type roomMemberHandler struct {
	roomMemberSer service.RoomMemberService
}

func NewRoomMemberHandler(roomMemberSer service.RoomMemberService) roomMemberHandler {
	return roomMemberHandler{roomMemberSer: roomMemberSer}
}

func (h *roomMemberHandler) GetRoomMemberByRoomId(c *fiber.Ctx) error {
	roomIDReceive, err := strconv.Atoi(c.Params("RoomID"))

	roomMember, err := h.roomMemberSer.GetRoomMemberByRoomId(roomIDReceive)
	if err != nil {
		return err
	}

	roomMemberResponse := dtos.RoomMemberByRoomIdResponse{
		RoomMemberID: roomMember.RoomMemberID,
		RoomID:       roomMember.RoomID,
		UserID:       roomMember.UserID,
		IsHost:       roomMember.IsHost,
	}

	return c.JSON(roomMemberResponse)
}
