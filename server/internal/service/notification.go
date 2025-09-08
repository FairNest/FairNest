package service

import "fairnest/internal/entities"

type NotificationService interface {
	GetNotificationByNotificationId(int) (*entities.Notification, error)

	////////////////////////////////////////////////////////////////////
	FetchAllUnreadNotificationByUserId(int) ([]entities.Notification, error)
	FetchThreeNotificationByUserId(int) ([]entities.Notification, error)

	PutMarkAsReadByNotificationId(int) (*entities.Notification, error)
}
