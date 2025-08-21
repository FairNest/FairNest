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
	Username                *string `json:"username" validate:"required" form:"username"`
	Password                *string `json:"password" validate:"required" form:"password"`
	Email                   *string `json:"email" validate:"required" form:"email"`
	Firstname               *string `json:"firstname" validate:"required" form:"firstname"`
	Lastname                *string `json:"lastname" validate:"required" form:"lastname"`
	PhoneNumber             *string `json:"phone_number" validate:"required" form:"phone_number"`
	UserPicture             *string `json:"user_picture" validate:"required" form:"user_picture"`
	BankAccountNumber       *string `json:"bank_account_number" validate:"required" form:"bank_account_number"`
	UserVerificationPicture *string `json:"user_verification_picture" validate:"required" form:"user_verification_picture"`
}

type LoginRequest struct {
	Email    *string `json:"email" validate:"required"`
	Password *string `json:"password" validate:"required"`
}

type UserResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	UserPicture *string `json:"user_pic" validate:"required"`
	Token       *string `json:"token,omitempty"`
}

type LoginResponse struct {
	UserID *uint   `json:"user_id" validate:"required"`
	Email  *string `json:"email" validate:"required"`
	Token  *string `json:"token,omitempty"`
}
