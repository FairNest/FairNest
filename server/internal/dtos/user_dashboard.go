package dtos

// 1. Your Progress Now Response
type GetUserProgressResponse struct {
	CompletedTasks     int     `json:"completed_tasks"`
	TotalTasks         int     `json:"total_tasks"`
	CompletedPayments  int     `json:"completed_payments"`
	TotalPayments      int     `json:"total_payments"`
	OverallCompleted   int     `json:"overall_completed"`
	OverallTotal       int     `json:"overall_total"`
	ProgressPercentage float64 `json:"progress_percentage"`
}

// Chore Item Response (for chore cards)
type UserChoreItem struct {
	ChoreAssignmentID uint    `json:"chore_assignment_id"`
	ChoreID           uint    `json:"chore_id"`
	Title             string  `json:"title"`
	Status            string  `json:"status"` // "pending", "completed", "overdue"
	DueDate           string  `json:"due_date"`
	DueTime           *string `json:"due_time"`
	Category          *string `json:"category"`
	Points            int     `json:"points"`
	AssignedName      *string `json:"assigned_name"`
	AssignedAvatar    *string `json:"assigned_avatar"`
	AutoRotate        *bool   `json:"auto_rotate"`
	Recurrence        *string `json:"recurrence"`
	ReminderTime      *string `json:"reminder_time"`
	ReminderRepeat    *string `json:"reminder_repeat"`
}

// Finance Item Response (for payment cards)
type UserFinanceItem struct {
	TransactionID uint    `json:"transaction_id"`
	FinanceID     uint    `json:"finance_id"`
	Title         string  `json:"title"`
	Status        string  `json:"status"` // "pending", "completed", "overdue"
	DueDate       string  `json:"due_date"`
	Category      *string `json:"category"`
	Points        int     `json:"points"`
	Amount        *int    `json:"amount"`
	TotalAmount   *int    `json:"total_amount"`
	SplitType     *string `json:"split_type"` // "even" or "custom"
	SplitCount    *int    `json:"split_count"`
	PayToName     *string `json:"pay_to_name"`
	PayToAvatar   *string `json:"pay_to_avatar"`
	QRCode        *string `json:"qr_code"`
	PaymentLink   *string `json:"payment_link"`
}

// Separated response for tasks
type GetUserTasksSeparatedResponse struct {
	Chores   []UserChoreItem   `json:"chores"`
	Finances []UserFinanceItem `json:"finances"`
}

// Type aliases for the three task endpoints
type GetUserTasksTodayResponse = GetUserTasksSeparatedResponse
type GetUserTasksCompletedResponse = GetUserTasksSeparatedResponse
type GetUserTasksUpcomingResponse = GetUserTasksSeparatedResponse
