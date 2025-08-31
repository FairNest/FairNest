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

func (r userRepositoryDB) FetchAllUser() ([]entities.User, error) {
	users := []entities.User{}
	result := r.db.Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return users, nil
}

func (r userRepositoryDB) GetUserByUserId(userId int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userId).Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil
}

func (r userRepositoryDB) GetUserByToken(userId int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userId).Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil
}

/////////////////////////////////////////////////////////////////////////////////////////////

func (r userRepositoryDB) GetCurrentUser(userId int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userId).Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil
}

func (r userRepositoryDB) GetProfileOfCurrentUserByUserId(userId int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userId).Find(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil
}

func (r userRepositoryDB) GetEditUserProfileByUserId(userId int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userId).Find(&users)
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

func (r userRepositoryDB) GetUserByEmail(email string) (*entities.User, error) {
	var user entities.User
	result := r.db.Where("email = ?", email).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

func (r userRepositoryDB) GetUserByUsername(username string) (*entities.User, error) {
	var user entities.User
	result := r.db.Where("username = ?", username).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

func (r userRepositoryDB) GetUserByUserIdentityDocumentNumber(userIdentityDocumentNumber string) (*entities.User, error) {
	var user entities.User
	result := r.db.Where("user_identity_document_number = ?", userIdentityDocumentNumber).First(&user)
	if result.Error != nil {
		return nil, result.Error
	}
	return &user, nil
}

func (r userRepositoryDB) FetchAllUserByUserId(userIds []uint) ([]entities.User, error) {
	var users []entities.User
	err := r.db.Where("user_id IN ?", userIds).Find(&users).Error
	return users, err
}

func (r userRepositoryDB) GetFindUserByUserId(userId int) (*entities.User, error) {
	users := entities.User{}
	result := r.db.Where("user_id = ?", userId).First(&users)
	if result.Error != nil {
		return nil, result.Error
	}
	return &users, nil

}
