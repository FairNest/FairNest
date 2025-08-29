package repository

import "fairnest/internal/entities"

type TemplateRepository interface {
	FetchAllTemplate() ([]entities.Room, error)
}
