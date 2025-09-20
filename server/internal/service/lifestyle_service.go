package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils/v"
	"log"
	"math"

	"github.com/gofiber/fiber/v2"
)

type lifestyleService struct {
	lifestyleRepo repository.LifestyleRepository
}

func NewLifestyleService(lifestyleRepo repository.LifestyleRepository) lifestyleService {
	return lifestyleService{
		lifestyleRepo: lifestyleRepo,
	}
}

func (s lifestyleService) GetLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyle, err := s.lifestyleRepo.GetLifestyleByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if lifestyle.LifestyleID == nil &&
		lifestyle.UserID == nil &&
		lifestyle.Q1 == nil &&
		lifestyle.Q2 == nil &&
		lifestyle.Q3 == nil &&
		lifestyle.Q4 == nil &&
		lifestyle.Q5 == nil &&
		lifestyle.Q6 == nil &&
		lifestyle.Q7 == nil &&
		lifestyle.Q8 == nil &&
		lifestyle.Q9 == nil &&
		lifestyle.Q10 == nil &&
		lifestyle.Q11 == nil &&
		lifestyle.Q12 == nil &&
		lifestyle.UserTidiness == nil &&
		lifestyle.UserNoiseActivity == nil &&
		lifestyle.UserSchedule == nil &&
		lifestyle.UserGuestFrequency == nil &&
		lifestyle.UserTaskStructure == nil &&
		lifestyle.UserMoneyAttitude == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "lifestyle data is not found")
	}

	lifestyleResponse := entities.Lifestyle{
		LifestyleID:        lifestyle.LifestyleID,
		UserID:             lifestyle.UserID,
		Q1:                 lifestyle.Q1,
		Q2:                 lifestyle.Q2,
		Q3:                 lifestyle.Q3,
		Q4:                 lifestyle.Q4,
		Q5:                 lifestyle.Q5,
		Q6:                 lifestyle.Q6,
		Q7:                 lifestyle.Q7,
		Q8:                 lifestyle.Q8,
		Q9:                 lifestyle.Q9,
		Q10:                lifestyle.Q10,
		Q11:                lifestyle.Q11,
		Q12:                lifestyle.Q12,
		UserTidiness:       lifestyle.UserTidiness,
		UserNoiseActivity:  lifestyle.UserNoiseActivity,
		UserSchedule:       lifestyle.UserSchedule,
		UserGuestFrequency: lifestyle.UserGuestFrequency,
		UserTaskStructure:  lifestyle.UserTaskStructure,
		UserMoneyAttitude:  lifestyle.UserMoneyAttitude,
	}
	return &lifestyleResponse, nil
}

func (s lifestyleService) GetUserLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyle, err := s.lifestyleRepo.GetUserLifestyleByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if lifestyle.LifestyleID == nil &&
		lifestyle.UserID == nil &&
		lifestyle.UserTidiness == nil &&
		lifestyle.UserNoiseActivity == nil &&
		lifestyle.UserSchedule == nil &&
		lifestyle.UserGuestFrequency == nil &&
		lifestyle.UserTaskStructure == nil &&
		lifestyle.UserMoneyAttitude == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user lifestyle data is not found")
	}

	lifestyleResponse := entities.Lifestyle{
		LifestyleID:        lifestyle.LifestyleID,
		UserID:             lifestyle.UserID,
		UserTidiness:       lifestyle.UserTidiness,
		UserNoiseActivity:  lifestyle.UserNoiseActivity,
		UserSchedule:       lifestyle.UserSchedule,
		UserGuestFrequency: lifestyle.UserGuestFrequency,
		UserTaskStructure:  lifestyle.UserTaskStructure,
		UserMoneyAttitude:  lifestyle.UserMoneyAttitude,
	}
	return &lifestyleResponse, nil
}

func (s lifestyleService) CreateLifestyleByUserId(userId int, request *entities.Lifestyle) (*entities.Lifestyle, error) {
	lifestyle := entities.Lifestyle{
		UserID:             v.UintPtr(userId),
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

	if err := s.lifestyleRepo.CreateLifestyleByUserId(&lifestyle); err != nil {
		return nil, err
	}

	return &entities.Lifestyle{
		UserID:             v.UintPtr(userId),
		Q1:                 lifestyle.Q1,
		Q2:                 lifestyle.Q2,
		Q3:                 lifestyle.Q3,
		Q4:                 lifestyle.Q4,
		Q5:                 lifestyle.Q5,
		Q6:                 lifestyle.Q6,
		Q7:                 lifestyle.Q7,
		Q8:                 lifestyle.Q8,
		Q9:                 lifestyle.Q9,
		Q10:                lifestyle.Q10,
		Q11:                lifestyle.Q11,
		Q12:                lifestyle.Q12,
		UserTidiness:       lifestyle.UserTidiness,
		UserNoiseActivity:  lifestyle.UserNoiseActivity,
		UserSchedule:       lifestyle.UserSchedule,
		UserGuestFrequency: lifestyle.UserGuestFrequency,
		UserTaskStructure:  lifestyle.UserTaskStructure,
		UserMoneyAttitude:  lifestyle.UserMoneyAttitude,
	}, nil
}

func (s lifestyleService) GetUserOverallLifestyleByUserId(userId int) (*entities.Lifestyle, error) {
	lifestyle, err := s.lifestyleRepo.GetUserOverallLifestyleByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if lifestyle.LifestyleID == nil &&
		lifestyle.UserID == nil &&
		lifestyle.UserTidiness == nil &&
		lifestyle.UserNoiseActivity == nil &&
		lifestyle.UserSchedule == nil &&
		lifestyle.UserGuestFrequency == nil &&
		lifestyle.UserTaskStructure == nil &&
		lifestyle.UserMoneyAttitude == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "user overall lifestyle data is not found")
	}

	lifestyleResponse := entities.Lifestyle{
		LifestyleID:        lifestyle.LifestyleID,
		UserID:             lifestyle.UserID,
		UserTidiness:       lifestyle.UserTidiness,
		UserNoiseActivity:  lifestyle.UserNoiseActivity,
		UserSchedule:       lifestyle.UserSchedule,
		UserGuestFrequency: lifestyle.UserGuestFrequency,
		UserTaskStructure:  lifestyle.UserTaskStructure,
		UserMoneyAttitude:  lifestyle.UserMoneyAttitude,
	}
	return &lifestyleResponse, nil
}

func clamp01(x float64) float64 {
	if x < 0 {
		return 0
	}
	if x > 1 {
		return 1
	}
	return x
}

func traits6(l *entities.Lifestyle) ([]float64, error) {
	if l == nil ||
		l.UserTidiness == nil ||
		l.UserNoiseActivity == nil ||
		l.UserSchedule == nil ||
		l.UserGuestFrequency == nil ||
		l.UserTaskStructure == nil ||
		l.UserMoneyAttitude == nil {
		return nil, fiber.NewError(fiber.StatusUnprocessableEntity, "incomplete lifestyle data for a room member")
	}

	return []float64{
		clamp01(*l.UserTidiness),
		clamp01(*l.UserNoiseActivity),
		clamp01(*l.UserSchedule),
		clamp01(*l.UserGuestFrequency),
		clamp01(*l.UserTaskStructure),
		clamp01(*l.UserMoneyAttitude),
	}, nil
}

func pairCompatibility(a, b []float64) float64 {
	var sum float64
	for i := 0; i < len(a); i++ {
		diff := math.Abs(a[i] - b[i])
		sum += diff
	}
	avgDiff := sum / float64(len(a))
	return clamp01(1 - avgDiff)
}

type PairScore struct {
	UserAID  uint
	UserBID  uint
	ScorePct float64
}

func (s lifestyleService) GetRoomAverageCompatibilityByRoomId(roomId int) (avgPct float64, best PairScore, worst PairScore, err error) {
	lifestyles, err := s.lifestyleRepo.GetLifestylesByRoomId(roomId)
	if err != nil {
		return 0, PairScore{}, PairScore{}, err
	}

	n := len(lifestyles)
	if n < 2 {
		return 0, PairScore{}, PairScore{}, fiber.NewError(fiber.StatusBadRequest, "need at least two members in the room")
	}

	traits := make([][]float64, 0, n)
	userIDs := make([]uint, 0, n)

	for i := range lifestyles {
		if lifestyles[i].UserID == nil {
			return 0, PairScore{}, PairScore{}, fiber.NewError(fiber.StatusUnprocessableEntity, "missing user ID in lifestyle data")
		}

		t6, err := traits6(lifestyles[i])
		if err != nil {
			return 0, PairScore{}, PairScore{}, err
		}
		traits = append(traits, t6)
		userIDs = append(userIDs, uint(*lifestyles[i].UserID))
	}

	var total float64
	var count int
	var bestScore float64 = 0
	var worstScore float64 = 1
	var bestPair, worstPair PairScore

	for i := 0; i < n; i++ {
		for j := i + 1; j < n; j++ {
			score := pairCompatibility(traits[i], traits[j])
			scorePct := score * 100.0

			total += score
			count++

			if score > bestScore {
				bestScore = score
				bestPair = PairScore{
					UserAID:  userIDs[i],
					UserBID:  userIDs[j],
					ScorePct: scorePct,
				}
			}

			if score < worstScore {
				worstScore = score
				worstPair = PairScore{
					UserAID:  userIDs[i],
					UserBID:  userIDs[j],
					ScorePct: scorePct,
				}
			}
		}
	}

	if count == 0 {
		return 0, PairScore{}, PairScore{}, fiber.NewError(fiber.StatusInternalServerError, "no pairs to compute")
	}

	avgScore := total / float64(count)
	return avgScore * 100.0, bestPair, worstPair, nil
}

func (s lifestyleService) GetCompatibilityMatchesByRoomAndUser(roomId int, userId int) (dtos.CompatibilityMatchResponse, error) {
	// Get all lifestyles in the room
	lifestyles, err := s.lifestyleRepo.GetLifestylesByRoomId(roomId)
	if err != nil {
		return dtos.CompatibilityMatchResponse{}, err
	}

	if len(lifestyles) < 2 {
		return dtos.CompatibilityMatchResponse{}, fiber.NewError(fiber.StatusBadRequest, "need at least two members in the room")
	}

	// Get users in room for username and profile picture
	users, err := s.lifestyleRepo.GetUsersInRoom(roomId)
	if err != nil {
		return dtos.CompatibilityMatchResponse{}, err
	}

	// Find the target user's lifestyle
	var targetLifestyle *entities.Lifestyle
	for _, l := range lifestyles {
		if l != nil && l.UserID != nil && *l.UserID == uint(userId) {
			targetLifestyle = l
			break
		}
	}

	if targetLifestyle == nil {
		return dtos.CompatibilityMatchResponse{}, fiber.NewError(fiber.StatusNotFound, "user not found in room or has no lifestyle data")
	}

	// Get target user traits
	targetTraits, err := traits6(targetLifestyle)
	if err != nil {
		return dtos.CompatibilityMatchResponse{}, err
	}

	// Helper function to get user details by ID
	getUserDetails := func(uid uint) (username string, profilePicture *string) {
		for _, u := range users {
			if u != nil && u.UserID != nil && uint(*u.UserID) == uid {
				if u.Username != nil {
					username = *u.Username
				}
				profilePicture = u.UserPicture
				break
			}
		}
		return username, profilePicture
	}

	// Helper function to convert score to match label
	getMatchLabel := func(score float64) string {
		switch {
		case score >= 90:
			return "Perfect Match"
		case score >= 75:
			return "Very Good Match"
		case score >= 60:
			return "Good Match"
		case score >= 40:
			return "Average Match"
		default:
			return "Bad Match"
		}
	}

	// Calculate compatibility with other users
	var matches []dtos.CompatibilityMatchItem
	for _, otherLifestyle := range lifestyles {
		if otherLifestyle == nil || otherLifestyle.UserID == nil || *otherLifestyle.UserID == uint(userId) {
			continue // Skip target user or invalid entries
		}

		otherTraits, err := traits6(otherLifestyle)
		if err != nil {
			continue // Skip users with incomplete data
		}

		// Calculate compatibility score
		compatibilityScore := pairCompatibility(targetTraits, otherTraits)
		scorePct := compatibilityScore * 100.0

		// Get user details
		username, profilePicture := getUserDetails(uint(*otherLifestyle.UserID))

		match := dtos.CompatibilityMatchItem{
			UserID:         uint(*otherLifestyle.UserID),
			Username:       username,
			ProfilePicture: profilePicture,
			Score:          scorePct,
			Match:          getMatchLabel(scorePct),
		}

		matches = append(matches, match)
	}

	// Sort matches by score (highest first)
	for i := 0; i < len(matches)-1; i++ {
		for j := i + 1; j < len(matches); j++ {
			if matches[i].Score < matches[j].Score {
				matches[i], matches[j] = matches[j], matches[i]
			}
		}
	}

	response := dtos.CompatibilityMatchResponse{
		RoomID:  uint(roomId),
		UserID:  uint(userId),
		Matches: matches,
	}

	return response, nil
}
