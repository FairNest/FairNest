package repository

import (
	"fairnest/internal/entities"
	"time"

	"gorm.io/gorm"
)

type dashboardRepositoryDB struct {
	db *gorm.DB
}

func NewDashboardRepositoryDB(db *gorm.DB) dashboardRepositoryDB {
	return dashboardRepositoryDB{db: db}
}

// GetRoomMembersByRoomID returns all users who are members of the specified room
func (r dashboardRepositoryDB) GetRoomMembersByRoomID(roomID uint) ([]entities.User, error) {
	var users []entities.User
	err := r.db.
		Table("users").
		Select("users.user_id, users.username, users.user_picture").
		Joins("JOIN room_members ON room_members.user_id = users.user_id").
		Where("room_members.room_id = ?", roomID).
		Scan(&users).Error

	return users, err
}

// GetCompletedChoresCountByUserIDToday returns count of completed chores for user TODAY
func (r dashboardRepositoryDB) GetCompletedChoresCountByUserIDToday(userID uint) (int, error) {
	var count int64
	today := time.Now()
	startOfDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	endOfDay := startOfDay.AddDate(0, 0, 1)

	err := r.db.Model(&entities.ChoreAssignment{}).
		Where("user_id = ? AND status = ? AND assigned_date >= ? AND assigned_date < ?",
			userID, "completed", startOfDay, endOfDay).
		Count(&count).Error

	return int(count), err
}

// GetTotalChoresCountByUserIDToday returns total chores assigned to user TODAY
func (r dashboardRepositoryDB) GetTotalChoresCountByUserIDToday(userID uint) (int, error) {
	var count int64
	today := time.Now()
	startOfDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	endOfDay := startOfDay.AddDate(0, 0, 1)

	err := r.db.Model(&entities.ChoreAssignment{}).
		Where("user_id = ? AND assigned_date >= ? AND assigned_date < ?",
			userID, startOfDay, endOfDay).
		Count(&count).Error

	return int(count), err
}

// GetRoomChoresStatsForToday returns today's chore completion stats for the entire room
func (r dashboardRepositoryDB) GetRoomChoresStatsForToday(roomID uint) (completed int, total int, err error) {
	today := time.Now()
	startOfDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	endOfDay := startOfDay.AddDate(0, 0, 1)

	// Total chores for today
	var totalCount int64
	err = r.db.Model(&entities.ChoreAssignment{}).
		Joins("JOIN chores ON chores.chore_id = chore_assignments.chore_id").
		Where("chores.room_id = ? AND chore_assignments.assigned_date >= ? AND chore_assignments.assigned_date < ?",
			roomID, startOfDay, endOfDay).
		Count(&totalCount).Error

	if err != nil {
		return 0, 0, err
	}

	// Completed chores for today
	var completedCount int64
	err = r.db.Model(&entities.ChoreAssignment{}).
		Joins("JOIN chores ON chores.chore_id = chore_assignments.chore_id").
		Where("chores.room_id = ? AND chore_assignments.assigned_date >= ? AND chore_assignments.assigned_date < ? AND chore_assignments.status = ?",
			roomID, startOfDay, endOfDay, "completed").
		Count(&completedCount).Error

	if err != nil {
		return 0, 0, err
	}

	return int(completedCount), int(totalCount), nil
}

// GetRoomFinanceStatsForToday returns finance statistics for transactions due TODAY
func (r dashboardRepositoryDB) GetRoomFinanceStatsForToday(roomID uint) (completed int, total int, err error) {
	// Get all user IDs in the room
	var userIDs []uint
	err = r.db.Model(&entities.RoomMember{}).
		Where("room_id = ?", roomID).
		Pluck("user_id", &userIDs).Error

	if err != nil || len(userIDs) == 0 {
		return 0, 0, err
	}

	// Get today's date range
	today := time.Now()
	startOfDay := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	endOfDay := startOfDay.AddDate(0, 0, 1)

	// Total transactions where either payer or debtor is in the room AND due date is today
	var totalCount int64
	err = r.db.Model(&entities.Transaction{}).
		Joins("JOIN finances ON finances.finance_id = transactions.finance_id").
		Where("(transactions.payer_id IN ? OR transactions.debtor_id IN ?) AND finances.due_date >= ? AND finances.due_date < ?",
			userIDs, userIDs, startOfDay, endOfDay).
		Count(&totalCount).Error

	if err != nil {
		return 0, 0, err
	}

	// Completed (settled) transactions due today
	var completedCount int64
	err = r.db.Model(&entities.Transaction{}).
		Joins("JOIN finances ON finances.finance_id = transactions.finance_id").
		Where("(transactions.payer_id IN ? OR transactions.debtor_id IN ?) AND finances.due_date >= ? AND finances.due_date < ? AND transactions.transaction_status = ?",
			userIDs, userIDs, startOfDay, endOfDay, true).
		Count(&completedCount).Error

	if err != nil {
		return 0, 0, err
	}

	return int(completedCount), int(totalCount), nil
}

// GetOwedAmountByRoommates returns amounts owed TO the current user BY each roommate
// Only includes positive amounts (where roommate owes current user)
func (r dashboardRepositoryDB) GetOwedAmountByRoommates(currentUserID uint, roommateIDs []uint) (map[uint]int, error) {
	result := make(map[uint]int)

	if len(roommateIDs) == 0 {
		return result, nil
	}

	// Get all unsettled transactions between current user and roommates
	var transactions []entities.Transaction
	err := r.db.Model(&entities.Transaction{}).
		Where("transaction_status = ?", false).
		Where("(payer_id = ? AND debtor_id IN ?) OR (debtor_id = ? AND payer_id IN ?)",
			currentUserID, roommateIDs, currentUserID, roommateIDs).
		Find(&transactions).Error

	if err != nil {
		return nil, err
	}

	// Calculate net balance for each roommate
	balances := make(map[uint]int)
	for _, t := range transactions {
		if t.PayerID == nil || t.DebtorID == nil || t.TotalAmount == nil {
			continue
		}

		payer := *t.PayerID
		debtor := *t.DebtorID
		amount := *t.TotalAmount

		if payer == currentUserID {
			// Current user paid, so roommate (debtor) owes us
			balances[debtor] += amount
		} else if debtor == currentUserID {
			// Current user is debtor, so we owe the roommate (payer)
			balances[payer] -= amount
		}
	}

	// Only return positive balances (amounts owed TO current user)
	for roommateID, balance := range balances {
		if balance > 0 {
			result[roommateID] = balance
		}
	}

	return result, nil
}
