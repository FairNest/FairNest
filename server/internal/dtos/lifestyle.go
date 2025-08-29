package dtos

type LifestyleByUserIdResponse struct {
	LifestyleID *uint `json:"lifestyle_id" validate:"required" `
	UserID      *uint `json:"user_id" validate:"required"`
	Q1          *int  `json:"q1" validate:"required"`
	Q2          *int  `json:"q2" validate:"required"`
	Q3          *int  `json:"q3" validate:"required"`
	Q4          *int  `json:"q4" validate:"required"`
	Q5          *int  `json:"q5" validate:"required"`
	Q6          *int  `json:"q6" validate:"required"`
	Q7          *int  `json:"q7" validate:"required"`
	Q8          *int  `json:"q8" validate:"required"`
	Q9          *int  `json:"q9" validate:"required"`
	Q10         *int  `json:"q10" validate:"required"`
	Q11         *int  `json:"q11" validate:"required"`
	Q12         *int  `json:"q12" validate:"required"`

	// Personality Traits
	UserTidiness       *float64 `json:"user_tidiness" validate:"required"`
	UserNoiseActivity  *float64 `json:"user_noise_activity" validate:"required"`
	UserSchedule       *float64 `json:"user_schedule" validate:"required"`
	UserGuestFrequency *float64 `json:"user_guest_frequency" validate:"required"`
	UserTaskStructure  *float64 `json:"user_task_structure" validate:"required"`
	UserMoneyAttitude  *float64 `json:"user_money_attitude" validate:"required"`
}
