package service

import (
	"errors"
	"fairnest/internal/utils"
	"log"
	"strconv"
	"time"

	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type userService struct {
	userRepo      repository.UserRepository
	jwtSecret     string
	lifestyleRepo repository.LifestyleRepository
}

func NewUserService(userRepo repository.UserRepository, jwtSecret string, lifestyleRepo repository.LifestyleRepository) userService {
	return userService{
		userRepo:      userRepo,
		jwtSecret:     jwtSecret,
		lifestyleRepo: lifestyleRepo,
	}
}

func (s userService) FetchUsers() ([]entities.User, error) {
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

func (s userService) GetUserByUserId(userId int) (*entities.User, error) {
	user, err := s.userRepo.GetUserByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if user.UserID == nil &&
		user.Username == nil &&
		user.Password == nil &&
		user.Email == nil &&
		user.Firstname == nil &&
		user.Lastname == nil &&
		user.PhoneNumber == nil &&
		user.UserPicture == nil &&
		user.UserAboutMe == nil &&
		user.BankAccountNumber == nil &&
		user.RoommateScore == nil &&
		user.UserVerificationPicture == nil &&
		user.UserIdentityDocumentNumber == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user data is not found")
	}

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
	return &userResponse, nil
}

func (s userService) GetUserByToken(userId int) (*entities.User, error) {
	user, err := s.userRepo.GetUserByToken(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if user.UserID == nil &&
		user.Username == nil &&
		user.Password == nil &&
		user.Email == nil &&
		user.Firstname == nil &&
		user.Lastname == nil &&
		user.PhoneNumber == nil &&
		user.UserPicture == nil &&
		user.UserAboutMe == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user data is not found")
	}

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
	return &userResponse, nil
}

////////////////////////////////////////////////////////////////////////////////////

func (s userService) GetCurrentUser(userId int) (*entities.User, error) {
	user, err := s.userRepo.GetCurrentUser(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

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
	return &userResponse, nil
}

func (s userService) GetProfileOfCurrentUserByUserId(userId int) (*entities.User, error) {
	user, err := s.userRepo.GetProfileOfCurrentUserByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if user.UserID == nil &&
		user.Username == nil &&
		user.Firstname == nil &&
		user.Lastname == nil &&
		user.UserPicture == nil &&
		user.UserAboutMe == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user data is not found")
	}

	userResponse := entities.User{
		UserID:      user.UserID,
		Username:    user.Username,
		Firstname:   user.Firstname,
		Lastname:    user.Lastname,
		UserPicture: user.UserPicture,
		UserAboutMe: user.UserAboutMe,
	}
	return &userResponse, nil
}

func (s userService) GetEditUserProfileByUserId(userId int) (*entities.User, error) {
	user, err := s.userRepo.GetEditUserProfileByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if user.UserID == nil &&
		user.Username == nil &&
		user.Firstname == nil &&
		user.Lastname == nil &&
		user.UserAboutMe == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user data is not found")
	}

	userResponse := entities.User{
		UserID:      user.UserID,
		Username:    user.Username,
		Firstname:   user.Firstname,
		Lastname:    user.Lastname,
		UserAboutMe: user.UserAboutMe,
	}
	return &userResponse, nil
}

func (s userService) PatchEditUserProfileByUserId(userId int, req dtos.EditUserProfileByUserIdRequest) (*entities.User, error) {
	user := &entities.User{
		UserID:      v.UintPtr(userId),
		Username:    req.Username,
		Firstname:   req.Firstname,
		Lastname:    req.Lastname,
		UserAboutMe: req.UserAboutMe,
	}

	err := s.userRepo.PatchEditUserProfileByUserId(user)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	return user, nil
}

func (s userService) Register(request dtos.RegisterRequest) (*dtos.UserResponse, error) {
	// Email, Username, Password, UserIdentityDocumentNumber Nil check
	if request.Email == nil || request.Username == nil || request.Password == nil || request.UserIdentityDocumentNumber == nil {
		return nil, errors.New("email, username, password and user identity document number are required")
	}

	// Dereference
	email := *request.Email
	username := *request.Username
	userIdentityDocumentNumber := *request.UserIdentityDocumentNumber

	// Uniqueness checks
	if _, err := s.userRepo.GetUserByEmail(email); err == nil {
		return nil, errors.New("email already exists")
	}
	if _, err := s.userRepo.GetUserByUsername(username); err == nil {
		return nil, errors.New("username already exists")
	}
	if _, err := s.userRepo.GetUserByUserIdentityDocumentNumber(userIdentityDocumentNumber); err == nil {
		return nil, errors.New("user identity document number already exists")
	}

	// Identify type (true = 13-digit citizen ID, false = 9-char passport)
	isCitizenID, err := utils.DetectIdentityDocumentType(userIdentityDocumentNumber)
	if err != nil {
		return nil, err
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword(v.ByteSlice(request.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	// Hash user identity document number
	hashedUserIdentityDocumentNumber, err := bcrypt.GenerateFromPassword(v.ByteSlice(request.UserIdentityDocumentNumber), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := entities.User{
		Username:                   request.Username,
		Password:                   v.Ptr(string(hashedPassword)),
		Email:                      request.Email,
		Firstname:                  request.Firstname,
		Lastname:                   request.Lastname,
		PhoneNumber:                request.PhoneNumber,
		UserPicture:                request.UserPicture,
		UserAboutMe:                request.UserAboutMe,
		BankAccountNumber:          request.BankAccountNumber,
		RoommateScore:              v.Ptr(float64(100)),
		UserVerificationPicture:    request.UserVerificationPicture,
		UserIdentityDocumentNumber: v.Ptr(string(hashedUserIdentityDocumentNumber)),
		UserIdentityDocumentType:   v.Ptr(isCitizenID),
	}

	if err := s.userRepo.CreateUser(&user); err != nil {
		return nil, err
	}

	lifestyle := entities.Lifestyle{
		UserID:             user.UserID,
		Q1:                 request.Q1,
		Q2:                 request.Q2,
		Q3:                 request.Q3,
		Q4:                 request.Q4,
		Q5:                 request.Q5,
		Q6:                 request.Q6,
		Q7:                 request.Q7,
		Q8:                 request.Q8,
		Q9:                 request.Q9,
		Q10:                request.Q10,
		Q11:                request.Q11,
		Q12:                request.Q12,
		UserTidiness:       request.UserTidiness,
		UserNoiseActivity:  request.UserNoiseActivity,
		UserSchedule:       request.UserSchedule,
		UserGuestFrequency: request.UserGuestFrequency,
		UserTaskStructure:  request.UserTaskStructure,
		UserMoneyAttitude:  request.UserMoneyAttitude,
	}

	if err := s.lifestyleRepo.CreateLifestyle(&lifestyle); err != nil {
		return nil, err
	}

	return &dtos.UserResponse{
		UserID:      user.UserID,
		Username:    user.Username,
		Email:       user.Email,
		UserPicture: user.UserPicture,
	}, nil
}

func (s userService) Login(request dtos.LoginRequest, jwtSecret string) (*dtos.LoginResponse, error) {
	// Validate request data
	if request.Email == nil || request.Password == nil {
		return nil, fiber.NewError(fiber.StatusBadRequest, "Email and password are required")
	}

	username := *request.Email
	password := *request.Password

	// Find user by username
	user, err := s.userRepo.GetUserByEmail(username)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fiber.NewError(fiber.StatusBadRequest, "Invalid email or password")
		}
		return nil, err
	}

	// Nil checks to prevent crashes
	if user == nil || user.Password == nil || user.UserID == nil {
		return nil, fiber.NewError(fiber.StatusBadRequest, "Invalid password")
	}

	// Compare password
	if err := bcrypt.CompareHashAndPassword(v.ByteSlice(user.Password), []byte(password)); err != nil {
		return nil, fiber.NewError(fiber.StatusBadRequest, "Invalid password")
	}

	// Generate JWT token
	claims := jwt.RegisteredClaims{
		Issuer:    strconv.Itoa(int(*user.UserID)),
		IssuedAt:  jwt.NewNumericDate(time.Now()),
		ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)), // 24-hour expiration
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	jwtToken, err := token.SignedString([]byte(jwtSecret))
	if err != nil {
		return nil, err
	}

	// Return login response
	return &dtos.LoginResponse{
		UserID: user.UserID,
		Email:  user.Email,
		Token:  &jwtToken,
	}, nil
}
