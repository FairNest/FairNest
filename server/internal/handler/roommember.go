package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"strconv"

	"github.com/gofiber/fiber/v2"
)

type roomMemberHandler struct {
	roomMemberSer service.RoomMemberService
}

func NewRoomMemberHandler(roomMemberSer service.RoomMemberService) roomMemberHandler {
	return roomMemberHandler{roomMemberSer: roomMemberSer}
}

func (h *roomMemberHandler) FetchAllRoomMemberByRoomId(c *fiber.Ctx) error {
	roomMembersResponse := make([]dtos.FetchAllRoomMemberByRoomIdDataResponse, 0)
	roomIDReceive, err := strconv.Atoi(c.Params("RoomID"))

	roomMembers, err := h.roomMemberSer.FetchAllRoomMemberByRoomId(roomIDReceive)
	if err != nil {
		return err
	}

	for _, roomMember := range roomMembers {
		roomMembersResponse = append(roomMembersResponse, dtos.FetchAllRoomMemberByRoomIdDataResponse{
			RoomMemberID: roomMember.RoomMemberID,
			RoomID:       roomMember.RoomID,
			UserID:       roomMember.UserID,
			IsHost:       roomMember.IsHost,
		})
	}
	return c.JSON(roomMembersResponse)
}

// --------------------------------------------------------------------------------------------------------------

func (h *roomMemberHandler) FetchAllRoomMemberWithUserDetailsByRoomId(c *fiber.Ctx) error {
	roomMembersResponse := make([]dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse, 0)
	roomIDReceive, err := strconv.Atoi(c.Params("RoomID"))

	roomMembers, err := h.roomMemberSer.FetchAllRoomMemberWithUserDetailsByRoomId(roomIDReceive)
	if err != nil {
		return err
	}

	for _, roomMember := range roomMembers {
		roomMembersResponse = append(roomMembersResponse, dtos.FetchAllRoomMemberWithUserDetailsByRoomIdResponse{
			RoomMemberID: roomMember.RoomMemberID,
			RoomID:       roomMember.RoomID,
			UserID:       roomMember.UserID,
			IsHost:       roomMember.IsHost,
			Username:     roomMember.Username,
			Email:        roomMember.Email,
			Firstname:    roomMember.Firstname,
			Lastname:     roomMember.Lastname,
			PhoneNumber:  roomMember.PhoneNumber,
			UserPicture:  roomMember.UserPicture,
			UserAboutMe:  roomMember.UserAboutMe,
		})
	}
	return c.JSON(roomMembersResponse)
}

func (h *roomMemberHandler) CheckUserHasRoomOrNot(c *fiber.Ctx) error {
	userID, err := strconv.Atoi(c.Params("userID"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid user id",
		})
	}

	hasRoom, err := h.roomMemberSer.CheckUserHasRoomOrNot(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "user not found",
		})
	}

	return c.JSON(fiber.Map{
		"has_room": hasRoom,
	})
}

func (h roomMemberHandler) GetUsersBasicByRoomId(c *fiber.Ctx) error {
	roomID, err := strconv.Atoi(c.Params("RoomID"))
	if err != nil || roomID <= 0 {
		return fiber.NewError(fiber.StatusBadRequest, "invalid room id")
	}

	users, err := h.roomMemberSer.GetUsersBasicByRoomId(roomID) // int → int
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.Status(fiber.StatusOK).JSON(users)
}
