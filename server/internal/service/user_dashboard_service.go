package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"log"
	"time"

	"github.com/gofiber/fiber/v2"
)

type userDashboardService struct {
	userDashboardRepo repository.UserDashboardRepository
}

func NewUserDashboardService(userDashboardRepo repository.UserDashboardRepository) UserDashboardService {
	return &userDashboardService{
		userDashboardRepo: userDashboardRepo,
	}
}

func (s *userDashboardService) GetUserDashboard(userID uint) (*dtos.GetUserDashboardResponse, error) {
	// Get progress info for TODAY
	progressInfo, err := s.getYourProgress(userID)
	if err != nil {
		log.Printf("Error getting user progress: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch user progress")
	}

	// Get task summary (today + next 7 days)
	taskSummary, err := s.getTaskSummary(userID)
	if err != nil {
		log.Printf("Error getting task summary: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch task summary")
	}

	return &dtos.GetUserDashboardResponse{
		YourProgress: *progressInfo,
		TaskSummary:  *taskSummary,
	}, nil
}

// getYourProgress calculates user's progress for TODAY (chores + payments)
func (s *userDashboardService) getYourProgress(userID uint) (*dtos.YourProgressInfo, error) {
	// Get chores for today
	todayChores, err := s.userDashboardRepo.GetUserChoresForToday(userID)
	if err != nil {
		log.Printf("Error getting today's chores: %v", err)
		todayChores = []entities.ChoreAssignment{}
	}

	completedChores, err := s.userDashboardRepo.GetUserCompletedChoresForToday(userID)
	if err != nil {
		log.Printf("Error getting completed chores: %v", err)
		completedChores = []entities.ChoreAssignment{}
	}

	// Get payments for today
	todayPayments, err := s.userDashboardRepo.GetUserPaymentsDueToday(userID)
	if err != nil {
		log.Printf("Error getting today's payments: %v", err)
		todayPayments = []entities.Transaction{}
	}

	completedPayments, err := s.userDashboardRepo.GetUserCompletedPaymentsDueToday(userID)
	if err != nil {
		log.Printf("Error getting completed payments: %v", err)
		completedPayments = []entities.Transaction{}
	}

	// Calculate totals
	totalTasks := len(todayChores)
	completedTasks := len(completedChores)
	totalPayments := len(todayPayments)
	completedPaymentsCount := len(completedPayments)

	overallTotal := totalTasks + totalPayments
	overallCompleted := completedTasks + completedPaymentsCount

	// Calculate percentage
	var progressPercentage float64
	if overallTotal > 0 {
		progressPercentage = (float64(overallCompleted) / float64(overallTotal)) * 100.0
	}

	return &dtos.YourProgressInfo{
		CompletedTasks:     completedTasks,
		TotalTasks:         totalTasks,
		CompletedPayments:  completedPaymentsCount,
		TotalPayments:      totalPayments,
		OverallCompleted:   overallCompleted,
		OverallTotal:       overallTotal,
		ProgressPercentage: progressPercentage,
	}, nil
}

// getTaskSummary categorizes tasks and payments
func (s *userDashboardService) getTaskSummary(userID uint) (*dtos.TaskSummaryInfo, error) {
	today := time.Now()
	startOfToday := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	endOfToday := startOfToday.AddDate(0, 0, 1)

	// Next 7 days (excluding today)
	startOfTomorrow := endOfToday
	endOfNext7Days := startOfTomorrow.AddDate(0, 0, 7)

	// Get today's unfinished chores
	todayChores, _ := s.userDashboardRepo.GetUserChoresForToday(userID)
	todayUnfinishedChores := filterUnfinishedChores(todayChores)

	// Get today's completed chores
	completedChores, _ := s.userDashboardRepo.GetUserCompletedChoresForToday(userID)

	// Get upcoming unfinished chores (next 7 days)
	upcomingChores, _ := s.userDashboardRepo.GetUserUpcomingChores(userID, startOfTomorrow, endOfNext7Days)

	// Get today's unfinished payments
	todayPayments, _ := s.userDashboardRepo.GetUserPaymentsDueToday(userID)
	todayUnfinishedPayments := filterUnfinishedPayments(todayPayments)

	// Get today's completed payments
	completedPayments, _ := s.userDashboardRepo.GetUserCompletedPaymentsDueToday(userID)

	// Get upcoming unfinished payments (next 7 days)
	upcomingPayments, _ := s.userDashboardRepo.GetUserUpcomingPayments(userID, startOfTomorrow, endOfNext7Days)

	// Build item lists
	todayUnfinishedItems := append(
		mapChoresToItems(todayUnfinishedChores),
		mapPaymentsToItems(todayUnfinishedPayments)...,
	)

	completedItems := append(
		mapChoresToItems(completedChores),
		mapPaymentsToItems(completedPayments)...,
	)

	upcomingUnfinishedItems := append(
		mapChoresToItems(upcomingChores),
		mapPaymentsToItems(upcomingPayments)...,
	)

	return &dtos.TaskSummaryInfo{
		TodayUnfinishedCount:    len(todayUnfinishedItems),
		CompletedCount:          len(completedItems),
		UpcomingUnfinishedCount: len(upcomingUnfinishedItems),
		TodayUnfinishedItems:    todayUnfinishedItems,
		CompletedItems:          completedItems,
		UpcomingUnfinishedItems: upcomingUnfinishedItems,
	}, nil
}

// Helper functions
func filterUnfinishedChores(chores []entities.ChoreAssignment) []entities.ChoreAssignment {
	var unfinished []entities.ChoreAssignment
	for _, chore := range chores {
		if chore.Status != nil && (*chore.Status == "pending" || *chore.Status == "overdue") {
			unfinished = append(unfinished, chore)
		}
	}
	return unfinished
}

func filterUnfinishedPayments(payments []entities.Transaction) []entities.Transaction {
	var unfinished []entities.Transaction
	for _, payment := range payments {
		if payment.TransactionStatus != nil && !*payment.TransactionStatus {
			unfinished = append(unfinished, payment)
		}
	}
	return unfinished
}

func mapChoresToItems(chores []entities.ChoreAssignment) []dtos.UserDashboardItem {
	items := make([]dtos.UserDashboardItem, 0, len(chores))
	for _, chore := range chores {
		if chore.Chore == nil {
			continue
		}

		var dueDate string
		if chore.AssignedDate != nil {
			dueDate = chore.AssignedDate.Format("2006-01-02")
		}

		var completedAt *string
		if chore.CompletedAt != nil {
			ca := chore.CompletedAt.Format(time.RFC3339)
			completedAt = &ca
		}

		status := "pending"
		if chore.Status != nil {
			status = *chore.Status
		}

		items = append(items, dtos.UserDashboardItem{
			ItemType:    "chore",
			ItemID:      v.UintValue(chore.ChoreAssignmentID),
			Title:       v.StringValue(chore.Chore.ChoreTitle),
			Description: chore.Chore.ChoreDescription,
			DueDate:     dueDate,
			DueTime:     chore.Chore.DueTime,
			Amount:      nil,
			Category:    chore.Chore.Category,
			Status:      status,
			CompletedAt: completedAt,
		})
	}
	return items
}

func mapPaymentsToItems(payments []entities.Transaction) []dtos.UserDashboardItem {
	items := make([]dtos.UserDashboardItem, 0, len(payments))
	for _, payment := range payments {
		if payment.Finance == nil {
			continue
		}

		var dueDate string
		if payment.Finance.DueDate != nil {
			dueDate = payment.Finance.DueDate.Format("2006-01-02")
		}

		var completedAt *string
		if payment.PaidAt != nil {
			pa := payment.PaidAt.Format(time.RFC3339)
			completedAt = &pa
		}

		status := "pending"
		if payment.TransactionStatus != nil && *payment.TransactionStatus {
			status = "completed"
		}

		items = append(items, dtos.UserDashboardItem{
			ItemType:    "payment",
			ItemID:      v.UintValue(payment.TransactionID),
			Title:       v.StringValue(payment.Finance.TitleName),
			Description: nil,
			DueDate:     dueDate,
			DueTime:     nil,
			Amount:      payment.TotalAmount,
			Category:    payment.Finance.Category,
			Status:      status,
			CompletedAt: completedAt,
		})
	}
	return items
}
