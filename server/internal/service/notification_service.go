package service

import (
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
			CreatedAt:           notification.CreatedAt,
		}
		err := s.notificationRepo.PutMarkAsRead(v.UintToInt(v.UintValue(notification.NotificationID)))
		if err != nil {
			log.Println(err)
			return nil, err
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
			CreatedAt:           notification.CreatedAt,
		}
		notificationResponses = append(notificationResponses, notificationResponse)
	}
	return notificationResponses, nil
}
