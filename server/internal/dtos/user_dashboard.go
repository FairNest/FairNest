package dtos

// GetUserDashboardResponse contains all data for the "Your Dashboard" section
type GetUserDashboardResponse struct {
	YourProgress YourProgressInfo `json:"your_progress"`
	TaskSummary  TaskSummaryInfo  `json:"task_summary"`
}

// YourProgressInfo shows user's personal progress for TODAY
type YourProgressInfo struct {
	CompletedTasks     int     `json:"completed_tasks"`     // Completed chores today
	TotalTasks         int     `json:"total_tasks"`         // Total chores assigned today
	CompletedPayments  int     `json:"completed_payments"`  // Settled transactions due today
	TotalPayments      int     `json:"total_payments"`      // Total transactions due today
	OverallCompleted   int     `json:"overall_completed"`   // Total completed (chores + payments)
	OverallTotal       int     `json:"overall_total"`       // Total items (chores + payments)
	ProgressPercentage float64 `json:"progress_percentage"` // Overall completion percentage
}

// TaskSummaryInfo categorizes tasks/obligations for the user
type TaskSummaryInfo struct {
	TodayUnfinishedCount    int                 `json:"today_unfinished_count"`    // Unfinished today
	CompletedCount          int                 `json:"completed_count"`           // Completed today
	UpcomingUnfinishedCount int                 `json:"upcoming_unfinished_count"` // Unfinished in next 7 days
	TodayUnfinishedItems    []UserDashboardItem `json:"today_unfinished_items"`    // Details of today's unfinished
	CompletedItems          []UserDashboardItem `json:"completed_items"`           // Details of completed today
	UpcomingUnfinishedItems []UserDashboardItem `json:"upcoming_unfinished_items"` // Details of upcoming unfinished
}

// UserDashboardItem represents a single task or payment obligation
type UserDashboardItem struct {
	ItemType    string  `json:"item_type"`    // "chore" or "payment"
	ItemID      uint    `json:"item_id"`      // ChoreAssignmentID or TransactionID
	Title       string  `json:"title"`        // Chore title or finance title
	Description *string `json:"description"`  // Optional description
	DueDate     string  `json:"due_date"`     // "YYYY-MM-DD"
	DueTime     *string `json:"due_time"`     // "HH:MM" for chores, null for payments
	Amount      *int    `json:"amount"`       // For payments only
	Category    *string `json:"category"`     // Category (chore or finance)
	Status      string  `json:"status"`       // "pending", "completed", "overdue"
	CompletedAt *string `json:"completed_at"` // ISO timestamp if completed
}
