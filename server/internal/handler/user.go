package handler

import (
	"errors"
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"fairnest/internal/utils"
	"github.com/gofiber/fiber/v2"
	"strconv"
	"strings"
)

type userHandler struct {
	userSer   service.UserService
	jwtSecret string
	uploadSer service.UploadService
}

func NewUserHandler(userSer service.UserService, jwtSecret string, uploadSer service.UploadService) userHandler {
	return userHandler{userSer: userSer, jwtSecret: jwtSecret, uploadSer: uploadSer}
}

func (h *userHandler) FetchUsers(c *fiber.Ctx) error {
	usersResponse := make([]dtos.UserDataResponse, 0)

	users, err := h.userSer.FetchUsers()
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

func (h *userHandler) GetUserByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	user, err := h.userSer.GetUserByUserId(userIDReceive)
	if err != nil {
		return err
	}

	userResponse := dtos.UserByUserIdDataResponse{
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
	}

	return c.JSON(userResponse)
}

func (h *userHandler) GetUserByToken(c *fiber.Ctx) error {
	// Extract the token from the request headers
	token := c.Get("Authorization")

	// Check if the token is empty
	if token == "" {
		return errors.New("token is missing")
	}

	// Extract the user ID from the token
	userIDExtract, err := utils.ExtractUserIDFromToken(strings.Replace(token, "Bearer ", "", 1), h.jwtSecret)
	if err != nil {
		return err
	}

	user, err := h.userSer.GetUserByToken(userIDExtract)
	if err != nil {
		return err
	}

	userResponse := dtos.UserByTokenDataResponse{
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
	}

	return c.JSON(userResponse)
}

/////////////////////////////////////////////////////////////////////////

func (h *userHandler) GetCurrentUser(c *fiber.Ctx) error {
	// Extract the token from the request headers
	token := c.Get("Authorization")

	// Check if the token is empty
	if token == "" {
		return errors.New("token is missing")
	}

	// Extract the user ID from the token
	userIDExtract, err := utils.ExtractUserIDFromToken(strings.Replace(token, "Bearer ", "", 1), h.jwtSecret)
	if err != nil {
		return err
	}

	user, err := h.userSer.GetCurrentUser(userIDExtract)
	if err != nil {
		return err
	}

	userResponse := dtos.CurrentUserResponse{
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
	}

	return c.JSON(userResponse)
}

func (h *userHandler) GetProfileOfCurrentUserByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	user, err := h.userSer.GetProfileOfCurrentUserByUserId(userIDReceive)
	if err != nil {
		return err
	}

	userResponse := dtos.ProfileOfCurrentUserByUserIdResponse{
		UserID:             user.UserID,
		Username:           user.Username,
		Firstname:          user.Firstname,
		Lastname:           user.Lastname,
		UserPicture:        user.UserPicture,
		UserAboutMe:        user.UserAboutMe,
		UserTidiness:       user.UserTidiness,
		UserNoiseActivity:  user.UserNoiseActivity,
		UserSchedule:       user.UserSchedule,
		UserGuestFrequency: user.UserGuestFrequency,
		UserTaskStructure:  user.UserTaskStructure,
		UserMoneyAttitude:  user.UserMoneyAttitude,
	}

	return c.JSON(userResponse)
}

func (h *userHandler) GetEditUserProfileByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	user, err := h.userSer.GetEditUserProfileByUserId(userIDReceive)
	if err != nil {
		return err
	}

	userResponse := dtos.EditUserProfileByUserIdResponse{
		UserID:      user.UserID,
		Username:    user.Username,
		Firstname:   user.Firstname,
		Lastname:    user.Lastname,
		UserAboutMe: user.UserAboutMe,
	}

	return c.JSON(userResponse)
}

func (h *userHandler) PatchEditUserProfileByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	var req dtos.EditUserProfileByUserIdRequest
	if err := c.BodyParser(&req); err != nil {
		return err
	}

	user, err := h.userSer.PatchEditUserProfileByUserId(userIDReceive, req)
	if err != nil {
		return err
	}

	userResponse := dtos.EditUserProfileByUserIdRequest{
		Username:    user.Username,
		Firstname:   user.Firstname,
		Lastname:    user.Lastname,
		UserAboutMe: user.UserAboutMe,
	}

	return c.JSON(userResponse)
}

func (h *userHandler) Register(c *fiber.Ctx) error {
	var request dtos.RegisterRequest
	if err := c.BodyParser(&request); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, err.Error())
	}

	//// Check if a user picture file is uploaded
	//userPictureFile, err := c.FormFile("user_picture")
	//if err != nil {
	//	return fiber.NewError(fiber.StatusBadRequest, "User picture file not found")
	//}
	//
	//// Call upload service to upload the user picture file
	//userPictureFileURL, err := h.uploadSer.UploadFile(userPictureFile)
	//if err != nil {
	//	return fiber.NewError(fiber.StatusInternalServerError, "Failed to upload user picture file")
	//}
	//
	//// Check if a user verification picture file is uploaded
	//userVerificationPictureFile, err := c.FormFile("user_verification_picture")
	//if err != nil {
	//	return fiber.NewError(fiber.StatusBadRequest, "User picture file not found")
	//}
	//
	//// Call upload service to upload the user verification picture file
	//userVerificationPictureFileURL, err := h.uploadSer.UploadFile(userVerificationPictureFile)
	//if err != nil {
	//	return fiber.NewError(fiber.StatusInternalServerError, "Failed to upload user verification picture file")
	//}
	//
	////Set the uploaded file URL in the registration request
	//request.UserPicture = userPictureFileURL
	//request.UserVerificationPicture = userVerificationPictureFileURL
	//
	//// Check if user_pic field is empty or nil
	//if request.UserPicture == nil {
	//	return fiber.NewError(fiber.StatusBadRequest, "User picture is required")
	//}
	//
	//if request.UserVerificationPicture == nil {
	//	return fiber.NewError(fiber.StatusBadRequest, "User verification picture is required")
	//}

	response, err := h.userSer.Register(request)
	if err != nil {
		return fiber.NewError(fiber.StatusInternalServerError, err.Error())
	}

	return c.Status(fiber.StatusCreated).JSON(response)
}

func (h *userHandler) Login(c *fiber.Ctx) error {
	var request dtos.LoginRequest
	if err := c.BodyParser(&request); err != nil {
		return fiber.NewError(fiber.StatusBadRequest, err.Error())
	}

	if request.Email == nil || request.Password == nil {
		return fiber.NewError(fiber.StatusBadRequest, "Email and Password are required")
	}

	response, err := h.userSer.Login(request, h.jwtSecret)
	if err != nil {
		return fiber.NewError(fiber.StatusUnauthorized, err.Error())
	}

	return c.JSON(response)
}
