package service

import (
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"log"
)

type templateService struct {
	userRepo repository.UserRepository
}

func NewTemplateService(userRepo repository.UserRepository) templateService {
	return templateService{
		userRepo: userRepo,
	}
}

func (s templateService) FetchUsers() ([]entities.User, error) {
	users, err := s.userRepo.FetchAllUser()
	if err != nil {
		log.Println(err)
		return nil, err
	}

	userResponses := []entities.User{}
	for _, user := range users {
		userResponse := entities.User{
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
		userResponses = append(userResponses, userResponse)
	}
	return userResponses, nil
}
