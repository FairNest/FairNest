package dtos

type UserDataResponse struct {
	UserID                     *uint    `json:"user_id" validate:"required"`
	Username                   *string  `json:"username" validate:"required"`
	Password                   *string  `json:"password" validate:"required"`
	Email                      *string  `json:"email" validate:"required"`
	Firstname                  *string  `json:"firstname" validate:"required"`
	Lastname                   *string  `json:"lastname" validate:"required"`
	PhoneNumber                *string  `json:"phone_number" validate:"required"`
	UserPicture                *string  `json:"user_picture" validate:"required"`
	UserAboutMe                *string  `json:"user_about_me" validate:"required"`
	BankAccountNumber          *string  `json:"bank_account_number" validate:"required"`
	RoommateScore              *float64 `json:"roommate_score" validate:"required"`
	UserVerificationPicture    *string  `json:"user_verification_picture" validate:"required"`
	UserIdentityDocumentNumber *string  `json:"user_identity_document_number" validate:"required"`
	UserIdentityDocumentType   *bool    `json:"user_identity_document_type" validate:"required"`
}

type UserByUserIdDataResponse struct {
	UserID                     *uint    `json:"user_id" validate:"required"`
	Username                   *string  `json:"username" validate:"required"`
	Password                   *string  `json:"password" validate:"required"`
	Email                      *string  `json:"email" validate:"required"`
	Firstname                  *string  `json:"firstname" validate:"required"`
	Lastname                   *string  `json:"lastname" validate:"required"`
	PhoneNumber                *string  `json:"phone_number" validate:"required"`
	UserPicture                *string  `json:"user_picture" validate:"required"`
	UserAboutMe                *string  `json:"user_about_me" validate:"required"`
	BankAccountNumber          *string  `json:"bank_account_number" validate:"required"`
	RoommateScore              *float64 `json:"roommate_score" validate:"required"`
	UserVerificationPicture    *string  `json:"user_verification_picture" validate:"required"`
	UserIdentityDocumentNumber *string  `json:"user_identity_document_number" validate:"required"`
	UserIdentityDocumentType   *bool    `json:"user_identity_document_type" validate:"required"`
}

type UserByTokenDataResponse struct {
	UserID                     *uint    `json:"user_id" validate:"required"`
	Username                   *string  `json:"username" validate:"required"`
	Password                   *string  `json:"password" validate:"required"`
	Email                      *string  `json:"email" validate:"required"`
	Firstname                  *string  `json:"firstname" validate:"required"`
	Lastname                   *string  `json:"lastname" validate:"required"`
	PhoneNumber                *string  `json:"phone_number" validate:"required"`
	UserPicture                *string  `json:"user_picture" validate:"required"`
	UserAboutMe                *string  `json:"user_about_me" validate:"required"`
	BankAccountNumber          *string  `json:"bank_account_number" validate:"required"`
	RoommateScore              *float64 `json:"roommate_score" validate:"required"`
	UserVerificationPicture    *string  `json:"user_verification_picture" validate:"required"`
	UserIdentityDocumentNumber *string  `json:"user_identity_document_number" validate:"required"`
	UserIdentityDocumentType   *bool    `json:"user_identity_document_type" validate:"required"`
}

//////////////////////////////////////////////////////////////////////////////

type CurrentUserResponse struct {
	UserID                     *uint    `json:"user_id" validate:"required"`
	Username                   *string  `json:"username" validate:"required"`
	Password                   *string  `json:"password" validate:"required"`
	Email                      *string  `json:"email" validate:"required"`
	Firstname                  *string  `json:"firstname" validate:"required"`
	Lastname                   *string  `json:"lastname" validate:"required"`
	PhoneNumber                *string  `json:"phone_number" validate:"required"`
	UserPicture                *string  `json:"user_picture" validate:"required"`
	UserAboutMe                *string  `json:"user_about_me" validate:"required"`
	BankAccountNumber          *string  `json:"bank_account_number" validate:"required"`
	RoommateScore              *float64 `json:"roommate_score" validate:"required"`
	UserVerificationPicture    *string  `json:"user_verification_picture" validate:"required"`
	UserIdentityDocumentNumber *string  `json:"user_identity_document_number" validate:"required"`
	UserIdentityDocumentType   *bool    `json:"user_identity_document_type" validate:"required"`
}

type ProfileOfCurrentUserByUserIdResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	UserPicture *string `json:"user_picture" validate:"required"`
	UserAboutMe *string `json:"user_about_me" validate:"required"`
}

type EditUserProfileByUserIdResponse struct {
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	UserAboutMe *string `json:"user_about_me" validate:"required"`
}

type EditUserProfileByUserIdRequest struct {
	Username    *string `json:"username" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	UserAboutMe *string `json:"user_about_me" validate:"required"`
}

type RegisterRequest struct {
	Username                   *string `json:"username" validate:"required" form:"username"`
	Password                   *string `json:"password" validate:"required" form:"password"`
	Email                      *string `json:"email" validate:"required" form:"email"`
	Firstname                  *string `json:"firstname" validate:"required" form:"firstname"`
	Lastname                   *string `json:"lastname" validate:"required" form:"lastname"`
	PhoneNumber                *string `json:"phone_number" validate:"required" form:"phone_number"`
	UserPicture                *string `json:"user_picture" validate:"required" form:"user_picture"`
	UserAboutMe                *string `json:"user_about_me" validate:"required" form:"user_about_me"`
	BankAccountNumber          *string `json:"bank_account_number" validate:"required" form:"bank_account_number"`
	UserVerificationPicture    *string `json:"user_verification_picture" validate:"required" form:"user_verification_picture"`
	UserIdentityDocumentNumber *string `json:"user_identity_document_number" validate:"required" form:"user_identity_document_number"`
	UserIdentityDocumentType   *bool   `json:"user_identity_document_type" validate:"required" form:"user_identity_document_type"`

	//Lifestyle Questions
	Q1  *int `json:"q1" validate:"required" form:"q1"`
	Q2  *int `json:"q2" validate:"required" form:"q2"`
	Q3  *int `json:"q3" validate:"required" form:"q3"`
	Q4  *int `json:"q4" validate:"required" form:"q4"`
	Q5  *int `json:"q5" validate:"required" form:"q5"`
	Q6  *int `json:"q6" validate:"required" form:"q6"`
	Q7  *int `json:"q7" validate:"required" form:"q7"`
	Q8  *int `json:"q8" validate:"required" form:"q8"`
	Q9  *int `json:"q9" validate:"required" form:"q9"`
	Q10 *int `json:"q10" validate:"required" form:"q10"`
	Q11 *int `json:"q11" validate:"required" form:"q11"`
	Q12 *int `json:"q12" validate:"required" form:"q12"`
	// Personality Traits
	UserTidiness       *float64 `json:"user_tidiness" validate:"required" form:"user_tidiness"`
	UserNoiseActivity  *float64 `json:"user_noise_activity" validate:"required" form:"user_noise_activity"`
	UserSchedule       *float64 `json:"user_schedule" validate:"required" form:"user_schedule"`
	UserGuestFrequency *float64 `json:"user_guest_frequency" validate:"required" form:"user_guest_frequency"`
	UserTaskStructure  *float64 `json:"user_task_structure" validate:"required" form:"user_task_structure"`
	UserMoneyAttitude  *float64 `json:"user_money_attitude" validate:"required" form:"user_money_attitude"`
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
