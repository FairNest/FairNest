package service

import "fairnest/internal/entities"

type NotificationService interface {
	FetchAllUnreadNotificationByUserId(int) ([]entities.Notification, error)
	FetchThreeNotificationByUserId(int) ([]entities.Notification, error)

	////////////////////////////////////////////////////////////////////
}
