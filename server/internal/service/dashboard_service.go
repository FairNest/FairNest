package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/repository"
	"log"

	"github.com/gofiber/fiber/v2"
)

type dashboardService struct {
	dashboardRepo repository.DashboardRepository
	lifestyleRepo repository.LifestyleRepository
	lifestyleSer  LifestyleService
}

func NewDashboardService(
	dashboardRepo repository.DashboardRepository,
	lifestyleRepo repository.LifestyleRepository,
	lifestyleSer LifestyleService,
) DashboardService {
	return &dashboardService{
		dashboardRepo: dashboardRepo,
		lifestyleRepo: lifestyleRepo,
		lifestyleSer:  lifestyleSer,
	}
}

func (s *dashboardService) GetRoomDashboard(roomID uint, currentUserID uint) (*dtos.GetRoomDashboardResponse, error) {
	// 1. Get Today Room Status
	roomStatus, err := s.getTodayRoomStatus(roomID)
	if err != nil {
		log.Printf("Error getting room status: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch room status")
	}

	// 2. Get Roommate Overview
	roommateOverview, err := s.getRoommateOverview(roomID, currentUserID)
	if err != nil {
		log.Printf("Error getting roommate overview: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch roommate overview")
	}

	return &dtos.GetRoomDashboardResponse{
		TodayRoomStatus:  *roomStatus,
		RoommateOverview: roommateOverview,
	}, nil
}

// getTodayRoomStatus fetches room-level statistics
func (s *dashboardService) getTodayRoomStatus(roomID uint) (*dtos.TodayRoomStatusResponse, error) {
	// Get room compatibility score (average)
	avgCompatibility, _, _, err := s.lifestyleSer.GetRoomAverageCompatibilityByRoomId(int(roomID))
	if err != nil {
		log.Printf("Error getting room compatibility: %v", err)
		// Default to 0 if error (e.g., not enough members)
		avgCompatibility = 0
	}

	// Convert percentage (0-100) to decimal (0-1)
	compatibilityScore := avgCompatibility / 100.0

	// Get chores progress for today
	completedChores, totalChores, err := s.dashboardRepo.GetRoomChoresStatsForToday(roomID)
	if err != nil {
		log.Printf("Error getting chores stats: %v", err)
		completedChores, totalChores = 0, 0
	}

	// Get finances progress for TODAY
	completedFinances, totalFinances, err := s.dashboardRepo.GetRoomFinanceStatsForToday(roomID)
	if err != nil {
		log.Printf("Error getting finance stats: %v", err)
		completedFinances, totalFinances = 0, 0
	}

	return &dtos.TodayRoomStatusResponse{
		RoomCompatibility: dtos.RoomCompatibilityInfo{
			Score: compatibilityScore,
		},
		ChoresProgress: dtos.ChoresProgressInfo{
			CompletedTasks: completedChores,
			TotalTasks:     totalChores,
		},
		FinancesProgress: dtos.FinancesProgressInfo{
			CompletedFinances: completedFinances,
			TotalFinances:     totalFinances,
		},
	}, nil
}

// getRoommateOverview fetches individual roommate statistics
func (s *dashboardService) getRoommateOverview(roomID uint, currentUserID uint) ([]dtos.RoommateOverviewItem, error) {
	// Get all room members
	members, err := s.dashboardRepo.GetRoomMembersByRoomID(roomID)
	if err != nil {
		return nil, err
	}

	// Filter out current user
	var roommates []dtos.RoommateOverviewItem
	var roommateIDs []uint

	for _, member := range members {
		if member.UserID != nil && *member.UserID != currentUserID {
			roommateIDs = append(roommateIDs, *member.UserID)
		}
	}

	// Get compatibility scores between current user and each roommate
	compatibilityMatches, err := s.lifestyleSer.GetCompatibilityMatchesByRoomAndUser(int(roomID), int(currentUserID))
	if err != nil {
		log.Printf("Error getting compatibility matches: %v", err)
		// Continue without compatibility scores
	}

	// Create a map for quick compatibility lookup
	compatibilityMap := make(map[uint]float64)
	if compatibilityMatches.Matches != nil {
		for _, match := range compatibilityMatches.Matches {
			compatibilityMap[match.UserID] = match.Score
		}
	}

	// Get finance amounts owed by roommates to current user
	owedAmounts, err := s.dashboardRepo.GetOwedAmountByRoommates(currentUserID, roommateIDs)
	if err != nil {
		log.Printf("Error getting owed amounts: %v", err)
		owedAmounts = make(map[uint]int)
	}

	// Build roommate overview items
	for _, member := range members {
		if member.UserID == nil || *member.UserID == currentUserID {
			continue
		}

		userID := *member.UserID

		// Get chore statistics for this roommate TODAY
		completedTasks, _ := s.dashboardRepo.GetCompletedChoresCountByUserIDToday(userID)
		totalTasks, _ := s.dashboardRepo.GetTotalChoresCountByUserIDToday(userID)

		// Get compatibility score
		compatScore := compatibilityMap[userID]

		// Get finance amount (only if they owe current user)
		financeAmount := owedAmounts[userID]
		financeStatus := "owes_you" // Always "owes_you" as per requirement

		// Only include if there's an amount owed (or always include with 0)
		// Based on your Flutter code, it seems all roommates should be shown
		name := "Unknown"
		if member.Username != nil {
			name = *member.Username
		}

		roommates = append(roommates, dtos.RoommateOverviewItem{
			UserID:             userID,
			Name:               name,
			UserPicture:        member.UserPicture,
			CompatibilityScore: compatScore,
			TasksCompleted:     completedTasks,
			TasksTotal:         totalTasks,
			FinanceAmount:      financeAmount,
			FinanceStatus:      financeStatus,
		})
	}

	return roommates, nil
}
