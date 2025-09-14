package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"fmt"
	"log"
	"strings"
	"time"
)

type choreService struct {
	choreRepo repository.ChoreRepository
	userSer   UserService
}

func NewChoreService(choreRepo repository.ChoreRepository, userSer UserService) choreService {
	return choreService{
		choreRepo: choreRepo,
		userSer:   userSer,
	}
}

func (s choreService) FetchAllChore() ([]entities.Chore, error) {
	chores, err := s.choreRepo.FetchAllChore()
	if err != nil {
		log.Println(err)
		return nil, err
	}

	choreResponses := []entities.Chore{}
	for _, chore := range chores {
		choreResponse := entities.Chore{
			ChoreID:           chore.ChoreID,
			RoomID:            chore.RoomID,
			ChoreTitle:        chore.ChoreTitle,
			ChoreDescription:  chore.ChoreDescription,
			Category:          chore.Category,
			DueDayOfWeek:      chore.DueDayOfWeek,
			DueTime:           chore.DueTime,
			ReminderDayOfWeek: chore.ReminderDayOfWeek,
			ReminderTime:      chore.ReminderTime,
			Recurrence:        chore.Recurrence,
			AutoRotate:        chore.AutoRotate,
			ChoreScore:        chore.ChoreScore,
			CreatedAt:         chore.CreatedAt,
			UpdatedAt:         chore.UpdatedAt,
		}
		choreResponses = append(choreResponses, choreResponse)
	}
	return choreResponses, nil
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////

// * create new chore
func (s choreService) CreateChore(roomID uint, request *dtos.CreateChoreRequest) (*dtos.CreateChoreResponse, error) {
	now := time.Now()
	chore := &entities.Chore{
		RoomID:            v.Ptr(roomID),
		ChoreTitle:        request.ChoreTitle,
		ChoreDescription:  request.ChoreDescription,
		Category:          request.Category,
		DueDayOfWeek:      request.DueDayOfWeek,
		DueTime:           request.DueTime,
		ReminderDayOfWeek: request.ReminderDayOfWeek,
		ReminderTime:      request.ReminderTime,
		Recurrence:        request.Recurrence,
		AutoRotate:        request.AutoRotate,
		ChoreScore:        request.ChoreScore,
		CreatedAt:         now,
		UpdatedAt:         now,
	}

	err := s.choreRepo.CreateChore(chore)
	if err != nil {
		return nil, err
	}

	// * setup rotation users if auto rotate is enabled
	if v.BoolValue(request.AutoRotate) && len(request.AssignedUserIDs) > 0 {
		for i, userID := range request.AssignedUserIDs {
			rotation := &entities.ChoreRotationUser{
				ChoreID:       chore.ChoreID,
				UserID:        v.Ptr(userID),
				RotationOrder: v.Ptr(i + 1),
			}
			err = s.choreRepo.CreateRotationUser(rotation)
			if err != nil {
				log.Printf("failed to create rotation user: %v", err)
			}
		}
	}

	// * generate assignments for current week and next 3 weeks
	startDate := s.getStartOfWeek(now)
	endDate := startDate.AddDate(0, 0, 28) // * 4 weeks
	err = s.GenerateChoreAssignments(*chore.ChoreID, startDate, endDate)
	if err != nil {
		log.Printf("failed to generate initial assignments: %v", err)
	}

	return &dtos.CreateChoreResponse{
		ChoreID:           chore.ChoreID,
		RoomID:            chore.RoomID,
		ChoreTitle:        chore.ChoreTitle,
		ChoreDescription:  chore.ChoreDescription,
		Category:          chore.Category,
		DueDayOfWeek:      chore.DueDayOfWeek,
		DueTime:           chore.DueTime,
		ReminderDayOfWeek: chore.ReminderDayOfWeek,
		ReminderTime:      chore.ReminderTime,
		Recurrence:        chore.Recurrence,
		AutoRotate:        chore.AutoRotate,
		ChoreScore:        chore.ChoreScore,
		CreatedAt:         v.Ptr(now.Format(time.RFC3339)),
	}, nil
}

// * get all chores for room
func (s choreService) GetChoresByRoomID(roomID uint) ([]dtos.GetRoomChoresResponse, error) {
	chores, err := s.choreRepo.GetChoresByRoomID(roomID)
	if err != nil {
		return nil, err
	}

	responses := make([]dtos.GetRoomChoresResponse, 0, len(chores))
	for _, chore := range chores {
		// * get assigned users for this chore
		assignedUsers := make([]dtos.AssignedUserInfo, 0)
		if v.BoolValue(chore.AutoRotate) {
			rotations, err := s.choreRepo.GetRotationUsersByChoreID(*chore.ChoreID)
			if err == nil {
				for _, rotation := range rotations {
					if rotation.User != nil {
						assignedUsers = append(assignedUsers, dtos.AssignedUserInfo{
							UserID:      rotation.User.UserID,
							Username:    rotation.User.Username,
							UserPicture: rotation.User.UserPicture,
						})
					}
				}
			}
		}

		responses = append(responses, dtos.GetRoomChoresResponse{
			ChoreID:           chore.ChoreID,
			ChoreTitle:        chore.ChoreTitle,
			ChoreDescription:  chore.ChoreDescription,
			Category:          chore.Category,
			DueDayOfWeek:      chore.DueDayOfWeek,
			DueTime:           chore.DueTime,
			ReminderDayOfWeek: chore.ReminderDayOfWeek,
			ReminderTime:      chore.ReminderTime,
			Recurrence:        chore.Recurrence,
			AutoRotate:        chore.AutoRotate,
			ChoreScore:        chore.ChoreScore,
			AssignedUsers:     assignedUsers,
			CreatedAt:         v.Ptr(chore.CreatedAt),
		})
	}

	return responses, nil
}

// * get calendar view of chores
func (s choreService) GetChoreCalendar(roomID uint, startDate, endDate time.Time) ([]dtos.GetChoreCalendarResponse, error) {
	assignments, err := s.choreRepo.GetAssignmentsByDateRange(roomID, startDate, endDate)
	if err != nil {
		return nil, err
	}

	// * group assignments by date
	dateMap := make(map[string][]dtos.ChoreCalendarItemResponse)
	for _, assignment := range assignments {
		if assignment.AssignedDate == nil {
			continue
		}

		dateStr := assignment.AssignedDate.Format("2006-01-02")

		choreItem := dtos.ChoreCalendarItemResponse{
			ChoreAssignmentID: assignment.ChoreAssignmentID,
			ChoreID:           assignment.ChoreID,
			ChoreTitle:        assignment.Chore.ChoreTitle,
			Category:          assignment.Chore.Category,
			DueTime:           assignment.Chore.DueTime,
			Status:            assignment.Status,
			ChoreScore:        assignment.Chore.ChoreScore,
		}

		if assignment.User != nil {
			choreItem.AssignedUser = &dtos.AssignedUserInfo{
				UserID:      assignment.User.UserID,
				Username:    assignment.User.Username,
				UserPicture: assignment.User.UserPicture,
			}
		}

		dateMap[dateStr] = append(dateMap[dateStr], choreItem)
	}

	// * convert map to response format
	responses := make([]dtos.GetChoreCalendarResponse, 0)
	for dateStr, chores := range dateMap {
		responses = append(responses, dtos.GetChoreCalendarResponse{
			Date:   v.Ptr(dateStr),
			Chores: chores,
		})
	}

	return responses, nil
}

// * get today's chores for specific room and user
func (s choreService) GetTodayChores(roomID uint, userID uint) ([]dtos.GetTodayChoresResponse, error) {
	today := time.Now()
	assignments, err := s.choreRepo.GetTodayAssignments(roomID, today)
	if err != nil {
		return nil, err
	}

	responses := make([]dtos.GetTodayChoresResponse, 0, len(assignments))
	for _, assignment := range assignments {
		isMyTask := assignment.UserID != nil && *assignment.UserID == userID

		response := dtos.GetTodayChoresResponse{
			ChoreAssignmentID: assignment.ChoreAssignmentID,
			ChoreID:           assignment.ChoreID,
			Status:            assignment.Status,
			ChoreScore:        assignment.Chore.ChoreScore,
			IsMyTask:          v.Ptr(isMyTask),
		}

		if assignment.Chore != nil {
			response.ChoreTitle = assignment.Chore.ChoreTitle
			response.ChoreDescription = assignment.Chore.ChoreDescription
			response.Category = assignment.Chore.Category
			response.DueTime = assignment.Chore.DueTime
		}

		if assignment.User != nil {
			response.AssignedUser = &dtos.AssignedUserInfo{
				UserID:      assignment.User.UserID,
				Username:    assignment.User.Username,
				UserPicture: assignment.User.UserPicture,
			}
		}

		responses = append(responses, response)
	}

	return responses, nil
}

// * mark chore as completed
func (s choreService) MarkChoreComplete(userID uint, assignmentID uint) (*dtos.MarkChoreCompleteResponse, error) {
	assignment, err := s.choreRepo.GetAssignmentByID(assignmentID)
	if err != nil {
		return nil, fmt.Errorf("assignment not found: %v", err)
	}

	// * verify user can complete this assignment
	if assignment.UserID == nil || *assignment.UserID != userID {
		return nil, fmt.Errorf("user not authorized to complete this assignment")
	}

	// * check if already completed
	if assignment.Status != nil && *assignment.Status == "completed" {
		return nil, fmt.Errorf("assignment already completed")
	}

	// * mark as completed
	now := time.Now()
	assignment.Status = v.Ptr("completed")
	assignment.CompletedAt = &now
	assignment.ScoreEarned = assignment.Chore.ChoreScore

	err = s.choreRepo.UpdateAssignment(assignment)
	if err != nil {
		return nil, err
	}

	newScore, err := s.userSer.UpdateRoommateScore(userID, float64(*assignment.ScoreEarned))
	if err != nil {
		log.Printf("failed to update user roommate score for missed chore: %v", err)
	}

	return &dtos.MarkChoreCompleteResponse{
		ChoreAssignmentID: assignment.ChoreAssignmentID,
		Status:            assignment.Status,
		CompletedAt:       v.Ptr(now.Format(time.RFC3339)),
		ScoreEarned:       assignment.ScoreEarned,
		NewRoommateScore:  newScore,
	}, nil
}

// * generate assignments for a chore within date range
func (s choreService) GenerateChoreAssignments(choreID uint, startDate, endDate time.Time) error {
	chore, err := s.choreRepo.GetChoreByID(choreID)
	if err != nil {
		return err
	}

	if chore.DueDayOfWeek == nil || chore.DueTime == nil {
		return fmt.Errorf("chore missing due day or time")
	}

	dayOfWeek := s.parseDayOfWeek(*chore.DueDayOfWeek)
	dueTime := s.parseTime(*chore.DueTime)

	// * get rotation users if auto rotate
	var rotationUsers []entities.ChoreRotationUser
	if v.BoolValue(chore.AutoRotate) {
		rotationUsers, err = s.choreRepo.GetRotationUsersByChoreID(choreID)
		if err != nil || len(rotationUsers) == 0 {
			log.Printf("no rotation users found for chore %d", choreID)
			return nil
		}
	}

	currentDate := startDate
	rotationIndex := 0

	for currentDate.Before(endDate) || currentDate.Equal(endDate) {
		// * check if current day matches chore day
		if currentDate.Weekday() == dayOfWeek {
			// * create due date time
			dueDateTime := time.Date(currentDate.Year(), currentDate.Month(), currentDate.Day(),
				dueTime.Hour(), dueTime.Minute(), 0, 0, currentDate.Location())

			var assignedUserID *uint
			if len(rotationUsers) > 0 {
				assignedUserID = rotationUsers[rotationIndex%len(rotationUsers)].UserID
				rotationIndex++
			}

			assignment := &entities.ChoreAssignment{
				ChoreID:      v.Ptr(choreID),
				UserID:       assignedUserID,
				AssignedDate: &currentDate,
				DueDateTime:  &dueDateTime,
				Status:       v.Ptr("pending"),
			}

			err = s.choreRepo.CreateChoreAssignment(assignment)
			if err != nil {
				log.Printf("failed to create assignment: %v", err)
			}
		}
		currentDate = currentDate.AddDate(0, 0, 1)
	}

	return nil
}

// * update existing chore
func (s choreService) UpdateChore(choreID uint, request *dtos.EditChoreRequest) (*dtos.CreateChoreResponse, error) {
	chore, err := s.choreRepo.GetChoreByID(choreID)
	if err != nil {
		return nil, err
	}

	// * update chore fields
	chore.ChoreTitle = request.ChoreTitle
	chore.ChoreDescription = request.ChoreDescription
	chore.Category = request.Category
	chore.DueDayOfWeek = request.DueDayOfWeek
	chore.DueTime = request.DueTime
	chore.ReminderDayOfWeek = request.ReminderDayOfWeek
	chore.ReminderTime = request.ReminderTime
	chore.Recurrence = request.Recurrence
	chore.AutoRotate = request.AutoRotate
	chore.ChoreScore = request.ChoreScore
	chore.UpdatedAt = time.Now()

	err = s.choreRepo.UpdateChore(chore)
	if err != nil {
		return nil, err
	}

	now := time.Now()
	currentTime := s.getStartOfWeek(now)
	err = s.choreRepo.UpdateAssignedDate(choreID, currentTime)
	if err != nil {
		log.Printf("failed to update assigned date with current time: %v", err)
	}

	// * update rotation users
	if v.BoolValue(request.AutoRotate) {
		// * delete existing rotations
		err = s.choreRepo.DeleteRotationUsersByChoreID(choreID)
		if err != nil {
			log.Printf("failed to delete existing rotations: %v", err)
		}

		// * create new rotations
		for i, userID := range request.AssignedUserIDs {
			rotation := &entities.ChoreRotationUser{
				ChoreID:       v.Ptr(choreID),
				UserID:        v.Ptr(userID),
				RotationOrder: v.Ptr(i + 1),
			}
			err = s.choreRepo.CreateRotationUser(rotation)
			if err != nil {
				log.Printf("failed to create rotation user: %v", err)
			}
		}
	}

	return &dtos.CreateChoreResponse{
		ChoreID:           chore.ChoreID,
		RoomID:            chore.RoomID,
		ChoreTitle:        chore.ChoreTitle,
		ChoreDescription:  chore.ChoreDescription,
		Category:          chore.Category,
		DueDayOfWeek:      chore.DueDayOfWeek,
		DueTime:           chore.DueTime,
		ReminderDayOfWeek: chore.ReminderDayOfWeek,
		ReminderTime:      chore.ReminderTime,
		Recurrence:        chore.Recurrence,
		AutoRotate:        chore.AutoRotate,
		ChoreScore:        chore.ChoreScore,
		CreatedAt:         v.Ptr(chore.CreatedAt.Format(time.RFC3339)),
	}, nil
}

// * delete chore
func (s choreService) DeleteChore(choreID uint) error {
	return s.choreRepo.DeleteChore(choreID)
}

// * background process to generate weekly assignments
func (s choreService) GenerateWeeklyAssignments() error {
	// * this would be called by a cron job weekly
	log.Println("generating weekly chore assignments...")
	return nil
}

// * background process to handle missed chores
func (s choreService) ProcessMissedChores() error {
	now := time.Now()
	overdueAssignments, err := s.choreRepo.GetOverdueAssignments(now)
	if err != nil {
		return err
	}

	for _, assignment := range overdueAssignments {
		// * mark as missed and apply negative score
		assignment.Status = v.Ptr("missed")
		assignment.ScoreEarned = v.Ptr(-*assignment.Chore.ChoreScore) // * negative score

		err = s.choreRepo.UpdateAssignment(&assignment)
		if err != nil {
			log.Printf("failed to mark assignment as missed: %v", err)
			continue
		}

		// * update user score
		if assignment.UserID != nil {
			user, err := s.userSer.GetUserByUserId(int(*assignment.UserID))
			if err == nil {
				newScore := v.Float64Value(user.RoommateScore) + float64(*assignment.ScoreEarned)
				user.RoommateScore = v.Ptr(newScore)
				_, err := s.userSer.UpdateRoommateScore(*assignment.UserID, float64(*assignment.ScoreEarned))
				if err != nil {
					log.Printf("failed to update user roommate score for missed chore: %v", err)
				}
			}
		}
	}

	return nil
}

func (s choreService) GetRoomTasksForDate(roomID uint, date time.Time) ([]dtos.ChoreDayItem, error) {
	assignments, err := s.choreRepo.GetAssignmentsForRoomOnDate(roomID, date)
	if err != nil {
		return nil, err
	}
	return mapAssignmentsToDTO(assignments), nil
}

func (s choreService) GetMyTasksForDate(roomID, userID uint, date time.Time) ([]dtos.ChoreDayItem, error) {
	asg, err := s.choreRepo.GetAssignmentsForRoomOnDateByUser(roomID, userID, date)
	if err != nil {
		return nil, err
	}
	return mapAssignmentsToDTO(asg), nil
}

// * helper functions
func (s choreService) parseDayOfWeek(dayStr string) time.Weekday {
	switch strings.ToLower(dayStr) {
	case "sunday":
		return time.Sunday
	case "monday":
		return time.Monday
	case "tuesday":
		return time.Tuesday
	case "wednesday":
		return time.Wednesday
	case "thursday":
		return time.Thursday
	case "friday":
		return time.Friday
	case "saturday":
		return time.Saturday
	default:
		return time.Monday
	}
}

func (s choreService) parseTime(timeStr string) time.Time {
	// * parse "14:30" format
	t, err := time.Parse("15:04", timeStr)
	if err != nil {
		log.Printf("failed to parse time %s: %v", timeStr, err)
		return time.Date(0, 1, 1, 0, 0, 0, 0, time.UTC)
	}
	return t
}

func (s choreService) getStartOfWeek(t time.Time) time.Time {
	// * get monday of current week
	offset := int(time.Monday - t.Weekday())
	if offset > 0 {
		offset -= 7
	}
	return t.AddDate(0, 0, offset)
}

func sptr(s string) *string { return &s }

func mapAssignmentsToDTO(list []entities.ChoreAssignment) []dtos.ChoreDayItem {
	out := make([]dtos.ChoreDayItem, 0, len(list))
	for _, a := range list {
		item := dtos.ChoreDayItem{
			ChoreAssignmentID: a.ChoreAssignmentID,
		}

		// Dates
		if a.DueDateTime != nil {
			d := a.DueDateTime.Format("2006-01-02")
			item.DueDate = &d
		}

		// Status + completed_at (string RFC3339 if present)
		if a.Status != nil {
			item.Status = a.Status
		}
		if a.CompletedAt != nil {
			s := a.CompletedAt.Format(time.RFC3339)
			item.CompletedAt = &s
		}

		// Chore (exclude created_at/updated_at)
		if a.Chore != nil {
			c := a.Chore
			item.ChoreID = c.ChoreID
			item.RoomID = c.RoomID
			item.ChoreTitle = c.ChoreTitle
			item.ChoreDescription = c.ChoreDescription
			item.Category = c.Category
			item.DueDayOfWeek = c.DueDayOfWeek
			item.DueTime = c.DueTime
			item.ReminderDayOfWeek = c.ReminderDayOfWeek
			item.ReminderTime = c.ReminderTime
			item.Recurrence = c.Recurrence
			item.AutoRotate = c.AutoRotate
			item.ChoreScore = c.ChoreScore
		}

		// Assigned user
		if a.User != nil {
			u := a.User
			item.AssignedUser = &dtos.RoomUserInfo{
				UserID:      u.UserID,
				Username:    u.Username,
				UserPicture: u.UserPicture,
			}
		}

		out = append(out, item)
	}
	return out
}

func (s choreService) GetChoreDetailByID(choreID uint) (*dtos.GetChoreDetailByIDResponse, error) {
	chore, err := s.choreRepo.GetChoreByID(choreID)
	if err != nil {
		return nil, fmt.Errorf("chore not found: %v", err)
	}

	// Get assigned users for this chore
	assignedUsers := make([]dtos.AssignedUserInfo, 0)
	if v.BoolValue(chore.AutoRotate) {
		rotations, err := s.choreRepo.GetRotationUsersByChoreID(choreID)
		if err == nil {
			for _, rotation := range rotations {
				if rotation.User != nil {
					assignedUsers = append(assignedUsers, dtos.AssignedUserInfo{
						UserID:      rotation.User.UserID,
						Username:    rotation.User.Username,
						UserPicture: rotation.User.UserPicture,
					})
				}
			}
		}
	}

	// Convert to response struct with proper null handling
	response := &dtos.GetChoreDetailByIDResponse{
		ChoreID:           *chore.ChoreID,
		ChoreTitle:        v.StringValue(chore.ChoreTitle),
		ChoreDescription:  v.StringValue(chore.ChoreDescription),
		Category:          v.StringValue(chore.Category),
		DueDayOfWeek:      v.StringValue(chore.DueDayOfWeek),
		DueTime:           v.StringValue(chore.DueTime),
		ReminderDayOfWeek: v.StringValue(chore.ReminderDayOfWeek),
		ReminderTime:      v.StringValue(chore.ReminderTime),
		Recurrence:        v.StringValue(chore.Recurrence),
		AutoRotate:        v.BoolValue(chore.AutoRotate),
		ChoreScore:        v.IntValue(chore.ChoreScore),
		AssignedUsers:     assignedUsers,
	}

	return response, nil
}
