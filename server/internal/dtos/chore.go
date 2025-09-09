package dtos

type ChoreDataResponse struct {
	ChoreID           *uint   `json:"chore_id"`
	RoomID            *uint   `json:"room_id"`
	ChoreTitle        *string `json:"chore_title"`
	ChoreDescription  *string `json:"chore_description"`
	Category          *string `json:"category"`
	DueDayOfWeek      *string `json:"due_day_of_week"`
	DueTime           *string `json:"due_time"`
	ReminderDayOfWeek *string `json:"reminder_day_of_week"`
	ReminderTime      *string `json:"reminder_time"`
	Recurrence        *string `json:"recurrence"`
	AutoRotate        *bool   `json:"auto_rotate"`
	ChoreScore        *int    `json:"chore_score"`
	CreatedAt         *string `json:"created_at"`
	UpdatedAt         *string `json:"updated_at"`
}

// CreateChoreRequest * create task request
type CreateChoreRequest struct {
	ChoreTitle        *string `json:"chore_title" validate:"required"`
	ChoreDescription  *string `json:"chore_description"`
	Category          *string `json:"category" validate:"required"`
	DueDayOfWeek      *string `json:"due_day_of_week" validate:"required"`
	DueTime           *string `json:"due_time" validate:"required"`
	ReminderDayOfWeek *string `json:"reminder_day_of_week"`
	ReminderTime      *string `json:"reminder_time"`
	Recurrence        *string `json:"recurrence" validate:"required"`
	AutoRotate        *bool   `json:"auto_rotate"`
	ChoreScore        *int    `json:"chore_score" validate:"required"`
	AssignedUserIDs   []uint  `json:"assigned_user_ids"`
}

// CreateChoreResponse * create task response
type CreateChoreResponse struct {
	ChoreID           *uint   `json:"chore_id" validate:"required"`
	RoomID            *uint   `json:"room_id" validate:"required"`
	ChoreTitle        *string `json:"chore_title" validate:"required"`
	ChoreDescription  *string `json:"chore_description"`
	Category          *string `json:"category" validate:"required"`
	DueDayOfWeek      *string `json:"due_day_of_week" validate:"required"`
	DueTime           *string `json:"due_time" validate:"required"`
	ReminderDayOfWeek *string `json:"reminder_day_of_week"`
	ReminderTime      *string `json:"reminder_time"`
	Recurrence        *string `json:"recurrence" validate:"required"`
	AutoRotate        *bool   `json:"auto_rotate"`
	ChoreScore        *int    `json:"chore_score" validate:"required"`
	CreatedAt         *string `json:"created_at" validate:"required"`
}

// EditChoreRequest * edit task request
type EditChoreRequest struct {
	ChoreTitle        *string `json:"chore_title" validate:"required"`
	ChoreDescription  *string `json:"chore_description"`
	Category          *string `json:"category" validate:"required"`
	DueDayOfWeek      *string `json:"due_day_of_week" validate:"required"`
	DueTime           *string `json:"due_time" validate:"required"`
	ReminderDayOfWeek *string `json:"reminder_day_of_week"`
	ReminderTime      *string `json:"reminder_time"`
	Recurrence        *string `json:"recurrence" validate:"required"`
	AutoRotate        *bool   `json:"auto_rotate"`
	ChoreScore        *int    `json:"chore_score" validate:"required"`
	AssignedUserIDs   []uint  `json:"assigned_user_ids"`
}

// GetChoreCalendarResponse * get chores for calendar view
type GetChoreCalendarResponse struct {
	Date   *string                     `json:"date"`
	Chores []ChoreCalendarItemResponse `json:"chores"`
}

type ChoreCalendarItemResponse struct {
	ChoreAssignmentID *uint             `json:"chore_assignment_id"`
	ChoreID           *uint             `json:"chore_id"`
	ChoreTitle        *string           `json:"chore_title"`
	Category          *string           `json:"category"`
	DueTime           *string           `json:"due_time"`
	Status            *string           `json:"status"`
	ChoreScore        *int              `json:"chore_score"`
	AssignedUser      *AssignedUserInfo `json:"assigned_user"`
}

type AssignedUserInfo struct {
	UserID      *uint   `json:"user_id"`
	Username    *string `json:"username"`
	UserPicture *string `json:"user_picture"`
}

// GetTodayChoresResponse * get today tasks
type GetTodayChoresResponse struct {
	ChoreAssignmentID *uint             `json:"chore_assignment_id"`
	ChoreID           *uint             `json:"chore_id"`
	ChoreTitle        *string           `json:"chore_title"`
	ChoreDescription  *string           `json:"chore_description"`
	Category          *string           `json:"category"`
	DueTime           *string           `json:"due_time"`
	Status            *string           `json:"status"`
	ChoreScore        *int              `json:"chore_score"`
	IsMyTask          *bool             `json:"is_my_task"`
	AssignedUser      *AssignedUserInfo `json:"assigned_user"`
}

// MarkChoreCompleteRequest * mark chore as completed request
type MarkChoreCompleteRequest struct {
	ChoreAssignmentID *uint `json:"chore_assignment_id" validate:"required"`
}

// MarkChoreCompleteResponse * mark chore as completed response
type MarkChoreCompleteResponse struct {
	ChoreAssignmentID *uint    `json:"chore_assignment_id"`
	Status            *string  `json:"status"`
	CompletedAt       *string  `json:"completed_at"`
	ScoreEarned       *int     `json:"score_earned"`
	NewRoommateScore  *float64 `json:"new_roommate_score"`
}

// GetRoomChoresResponse * get all chores for room management
type GetRoomChoresResponse struct {
	ChoreID           *uint              `json:"chore_id"`
	ChoreTitle        *string            `json:"chore_title"`
	ChoreDescription  *string            `json:"chore_description"`
	Category          *string            `json:"category"`
	DueDayOfWeek      *string            `json:"due_day_of_week"`
	DueTime           *string            `json:"due_time"`
	ReminderDayOfWeek *string            `json:"reminder_day_of_week"`
	ReminderTime      *string            `json:"reminder_time"`
	Recurrence        *string            `json:"recurrence"`
	AutoRotate        *bool              `json:"auto_rotate"`
	ChoreScore        *int               `json:"chore_score"`
	AssignedUsers     []AssignedUserInfo `json:"assigned_users"`
	CreatedAt         *string            `json:"created_at"`
}

// DeleteChoreResponse * delete chore response
type DeleteChoreResponse struct {
	Message *string `json:"message"`
	ChoreID *uint   `json:"chore_id"`
}
