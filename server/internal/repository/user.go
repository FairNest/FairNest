package repository

import "fairnest/internal/entities"

type UserRepository interface {
	FetchAllUser() ([]entities.User, error)
	GetUserByUserId(int) (*entities.User, error)
	GetUserByToken(int) (*entities.User, error)

	////////////////////////////////////////////////////////////////////

	GetCurrentUser(int) (*entities.User, error)

	GetProfileOfCurrentUserByUserId(int) (*entities.User, error)

	GetEditUserProfileByUserId(int) (*entities.User, error)
	PatchEditUserProfileByUserId(user *entities.User) error

	CreateUser(user *entities.User) error                                                          //Register
	GetUserByEmail(email string) (*entities.User, error)                                           //Login
	GetUserByUsername(username string) (*entities.User, error)                                     //Login
	GetUserByUserIdentityDocumentNumber(userIdentityDocumentNumber string) (*entities.User, error) //Login
}
