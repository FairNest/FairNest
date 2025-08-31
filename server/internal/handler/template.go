package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"github.com/gofiber/fiber/v2"
)

type templateHandler struct {
	userSer service.UserService
}

func NewTemplateHandler(userSer service.UserService) templateHandler {
	return templateHandler{userSer: userSer}
}

func (h *templateHandler) FetchAllUser(c *fiber.Ctx) error {
	usersResponse := make([]dtos.UserDataResponse, 0)

	users, err := h.userSer.FetchAllUser()
	if err != nil {
		return err
	}

	for _, user := range users {
		usersResponse = append(usersResponse, dtos.UserDataResponse{
			UserID:                     user.UserID,
			Username:                   user.Username,
			Password:                   user.Password,
			Email:                      user.Email,
			Firstname:                  user.Firstname,
			Lastname:                   user.Lastname,
			PhoneNumber:                user.PhoneNumber,
			UserPicture:                user.UserPicture,
			UserAboutMe:                user.UserAboutMe,
			BankAccountNumber:          user.BankAccountNumber,
			RoommateScore:              user.RoommateScore,
			UserVerificationPicture:    user.UserVerificationPicture,
			UserIdentityDocumentNumber: user.UserIdentityDocumentNumber,
			UserIdentityDocumentType:   user.UserIdentityDocumentType,
		})
	}
	return c.JSON(usersResponse)
}
