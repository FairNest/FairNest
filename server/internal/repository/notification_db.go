package repository

import (
	"fairnest/internal/entities"
	"gorm.io/gorm"
)

type notificationRepositoryDB struct {
	db *gorm.DB
}

func NewNotificationRepositoryDB(db *gorm.DB) notificationRepositoryDB {
	return notificationRepositoryDB{db: db}
}

func (r notificationRepositoryDB) GetNotificationByNotificationId(notificationId int) (*entities.Notification, error) {
	notification := entities.Notification{}
	result := r.db.Where("notification_id = ?", notificationId).First(&notification)
	if result.Error != nil {
		return nil, result.Error
	}
	return &notification, nil
}

func (r notificationRepositoryDB) FetchAllUnreadNotificationByUserId(userId int) ([]entities.Notification, error) {
	notifications := []entities.Notification{}
	result := r.db.
		Where("receiver_id = ?", userId).
		Order("created_at DESC").
		Find(&notifications)
	if result.Error != nil {
		return nil, result.Error
	}
	return notifications, nil
}

func (r notificationRepositoryDB) FetchThreeNotificationByUserId(userId int) ([]entities.Notification, error) {
	notifications := []entities.Notification{}
	result := r.db.
		Where("receiver_id = ?", userId).
		Where("is_read = ?", false).
		Order("created_at DESC").
		Limit(3).
		Find(&notifications)
	if result.Error != nil {
		return nil, result.Error
	}
	return notifications, nil
}

func (r notificationRepositoryDB) PutMarkAsReadByNotificationId(notification *entities.Notification) error {
	result := r.db.Save(notification)
	if result.Error != nil {
		return result.Error
	}

	return nil
}
