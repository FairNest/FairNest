package repository

import (
	"fairnest/internal/entities"
	"time"

	"gorm.io/gorm"
)

type choreRepositoryDB struct {
	db *gorm.DB
}

func NewChoreRepositoryDB(db *gorm.DB) choreRepositoryDB {
	return choreRepositoryDB{db: db}
}

func (r choreRepositoryDB) FetchAllChore() ([]entities.Chore, error) {
	chores := []entities.Chore{}
	result := r.db.Find(&chores)
	if result.Error != nil {
		return nil, result.Error
	}
	return chores, nil
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////

// * basic crud operations
func (r choreRepositoryDB) CreateChore(chore *entities.Chore) error {
	return r.db.Create(chore).Error
}

func (r choreRepositoryDB) GetChoreByID(choreID uint) (*entities.Chore, error) {
	var chore entities.Chore
	err := r.db.Preload("Room").Preload("ChoreRotations.User").First(&chore, choreID).Error
	return &chore, err
}

func (r choreRepositoryDB) GetChoresByRoomID(roomID uint) ([]entities.Chore, error) {
	var chores []entities.Chore
	err := r.db.Where("room_id = ?", roomID).
		Preload("ChoreRotations.User").
		Find(&chores).Error
	return chores, err
}

func (r choreRepositoryDB) UpdateChore(chore *entities.Chore) error {
	return r.db.Save(chore).Error
}

func (r choreRepositoryDB) DeleteChore(choreID uint) error {
	return r.db.Delete(&entities.Chore{}, choreID).Error
}

// * assignment operations
func (r choreRepositoryDB) CreateChoreAssignment(assignment *entities.ChoreAssignment) error {
	return r.db.Create(assignment).Error
}

func (r choreRepositoryDB) GetAssignmentByID(assignmentID uint) (*entities.ChoreAssignment, error) {
	var assignment entities.ChoreAssignment
	err := r.db.Preload("Chore").Preload("User").First(&assignment, assignmentID).Error
	return &assignment, err
}

func (r choreRepositoryDB) GetAssignmentsByDateRange(roomID uint, startDate, endDate time.Time) ([]entities.ChoreAssignment, error) {
	var assignments []entities.ChoreAssignment
	err := r.db.Joins("JOIN chores ON chores.chore_id = chore_assignments.chore_id").
		Where("chores.room_id = ? AND chore_assignments.assigned_date BETWEEN ? AND ?", roomID, startDate, endDate).
		Preload("Chore").
		Preload("User").
		Order("chore_assignments.due_date_time ASC").
		Find(&assignments).Error
	return assignments, err
}

func (r choreRepositoryDB) GetTodayAssignments(roomID uint, date time.Time) ([]entities.ChoreAssignment, error) {
	startOfDay := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, date.Location())
	endOfDay := startOfDay.AddDate(0, 0, 1)

	var assignments []entities.ChoreAssignment
	err := r.db.Joins("JOIN chores ON chores.chore_id = chore_assignments.chore_id").
		Where("chores.room_id = ? AND chore_assignments.assigned_date BETWEEN ? AND ?", roomID, startOfDay, endOfDay).
		Preload("Chore").
		Preload("User").
		Order("chore_assignments.due_date_time ASC").
		Find(&assignments).Error
	return assignments, err
}

func (r choreRepositoryDB) GetUserAssignmentsByDateRange(userID uint, startDate, endDate time.Time) ([]entities.ChoreAssignment, error) {
	var assignments []entities.ChoreAssignment
	err := r.db.Where("user_id = ? AND assigned_date BETWEEN ? AND ?", userID, startDate, endDate).
		Preload("Chore").
		Preload("User").
		Order("due_date_time ASC").
		Find(&assignments).Error
	return assignments, err
}

func (r choreRepositoryDB) UpdateAssignment(assignment *entities.ChoreAssignment) error {
	return r.db.Save(assignment).Error
}

// * rotation operations
func (r choreRepositoryDB) CreateRotationUser(rotation *entities.ChoreRotationUser) error {
	return r.db.Create(rotation).Error
}

func (r choreRepositoryDB) GetRotationUsersByChoreID(choreID uint) ([]entities.ChoreRotationUser, error) {
	var rotations []entities.ChoreRotationUser
	err := r.db.Where("chore_id = ?", choreID).
		Preload("User").
		Order("rotation_order ASC").
		Find(&rotations).Error
	return rotations, err
}

func (r choreRepositoryDB) DeleteRotationUsersByChoreID(choreID uint) error {
	return r.db.Where("chore_id = ?", choreID).Delete(&entities.ChoreRotationUser{}).Error
}

func (r choreRepositoryDB) GetNextAssignedUserInRotation(choreID uint, lastAssignedUserID uint) (*entities.ChoreRotationUser, error) {
	// * find current user rotation order
	var currentRotation entities.ChoreRotationUser
	err := r.db.Where("chore_id = ? AND user_id = ?", choreID, lastAssignedUserID).First(&currentRotation).Error
	if err != nil {
		// * if user not found in rotation, get first user
		err = r.db.Where("chore_id = ?", choreID).
			Order("rotation_order ASC").
			First(&currentRotation).Error
		return &currentRotation, err
	}

	// * get next user in rotation
	var nextRotation entities.ChoreRotationUser
	err = r.db.Where("chore_id = ? AND rotation_order > ?", choreID, *currentRotation.RotationOrder).
		Order("rotation_order ASC").
		First(&nextRotation).Error

	if err != nil {
		// * if no next user, get first user (loop back)
		err = r.db.Where("chore_id = ?", choreID).
			Order("rotation_order ASC").
			First(&nextRotation).Error
	}

	return &nextRotation, err
}

// * status and scoring operations
func (r choreRepositoryDB) MarkAssignmentMissed(assignmentID uint) error {
	return r.db.Model(&entities.ChoreAssignment{}).
		Where("chore_assignment_id = ?", assignmentID).
		Updates(map[string]interface{}{
			"status": "missed",
		}).Error
}

func (r choreRepositoryDB) GetPendingAssignments() ([]entities.ChoreAssignment, error) {
	var assignments []entities.ChoreAssignment
	err := r.db.Where("status = ?", "pending").
		Preload("Chore").
		Preload("User").
		Find(&assignments).Error
	return assignments, err
}

func (r choreRepositoryDB) GetOverdueAssignments(currentTime time.Time) ([]entities.ChoreAssignment, error) {
	var assignments []entities.ChoreAssignment
	err := r.db.Where("status = ? AND due_date_time < ?", "pending", currentTime).
		Preload("Chore").
		Preload("User").
		Find(&assignments).Error
	return assignments, err
}

func (r choreRepositoryDB) GetAssignmentsForRoomOnDate(roomID uint, date time.Time) ([]entities.ChoreAssignment, error) {
	var rows []entities.ChoreAssignment
	qDate := date.Format("2006-01-02")

	err := r.db.
		Preload("Chore").
		Preload("User").
		Joins("JOIN chores ON chores.chore_id = chore_assignments.chore_id").
		Where("chores.room_id = ?", roomID).
		// Filter by DUE date (date part of due_date_time)
		Where("DATE(chore_assignments.due_date_time) = ?", qDate).
		// If you prefer ASSIGNED date instead, use:
		// Where("DATE(chore_assignments.assigned_date) = ?", qDate).
		Find(&rows).Error

	return rows, err
}

func (r choreRepositoryDB) GetAssignmentsForRoomOnDateByUser(roomID, userID uint, date time.Time) ([]entities.ChoreAssignment, error) {
	var rows []entities.ChoreAssignment
	qDate := date.Format("2006-01-02")

	err := r.db.
		Preload("Chore").
		Preload("User").
		Joins("JOIN chores ON chores.chore_id = chore_assignments.chore_id").
		Where("chores.room_id = ?", roomID).
		Where("chore_assignments.user_id = ?", userID).
		Where("DATE(chore_assignments.due_date_time) = ?", qDate).
		Find(&rows).Error

	return rows, err
}

func (r choreRepositoryDB) UpdateAssignedDate(assignmentIDs []uint, newDate time.Time) error {
	return r.db.Model(&entities.ChoreAssignment{}).
		Where("chore_assignment_id IN ?", assignmentIDs).
		Update("assigned_date", newDate).Error
}
