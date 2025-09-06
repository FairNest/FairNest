package repository

import "fairnest/internal/entities"

type NotificationRepository interface {
	FetchAllUnreadNotificationByUserId(int) ([]entities.Notification, error)
	FetchThreeNotificationByUserId(int) ([]entities.Notification, error)

	PutMarkAsRead(notificationId int) error
}
