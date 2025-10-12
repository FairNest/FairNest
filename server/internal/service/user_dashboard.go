package service

import "fairnest/internal/dtos"

type UserDashboardService interface {
	GetUserDashboard(userID uint) (*dtos.GetUserDashboardResponse, error)
}
