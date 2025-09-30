package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type NotificationService interface {
	GetNotificationByNotificationId(int) (*entities.Notification, error)

	////////////////////////////////////////////////////////////////////
	FetchAllUnreadNotificationByUserId(int) ([]entities.Notification, error)
	FetchThreeNotificationByUserId(int) ([]entities.Notification, error)

	PutMarkAsReadByNotificationId(int) (*entities.Notification, error)

	GetCountOfUnreadNotificationByUserId(int) (int, error)

	CreateNotification(int, int, dtos.CreateNotificationRequest) (*dtos.CreateNotificationResponse, error)
	CreateVoteNotification(int, int, dtos.CreateVoteNotificationRequest, int) (*dtos.CreateVoteNotificationResponse, error)

	PutMarkAllAsReadByRoomJoinRequestID(int) ([]entities.Notification, error)
	FetchAllNotificationsByRoomJoinRequestID(int) ([]entities.Notification, error)
}
