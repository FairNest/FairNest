package repository

import (
	"fairnest/internal/entities"
	"gorm.io/gorm"
)

type userRepositoryDB struct {
	db *gorm.DB
}

func NewUserRepositoryDB(db *gorm.DB) userRepositoryDB {
	return userRepositoryDB{db: db}
}

func (r userRepositoryDB) GetAllUser() ([]entities.User, error) {
	users := []entities.User{}
	result := r.db.Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return users, nil
}

func (r userRepositoryDB) GetUserByUserId(userid int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userid).Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil
}

func (r userRepositoryDB) GetUserByToken(userid int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userid).Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil
}

/////////////////////////////////////////////////////////////////////////////////////////////

func (r userRepositoryDB) GetCurrentUser(userid int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userid).Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil
}

func (r userRepositoryDB) GetProfileOfCurrentUserByUserId(userid int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userid).Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil
}

func (r userRepositoryDB) GetEditUserProfileByUserId(userid int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userid).Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil
}

func (r userRepositoryDB) PatchEditUserProfileByUserId(user *entities.User) error {
	result := r.db.Updates(user)
	if result.Error != nil {
		return result.Error
	}

	return nil
}

func (r userRepositoryDB) CreateUser(user *entities.User) error {
	result := r.db.Create(user)
	if result.Error != nil {
		return result.Error
	}
	return nil
}

func (r userRepositoryDB) GetUserByUsername(username string) (*entities.User, error) {
	var user entities.User
	result := r.db.Where("username = ?", username).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}
