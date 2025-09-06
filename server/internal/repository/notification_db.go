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

func (r notificationRepositoryDB) FetchAllUnreadNotificationByUserId(userId int) ([]entities.Notification, error) {
	notifications := []entities.Notification{}
	result := r.db.
		Where("receiver_id = ?", userId).
		Where("is_read = ?", false).
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

func (r notificationRepositoryDB) PutMarkAsRead(notificationId int) error {
	result := r.db.Model(&entities.Notification{}).
		Where("notification_id = ?", notificationId).
		Update("is_read", true)
	if result.Error != nil {
		return result.Error
	}

	return nil
}
