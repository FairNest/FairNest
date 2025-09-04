package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type UserService interface {
	FetchAllUser() ([]entities.User, error)
	GetUserByUserId(int) (*entities.User, error)
	GetUserByToken(int) (*entities.User, error)

	////////////////////////////////////////////////////////////////////

	GetCurrentUser(int) (*entities.User, error)
	GetProfileOfCurrentUserByUserId(int) (*dtos.GetProfileOfCurrentUserByUserIdResponse, error)

	GetEditUserProfileByUserId(int) (*entities.User, error)
	PatchEditUserProfileByUserId(int, dtos.PatchEditUserProfileByUserIdRequest) (*entities.User, error)

	Register(request dtos.RegisterRequest) (*dtos.UserResponse, error)
	Login(request dtos.LoginRequest, jwtSecret string) (*dtos.LoginResponse, error)

	FetchAllUserByUserId(userIDs []uint) ([]entities.User, error)

	GetFindUserByUserId(userId int) (*entities.User, error)
}
