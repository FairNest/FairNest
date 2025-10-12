package service

import "fairnest/internal/dtos"

type UserDashboardService interface {
	GetUserProgress(userID uint) (*dtos.GetUserProgressResponse, error)
	GetUserTasksToday(userID uint) (*dtos.GetUserTasksSeparatedResponse, error)
	GetUserTasksCompleted(userID uint) (*dtos.GetUserTasksSeparatedResponse, error)
	GetUserTasksUpcoming(userID uint) (*dtos.GetUserTasksSeparatedResponse, error)
}
