package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
)

type LifestyleService interface {
	GetLifestyleByUserId(int) (*entities.Lifestyle, error)
	///////////////////////////////////////////////////////////////////////////
	CreateLifestyleByUserId(userId int, request *entities.Lifestyle) (*entities.Lifestyle, error)
	GetUserLifestyleByUserId(int) (*entities.Lifestyle, error)

	GetUserOverallLifestyleByUserId(int) (*entities.Lifestyle, error)
	GetRoomAverageCompatibilityByRoomId(roomId int) (avgPct float64, best PairScore, worst PairScore, err error)
	GetCompatibilityMatchesByRoomAndUser(roomId int, userId int) (dtos.CompatibilityMatchResponse, error)
}
