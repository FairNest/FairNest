package dtos

type GetLifestyleByUserIdResponse struct {
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

type GetUserOverallLifestyleByUserIdResponse struct {
	LifestyleID *uint `json:"lifestyle_id" validate:"required" `
	UserID      *uint `json:"user_id" validate:"required"`

	// Personality Traits
	UserTidiness       *float64 `json:"user_tidiness" validate:"required"`
	UserNoiseActivity  *float64 `json:"user_noise_activity" validate:"required"`
	UserSchedule       *float64 `json:"user_schedule" validate:"required"`
	UserGuestFrequency *float64 `json:"user_guest_frequency" validate:"required"`
	UserTaskStructure  *float64 `json:"user_task_structure" validate:"required"`
	UserMoneyAttitude  *float64 `json:"user_money_attitude" validate:"required"`
}

type CompatibilityPair struct {
	UserAID   uint    `json:"user_a_id"`
	UserAName string  `json:"user_a_name"`
	UserBID   uint    `json:"user_b_id"`
	UserBName string  `json:"user_b_name"`
	Score     float64 `json:"score"` // percentage (0–100)
}

type RoomCompatibilitySummaryResponse struct {
	Score         float64           `json:"score"`          // average percentage (0–100)
	BestMatched   CompatibilityPair `json:"best_matched"`   // highest pairwise
	MostDivergent CompatibilityPair `json:"most_divergent"` // lowest pairwise
}

type CompatibilityMatchItem struct {
	UserID         uint    `json:"user_id"`
	Username       string  `json:"username"`
	ProfilePicture *string `json:"profile_picture,omitempty"`
	Score          float64 `json:"score"` // percentage (0–100)
	Match          string  `json:"match"` // Bad/Average/Good/Very Good/Perfect
}

type CompatibilityMatchResponse struct {
	RoomID  uint                     `json:"room_id"`
	UserID  uint                     `json:"user_id"`
	Matches []CompatibilityMatchItem `json:"matches"`
}
