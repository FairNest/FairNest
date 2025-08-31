package dtos

type FetchAllRoomMemberByRoomIdDataResponse struct {
	RoomMemberID *uint `json:"room_member_id" validate:"required"`
	RoomID       *uint `json:"room_id" validate:"required"`
	UserID       *uint `json:"user_id" validate:"required"`
	IsHost       *bool `json:"is_host" validate:"required"`
}

type FetchAllRoomMemberWithUserDetailsByRoomIdResponse struct {
	RoomMemberID *uint `json:"room_member_id" validate:"required"`
	RoomID       *uint `json:"room_id" validate:"required"`
	UserID       *uint `json:"user_id" validate:"required"`
	IsHost       *bool `json:"is_host" validate:"required"`

	// Flatten user subset
	Username    *string `json:"username" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_number" validate:"required"`
	UserPicture *string `json:"user_picture" validate:"required"`
	UserAboutMe *string `json:"user_about_me" validate:"required"`
}

type UserRoomCheck struct {
	UserExists bool
	HasRoom    bool
}
