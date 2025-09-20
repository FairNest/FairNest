package repository

import (
	"fairnest/internal/entities"

	"gorm.io/gorm"
)

type lifestyleRepositoryDB struct {
	db *gorm.DB
}

func NewLifestyleRepositoryDB(db *gorm.DB) lifestyleRepositoryDB {
	return lifestyleRepositoryDB{db: db}
}

func (r lifestyleRepositoryDB) GetLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyles := entities.Lifestyle{}
	result := r.db.Where("user_id = ?", userId).Find(&lifestyles)
	if result.Error != nil {
		return nil, result.Error
	}
	return &lifestyles, nil
}

///////////////////////////////////////////////////////////////////////////

func (r lifestyleRepositoryDB) CreateLifestyleByUserId(lifestyle *entities.Lifestyle) error {
	result := r.db.Create(lifestyle)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (r lifestyleRepositoryDB) GetUserLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyles := entities.Lifestyle{}
	result := r.db.Where("user_id = ?", userId).Find(&lifestyles)
	if result.Error != nil {
		return nil, result.Error
	}
	return &lifestyles, nil
}

func (r lifestyleRepositoryDB) GetUserOverallLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyles := entities.Lifestyle{}
	result := r.db.Where("user_id = ?", userId).Find(&lifestyles)
	if result.Error != nil {
		return nil, result.Error
	}
	return &lifestyles, nil
}

func (r lifestyleRepositoryDB) GetLifestylesByRoomId(roomId int) ([]*entities.Lifestyle, error) {
	var rows []entities.Lifestyle
	err := r.db.
		Table("lifestyles").
		Select(`
			lifestyles.lifestyle_id,
			lifestyles.user_id,
			lifestyles.user_tidiness,
			lifestyles.user_noise_activity,
			lifestyles.user_schedule,
			lifestyles.user_guest_frequency,
			lifestyles.user_task_structure,
			lifestyles.user_money_attitude
		`).
		Joins("JOIN room_members ON room_members.user_id = lifestyles.user_id").
		Where("room_members.room_id = ?", roomId).
		Scan(&rows).Error
	if err != nil {
		return nil, err
	}
	out := make([]*entities.Lifestyle, len(rows))
	for i := range rows {
		out[i] = &rows[i]
	}
	return out, nil
}

func (r lifestyleRepositoryDB) GetUsersInRoom(roomId int) ([]*entities.User, error) {
	var users []entities.User
	err := r.db.
		Table("users").
		Select("users.user_id, users.username, users.user_picture").
		Joins("JOIN room_members ON room_members.user_id = users.user_id").
		Where("room_members.room_id = ?", roomId).
		Scan(&users).Error
	if err != nil {
		return nil, err
	}
	out := make([]*entities.User, len(users))
	for i := range users {
		out[i] = &users[i]
	}
	return out, nil
}
