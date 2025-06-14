package service

import (
	"errors"
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
	userRepo  repository.UserRepository
	jwtSecret string
}

func NewUserService(userRepo repository.UserRepository, jwtSecret string) userService {
	return userService{
		userRepo:  userRepo,
		jwtSecret: jwtSecret,
	}
}

func (s userService) GetUsers() ([]entities.User, error) {
	users, err := s.userRepo.GetAllUser()
	if err != nil {
		log.Println(err)
		return nil, err
	}

	userResponses := []entities.User{}
	for _, user := range users {
		userResponse := entities.User{
			UserID:      user.UserID,
			Username:    user.Username,
			Password:    user.Password,
			Email:       user.Email,
			Firstname:   user.Firstname,
			Lastname:    user.Lastname,
			PhoneNumber: user.PhoneNumber,
			UserPicture: user.UserPicture,
		}
		userResponses = append(userResponses, userResponse)
	}
	return userResponses, nil
}

func (s userService) GetUserByUserId(userid int) (*entities.User, error) {
	user, err := s.userRepo.GetUserByUserId(userid)
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
		user.UserPicture == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user data is not found")
	}

	userResponse := entities.User{
		UserID:      user.UserID,
		Username:    user.Username,
		Password:    user.Password,
		Email:       user.Email,
		Firstname:   user.Firstname,
		Lastname:    user.Lastname,
		PhoneNumber: user.PhoneNumber,
		UserPicture: user.UserPicture,
	}
	return &userResponse, nil
}

func (s userService) GetUserByToken(userid int) (*entities.User, error) {
	user, err := s.userRepo.GetUserByToken(userid)
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
		user.UserPicture == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user data is not found")
	}

	userResponse := entities.User{
		UserID:      user.UserID,
		Username:    user.Username,
		Password:    user.Password,
		Email:       user.Email,
		Firstname:   user.Firstname,
		Lastname:    user.Lastname,
		PhoneNumber: user.PhoneNumber,
		UserPicture: user.UserPicture,
	}
	return &userResponse, nil
}

////////////////////////////////////////////////////////////////////////////////////

func (s userService) GetCurrentUser(userid int) (*entities.User, error) {
	user, err := s.userRepo.GetCurrentUser(userid)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	userResponse := entities.User{
		UserID:      user.UserID,
		Username:    user.Username,
		Password:    user.Password,
		Email:       user.Email,
		Firstname:   user.Firstname,
		Lastname:    user.Lastname,
		PhoneNumber: user.PhoneNumber,
		UserPicture: user.UserPicture,
	}
	return &userResponse, nil
}

func (s userService) GetProfileOfCurrentUserByUserId(userid int) (*entities.User, error) {
	user, err := s.userRepo.GetProfileOfCurrentUserByUserId(userid)
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
		user.UserPicture == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user data is not found")
	}

	userResponse := entities.User{
		UserID:      user.UserID,
		Username:    user.Username,
		Password:    user.Password,
		Email:       user.Email,
		Firstname:   user.Firstname,
		Lastname:    user.Lastname,
		PhoneNumber: user.PhoneNumber,
		UserPicture: user.UserPicture,
	}
	return &userResponse, nil
}

func (s userService) GetEditUserProfileByUserId(userid int) (*entities.User, error) {
	user, err := s.userRepo.GetEditUserProfileByUserId(userid)
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
		user.UserPicture == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user data is not found")
	}

	userResponse := entities.User{
		UserID:      user.UserID,
		Username:    user.Username,
		Email:       user.Email,
		Firstname:   user.Firstname,
		Lastname:    user.Lastname,
		PhoneNumber: user.PhoneNumber,
	}
	return &userResponse, nil
}

func (s userService) PatchEditUserProfileByUserId(userid int, req dtos.EditUserProfileByUserIdRequest) (*entities.User, error) {
	user := &entities.User{
		UserID:      v.UintPtr(userid),
		Username:    req.Username,
		Email:       req.Email,
		Firstname:   req.Firstname,
		Lastname:    req.Lastname,
		PhoneNumber: req.PhoneNumber,
	}

	err := s.userRepo.PatchEditUserProfileByUserId(user)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	return user, nil
}

func (s userService) Register(request dtos.RegisterRequest) (*dtos.UserResponse, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword(v.ByteSlice(request.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}

	user := entities.User{
		Username:    request.Username,
		Password:    v.Ptr(string(hashedPassword)),
		Email:       request.Email,
		Firstname:   request.Firstname,
		Lastname:    request.Lastname,
		PhoneNumber: request.PhoneNumber,
		UserPicture: request.UserPicture,
	}

	err = s.userRepo.CreateUser(&user)
	if err != nil {
		return nil, err
	}

	return &dtos.UserResponse{
		UserID:      user.UserID,
		Username:    user.Username,
		UserPicture: user.UserPicture,
	}, nil

}

func (s userService) Login(request dtos.LoginRequest, jwtSecret string) (*dtos.LoginResponse, error) {
	// Validate request data
	if request.Username == nil || request.Password == nil {
		return nil, fiber.NewError(fiber.StatusBadRequest, "Username and password are required")
	}

	username := *request.Username
	password := *request.Password

	// Find user by username
	user, err := s.userRepo.GetUserByUsername(username)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, fiber.NewError(fiber.StatusBadRequest, "Invalid username or password")
		}
		return nil, err
	}

	// Nil checks to prevent crashes
	if user == nil || user.Password == nil || user.UserID == nil {
		return nil, fiber.NewError(fiber.StatusBadRequest, "Invalid credentials")
	}

	// Compare password
	if err := bcrypt.CompareHashAndPassword(v.ByteSlice(user.Password), []byte(password)); err != nil {
		return nil, fiber.NewError(fiber.StatusBadRequest, "Invalid credentials")
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
		UserID:   user.UserID,
		Username: user.Username,
		Token:    &jwtToken,
	}, nil
}
