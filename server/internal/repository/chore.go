package repository

import (
	"fairnest/internal/entities"
	"time"
)

type ChoreRepository interface {
	FetchAllChore() ([]entities.Chore, error)

	///////////////////////////////////////////////////////////////////////////////////////

	// * basic crud operations
	CreateChore(chore *entities.Chore) error
	GetChoreByID(choreID uint) (*entities.Chore, error)
	GetChoresByRoomID(roomID uint) ([]entities.Chore, error)
	UpdateChore(chore *entities.Chore) error
	DeleteChore(choreID uint) error

	// * assignment operations
	CreateChoreAssignment(assignment *entities.ChoreAssignment) error
	GetAssignmentByID(assignmentID uint) (*entities.ChoreAssignment, error)
	GetAssignmentsByDateRange(roomID uint, startDate, endDate time.Time) ([]entities.ChoreAssignment, error)
	GetTodayAssignments(roomID uint, date time.Time) ([]entities.ChoreAssignment, error)
	GetUserAssignmentsByDateRange(userID uint, startDate, endDate time.Time) ([]entities.ChoreAssignment, error)
	UpdateAssignment(assignment *entities.ChoreAssignment) error

	// * rotation operations
	CreateRotationUser(rotation *entities.ChoreRotationUser) error
	GetRotationUsersByChoreID(choreID uint) ([]entities.ChoreRotationUser, error)
	DeleteRotationUsersByChoreID(choreID uint) error
	GetNextAssignedUserInRotation(choreID uint, lastAssignedUserID uint) (*entities.ChoreRotationUser, error)

	// * status and scoring
	MarkAssignmentMissed(assignmentID uint) error
	GetPendingAssignments() ([]entities.ChoreAssignment, error)
	GetOverdueAssignments(currentTime time.Time) ([]entities.ChoreAssignment, error)

	GetAssignmentsForRoomOnDate(roomID uint, date time.Time) ([]entities.ChoreAssignment, error)
	GetAssignmentsForRoomOnDateByUser(roomID, userID uint, date time.Time) ([]entities.ChoreAssignment, error)
}
