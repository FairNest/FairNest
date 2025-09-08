package repository

import "fairnest/internal/entities"

type NotificationRepository interface {
	GetNotificationByNotificationId(int) (*entities.Notification, error)
	///////////////////////////////////////////////////////////////////////////
	FetchAllUnreadNotificationByUserId(int) ([]entities.Notification, error)
	FetchThreeNotificationByUserId(int) ([]entities.Notification, error)

	PutMarkAsReadByNotificationId(notification *entities.Notification) error
	GetCountOfUnreadNotificationByUserId(int) (int, error)
}
