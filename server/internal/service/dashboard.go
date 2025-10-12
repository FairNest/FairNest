package service

import "fairnest/internal/dtos"

type DashboardService interface {
	GetRoomDashboard(roomID uint, currentUserID uint) (*dtos.GetRoomDashboardResponse, error)
}
