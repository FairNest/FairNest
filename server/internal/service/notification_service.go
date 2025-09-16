package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"log"
)

type notificationService struct {
	notificationRepo repository.NotificationRepository
}

func NewNotificationService(notificationRepo repository.NotificationRepository) notificationService {
	return notificationService{
		notificationRepo: notificationRepo,
	}
}

func (s notificationService) GetNotificationByNotificationId(notificationId int) (*entities.Notification, error) {
	notification, err := s.notificationRepo.GetNotificationByNotificationId(notificationId)
	if err != nil {
		return nil, err
	}

	notificationResponse := &entities.Notification{
		NotificationID:      notification.NotificationID,
		SenderID:            notification.SenderID,
		ReceiverID:          notification.ReceiverID,
		NotificationMessage: notification.NotificationMessage,
		IsRead:              notification.IsRead,
		IsVoteNotification:  notification.IsVoteNotification,
		CreatedAt:           notification.CreatedAt,
	}

	return notificationResponse, nil
}

func (s notificationService) FetchAllUnreadNotificationByUserId(userId int) ([]entities.Notification, error) {
	notifications, err := s.notificationRepo.FetchAllUnreadNotificationByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	notificationResponses := []entities.Notification{}
	for _, notification := range notifications {
		notificationResponse := entities.Notification{
			NotificationID:      notification.NotificationID,
			SenderID:            notification.SenderID,
			ReceiverID:          notification.ReceiverID,
			NotificationMessage: notification.NotificationMessage,
			IsRead:              notification.IsRead,
			IsVoteNotification:  notification.IsVoteNotification,
			CreatedAt:           notification.CreatedAt,
		}
		notificationResponses = append(notificationResponses, notificationResponse)
	}

	return notificationResponses, nil
}

func (s notificationService) FetchThreeNotificationByUserId(userId int) ([]entities.Notification, error) {
	notifications, err := s.notificationRepo.FetchThreeNotificationByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	notificationResponses := []entities.Notification{}
	for _, notification := range notifications {
		notificationResponse := entities.Notification{
			NotificationID:      notification.NotificationID,
			SenderID:            notification.SenderID,
			ReceiverID:          notification.ReceiverID,
			NotificationMessage: notification.NotificationMessage,
			IsRead:              notification.IsRead,
			IsVoteNotification:  notification.IsVoteNotification,
			CreatedAt:           notification.CreatedAt,
		}
		notificationResponses = append(notificationResponses, notificationResponse)
	}
	return notificationResponses, nil
}

func (s notificationService) PutMarkAsReadByNotificationId(notificationId int) (*entities.Notification, error) {
	notification, err := s.notificationRepo.GetNotificationByNotificationId(notificationId)
	if err != nil {
		return nil, err
	}

	read := true
	notification.IsRead = &read

	err = s.notificationRepo.PutMarkAsReadByNotificationId(notification)
	if err != nil {
		return nil, err
	}

	notificationResponse := &entities.Notification{
		NotificationID:      notification.NotificationID,
		SenderID:            notification.SenderID,
		ReceiverID:          notification.ReceiverID,
		NotificationMessage: notification.NotificationMessage,
		IsRead:              notification.IsRead,
		IsVoteNotification:  notification.IsVoteNotification,
		CreatedAt:           notification.CreatedAt,
	}

	return notificationResponse, nil
}

func (s notificationService) GetCountOfUnreadNotificationByUserId(userId int) (int, error) {
	count, err := s.notificationRepo.GetCountOfUnreadNotificationByUserId(userId)
	if err != nil {
		return 0, err
	}
	return count, nil
}

func (s notificationService) CreateNotification(senderId int, receiverId int, request dtos.CreateNotificationRequest) (*dtos.CreateNotificationResponse, error) {
	isRead := false
	isVoteNotification := false

	notification := entities.Notification{
		SenderID:            v.Ptr(uint(senderId)),
		ReceiverID:          v.Ptr(uint(receiverId)),
		NotificationMessage: request.NotificationMessage,
		IsRead:              &isRead,
		IsVoteNotification:  &isVoteNotification,
	}

	if err := s.notificationRepo.CreateNotification(&notification); err != nil {
		return nil, err
	}

	return &dtos.CreateNotificationResponse{
		NotificationID:      notification.NotificationID,
		SenderID:            notification.SenderID,
		ReceiverID:          notification.ReceiverID,
		NotificationMessage: notification.NotificationMessage,
		IsRead:              notification.IsRead,
		IsVoteNotification:  notification.IsVoteNotification,
		CreatedAt:           v.TimePtrToRFC3339Ptr(notification.CreatedAt),
	}, nil
}

func (s notificationService) CreateVoteNotification(senderId int, receiverId int, request dtos.CreateVoteNotificationRequest) (*dtos.CreateVoteNotificationResponse, error) {
	isRead := false
	isVoteNotification := true

	notification := entities.Notification{
		SenderID:            v.Ptr(uint(senderId)),
		ReceiverID:          v.Ptr(uint(receiverId)),
		NotificationMessage: request.NotificationMessage,
		IsRead:              &isRead,
		IsVoteNotification:  &isVoteNotification,
	}

	if err := s.notificationRepo.CreateVoteNotification(&notification); err != nil {
		return nil, err
	}

	return &dtos.CreateVoteNotificationResponse{
		NotificationID:      notification.NotificationID,
		SenderID:            notification.SenderID,
		ReceiverID:          notification.ReceiverID,
		NotificationMessage: notification.NotificationMessage,
		IsRead:              notification.IsRead,
		IsVoteNotification:  notification.IsVoteNotification,
		CreatedAt:           v.TimePtrToRFC3339Ptr(notification.CreatedAt),
	}, nil
}
