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
