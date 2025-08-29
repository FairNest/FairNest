package dtos

type RoomMemberByRoomIdDataResponse struct {
	RoomMemberID *uint `json:"room_member_id" validate:"required"`
	UserID       *uint `json:"user_id" validate:"required"`
	RoomID       *uint `json:"room_id" validate:"required"`
	IsHost       *bool `json:"is_host" validate:"required"`
}
