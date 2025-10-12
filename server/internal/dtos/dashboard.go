package dtos

// GetRoomDashboardResponse combines all data needed for the Room Dashboard view
type GetRoomDashboardResponse struct {
	TodayRoomStatus  TodayRoomStatusResponse `json:"today_room_status"`
	RoommateOverview []RoommateOverviewItem  `json:"roommate_overview"`
}

// TodayRoomStatusResponse contains room-level statistics for TODAY
type TodayRoomStatusResponse struct {
	RoomCompatibility RoomCompatibilityInfo `json:"room_compatibility"`
	ChoresProgress    ChoresProgressInfo    `json:"chores_progress"`
	FinancesProgress  FinancesProgressInfo  `json:"finances_progress"`
}

// RoomCompatibilityInfo shows overall room compatibility (ALL TIME - not date-based)
type RoomCompatibilityInfo struct {
	Score float64 `json:"score"` // 0.0 to 1.0 (e.g., 0.5 = 50%)
}

// ChoresProgressInfo shows chore completion stats for TODAY
type ChoresProgressInfo struct {
	CompletedTasks int `json:"completed_tasks"`
	TotalTasks     int `json:"total_tasks"`
}

// FinancesProgressInfo shows finance completion stats for transactions due TODAY
type FinancesProgressInfo struct {
	CompletedFinances int `json:"completed_finances"` // Number of settled transactions due today
	TotalFinances     int `json:"total_finances"`     // Total transactions due today
}

// RoommateOverviewItem contains individual roommate statistics for TODAY
type RoommateOverviewItem struct {
	UserID             uint    `json:"user_id"`
	Name               string  `json:"name"`
	UserPicture        *string `json:"user_picture"`
	CompatibilityScore float64 `json:"compatibility_score"` // 0-100 percentage (ALL TIME - not date-based)
	TasksCompleted     int     `json:"tasks_completed"`     // Completed tasks TODAY
	TasksTotal         int     `json:"tasks_total"`         // Total tasks TODAY
	FinanceAmount      int     `json:"finance_amount"`      // Always positive - amount they owe to current user (ALL TIME - cumulative)
	FinanceStatus      string  `json:"finance_status"`      // Always "owes_you"
}

// Note: RoomUserInfo is already defined in roommember.go, so we don't redeclare it here
