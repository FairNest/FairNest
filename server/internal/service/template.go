package service

import (
	"fairnest/internal/entities"
)

type TemplateService interface {
	FetchAllUser() ([]entities.User, error)
	GetUserByUserId(int) (*entities.User, error)
	GetUserByToken(int) (*entities.User, error)

	////////////////////////////////////////////////////////////////////
}
