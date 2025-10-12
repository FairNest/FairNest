package repository

import "fairnest/internal/entities"

type DashboardRepository interface {
	// GetRoomMembersByRoomID returns all members in a room
	GetRoomMembersByRoomID(roomID uint) ([]entities.User, error)

	// GetCompletedChoresCountByUserIDToday returns count of completed chores for a user TODAY
	GetCompletedChoresCountByUserIDToday(userID uint) (int, error)

	// GetTotalChoresCountByUserIDToday returns total assigned chores for a user TODAY
	GetTotalChoresCountByUserIDToday(userID uint) (int, error)

	// GetRoomChoresStatsForToday returns today's chore statistics for the room
	GetRoomChoresStatsForToday(roomID uint) (completed int, total int, err error)

	// GetRoomFinanceStatsForToday returns finance statistics for the room with due date TODAY
	GetRoomFinanceStatsForToday(roomID uint) (completed int, total int, err error)

	// GetOwedAmountByRoommates returns amounts owed to the current user by each roommate (ALL TIME)
	// Returns map[roommateUserID]amount (only positive amounts where roommate owes current user)
	GetOwedAmountByRoommates(currentUserID uint, roommateIDs []uint) (map[uint]int, error)
}
