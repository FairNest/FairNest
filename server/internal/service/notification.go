package service

import "fairnest/internal/entities"

type NotificationService interface {
	FetchAllUnreadNotificationByUserId(int) ([]entities.Notification, error)
	FetchThreeNoticesByUserId(int) ([]entities.Notification, error)

	////////////////////////////////////////////////////////////////////
}
