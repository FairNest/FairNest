package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"time"
)

type ChoreService interface {
	FetchAllChore() ([]entities.Chore, error)

	///////////////////////////////////////////////////////////////////////////////////////

	// * chore management
	CreateChore(roomID uint, request *dtos.CreateChoreRequest) (*dtos.CreateChoreResponse, error)
	GetChoresByRoomID(roomID uint) ([]dtos.GetRoomChoresResponse, error)
	UpdateChore(choreID uint, request *dtos.EditChoreRequest) (*dtos.CreateChoreResponse, error)
	DeleteChore(choreID uint) error

	// * calendar and assignment views
	GetChoreCalendar(roomID uint, startDate, endDate time.Time) ([]dtos.GetChoreCalendarResponse, error)
	GetTodayChores(roomID uint, userID uint) ([]dtos.GetTodayChoresResponse, error)

	// * chore completion
	MarkChoreComplete(userID uint, assignmentID uint) (*dtos.MarkChoreCompleteResponse, error)

	// * background tasks for auto-assignment and scoring
	GenerateWeeklyAssignments() error
	ProcessMissedChores() error

	// * helper functions
	GenerateChoreAssignments(choreID uint, startDate, endDate time.Time) error
}
