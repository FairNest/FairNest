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

type userDashboardSplitService struct {
	repo repository.UserDashboardRepository
}

func NewUserDashboardSplitService(repo repository.UserDashboardRepository) UserDashboardService {
	return &userDashboardSplitService{repo: repo}
}

// 1. GetUserProgress - fetch progress data by counting items
func (s *userDashboardSplitService) GetUserProgress(userID uint) (*dtos.GetUserProgressResponse, error) {
	// Get today's chores
	allChores, err := s.repo.GetUserChoresForToday(userID)
	if err != nil {
		log.Printf("Error getting today's chores: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch chores")
	}

	completedChores, err := s.repo.GetUserCompletedChoresForToday(userID)
	if err != nil {
		log.Printf("Error getting completed chores: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch completed chores")
	}

	// Get today's payments
	allPayments, err := s.repo.GetUserPaymentsDueToday(userID)
	if err != nil {
		log.Printf("Error getting today's payments: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch payments")
	}

	completedPayments, err := s.repo.GetUserCompletedPaymentsDueToday(userID)
	if err != nil {
		log.Printf("Error getting completed payments: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch completed payments")
	}

	totalTasks := len(allChores)
	completedTasks := len(completedChores)
	totalPayments := len(allPayments)
	completedPaymentsCount := len(completedPayments)

	overallCompleted := completedTasks + completedPaymentsCount
	overallTotal := totalTasks + totalPayments

	var progressPercentage float64
	if overallTotal > 0 {
		progressPercentage = (float64(overallCompleted) / float64(overallTotal)) * 100.0
	}

	return &dtos.GetUserProgressResponse{
		CompletedTasks:     completedTasks,
		TotalTasks:         totalTasks,
		CompletedPayments:  completedPaymentsCount,
		TotalPayments:      totalPayments,
		OverallCompleted:   overallCompleted,
		OverallTotal:       overallTotal,
		ProgressPercentage: progressPercentage,
	}, nil
}

// 2. GetUserTasksToday - fetch today's unfinished tasks + payments (SEPARATED)
func (s *userDashboardSplitService) GetUserTasksToday(userID uint) (*dtos.GetUserTasksSeparatedResponse, error) {
	chores, err := s.repo.GetUserChoresForToday(userID)
	if err != nil {
		log.Printf("Error getting today's chores: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch today's chores")
	}

	payments, err := s.repo.GetUserPaymentsDueToday(userID)
	if err != nil {
		log.Printf("Error getting today's payments: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch today's payments")
	}

	// Filter out completed items for "today" view
	var unfinishedChores []entities.ChoreAssignment
	for _, chore := range chores {
		if chore.Status == nil || *chore.Status != "completed" {
			unfinishedChores = append(unfinishedChores, chore)
		}
	}

	var unfinishedPayments []entities.Transaction
	for _, payment := range payments {
		if payment.TransactionStatus == nil || !*payment.TransactionStatus {
			unfinishedPayments = append(unfinishedPayments, payment)
		}
	}

	return &dtos.GetUserTasksSeparatedResponse{
		Chores:   mapChoresToChoreItems(unfinishedChores),
		Finances: mapPaymentsToFinanceItems(unfinishedPayments),
	}, nil
}

// 3. GetUserTasksCompleted - fetch today's completed tasks + payments (SEPARATED)
func (s *userDashboardSplitService) GetUserTasksCompleted(userID uint) (*dtos.GetUserTasksSeparatedResponse, error) {
	chores, err := s.repo.GetUserCompletedChoresForToday(userID)
	if err != nil {
		log.Printf("Error getting completed chores: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch completed chores")
	}

	payments, err := s.repo.GetUserCompletedPaymentsDueToday(userID)
	if err != nil {
		log.Printf("Error getting completed payments: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch completed payments")
	}

	return &dtos.GetUserTasksSeparatedResponse{
		Chores:   mapChoresToChoreItems(chores),
		Finances: mapPaymentsToFinanceItems(payments),
	}, nil
}

// 4. GetUserTasksUpcoming - fetch upcoming tasks + payments (next 7 days) (SEPARATED)
func (s *userDashboardSplitService) GetUserTasksUpcoming(userID uint) (*dtos.GetUserTasksSeparatedResponse, error) {
	today := time.Now()
	startOfTomorrow := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location()).AddDate(0, 0, 1)
	endOfNext7Days := startOfTomorrow.AddDate(0, 0, 7)

	chores, err := s.repo.GetUserUpcomingChores(userID, startOfTomorrow, endOfNext7Days)
	if err != nil {
		log.Printf("Error getting upcoming chores: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch upcoming chores")
	}

	payments, err := s.repo.GetUserUpcomingPayments(userID, startOfTomorrow, endOfNext7Days)
	if err != nil {
		log.Printf("Error getting upcoming payments: %v", err)
		return nil, fiber.NewError(fiber.StatusInternalServerError, "Failed to fetch upcoming payments")
	}

	return &dtos.GetUserTasksSeparatedResponse{
		Chores:   mapChoresToChoreItems(chores),
		Finances: mapPaymentsToFinanceItems(payments),
	}, nil
}

// Helper: Map chores to ChoreItem (separate type for chores)
func mapChoresToChoreItems(chores []entities.ChoreAssignment) []dtos.UserChoreItem {
	items := make([]dtos.UserChoreItem, 0, len(chores))
	for _, chore := range chores {
		if chore.Chore == nil {
			continue
		}

		var dueDate string
		if chore.AssignedDate != nil {
			dueDate = chore.AssignedDate.Format("2006-01-02")
		}

		status := "pending"
		if chore.Status != nil {
			status = *chore.Status
		}

		// Build reminder repeat text
		reminderRepeat := "No repeat"
		if chore.Chore.ReminderDayOfWeek != nil {
			reminderRepeat = "Every " + *chore.Chore.ReminderDayOfWeek
		}

		// Assigned user info
		var assignedName, assignedAvatar *string
		if chore.User != nil {
			assignedName = chore.User.Username
			assignedAvatar = chore.User.UserPicture
		}

		// Points calculation
		points := 10
		if chore.Chore.ChoreScore != nil {
			points = *chore.Chore.ChoreScore
		}

		items = append(items, dtos.UserChoreItem{
			ChoreAssignmentID: v.UintValue(chore.ChoreAssignmentID),
			ChoreID:           v.UintValue(chore.ChoreID),
			Title:             v.StringValue(chore.Chore.ChoreTitle),
			Status:            status,
			DueDate:           dueDate,
			DueTime:           chore.Chore.DueTime,
			Category:          chore.Chore.Category,
			Points:            points,
			AssignedName:      assignedName,
			AssignedAvatar:    assignedAvatar,
			AutoRotate:        chore.Chore.AutoRotate,
			Recurrence:        chore.Chore.Recurrence,
			ReminderTime:      chore.Chore.ReminderTime,
			ReminderRepeat:    &reminderRepeat,
		})
	}
	return items
}

// Helper: Map payments to FinanceItem (separate type for finances)
func mapPaymentsToFinanceItems(payments []entities.Transaction) []dtos.UserFinanceItem {
	items := make([]dtos.UserFinanceItem, 0, len(payments))
	for _, payment := range payments {
		if payment.Finance == nil {
			continue
		}

		var dueDate string
		if payment.Finance.DueDate != nil {
			dueDate = payment.Finance.DueDate.Format("2006-01-02")
		}

		status := "pending"
		if payment.TransactionStatus != nil && *payment.TransactionStatus {
			status = "completed"
		}

		// Check if overdue
		if payment.Finance.DueDate != nil && payment.Finance.DueDate.Before(time.Now()) && status == "pending" {
			status = "overdue"
		}

		// Payer info (who you pay to)
		var payToName, payToAvatar *string
		if payment.Payer != nil {
			payToName = payment.Payer.Username
			payToAvatar = payment.Payer.UserPicture
		}

		// Determine split type
		splitType := "even"
		var splitCount *int
		if payment.Finance.SplitType != nil && !*payment.Finance.SplitType {
			splitType = "custom"
		} else {
			splitCount = v.Ptr(2) // Default, can be enhanced
		}

		// Points calculation
		points := 10

		items = append(items, dtos.UserFinanceItem{
			TransactionID: v.UintValue(payment.TransactionID),
			FinanceID:     v.UintValue(payment.FinanceID),
			Title:         v.StringValue(payment.Finance.TitleName),
			Status:        status,
			DueDate:       dueDate,
			Category:      payment.Finance.Category,
			Points:        points,
			Amount:        payment.TotalAmount,
			TotalAmount:   payment.TotalAmount,
			SplitType:     &splitType,
			SplitCount:    splitCount,
			PayToName:     payToName,
			PayToAvatar:   payToAvatar,
			QRCode:        payment.QRCodeLinkImage,
			PaymentLink:   payment.PaymentLink,
		})
	}
	return items
}
