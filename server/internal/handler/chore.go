package handler

import (
	"fairnest/internal/service"
)

type choreHandler struct {
	choreSer service.ChoreService
}

func NewChoreHandler(choreSer service.ChoreService) choreHandler {
	return choreHandler{choreSer: choreSer}
}
