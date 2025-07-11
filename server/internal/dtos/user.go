package dtos

type UserDataResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Password    *string `json:"password" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_num" validate:"required"`
	UserPicture *string `json:"user_pic" validate:"required"`
}

type UserByUserIdDataResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Password    *string `json:"password" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_num" validate:"required"`
	UserPicture *string `json:"user_pic" validate:"required"`
}

type UserByTokenDataResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Password    *string `json:"password" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_num" validate:"required"`
	UserPicture *string `json:"user_pic" validate:"required"`
}

//////////////////////////////////////////////////////////////////////////////

type CurrentUserResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Password    *string `json:"password" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_num" validate:"required"`
	UserPicture *string `json:"user_pic" validate:"required"`
}

type ProfileOfCurrentUserByUserIdResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_num" validate:"required"`
	UserPicture *string `json:"user_pic" validate:"required"`
}

type EditUserProfileByUserIdResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_num" validate:"required"`
}

type EditUserProfileByUserIdRequest struct {
	Username    *string `json:"username" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_num" validate:"required"`
}

type RegisterRequest struct {
	Username    *string `json:"username" validate:"required"`
	Password    *string `json:"password" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_num" validate:"required"`
	UserPicture *string `json:"user_pic" form:"userPic" validate:"required"`
}

type LoginRequest struct {
	Username *string `json:"username" validate:"required"`
	Password *string `json:"password" validate:"required"`
}

type UserResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	UserPicture *string `json:"user_pic" validate:"required"`
	Token       *string `json:"token,omitempty"`
}

type LoginResponse struct {
	UserID   *uint   `json:"user_id" validate:"required"`
	Username *string `json:"username" validate:"required"`
	Token    *string `json:"token,omitempty"`
}
