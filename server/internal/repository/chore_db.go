package repository

import (
	"gorm.io/gorm"
)

type choreRepositoryDB struct {
	db *gorm.DB
}

func NewChoreRepositoryDB(db *gorm.DB) choreRepositoryDB {
	return choreRepositoryDB{db: db}
}
