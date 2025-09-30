package service

import (
	"fairnest/internal/dtos"
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"fairnest/internal/utils"
	"fairnest/internal/utils/v"
	"log"
	"math/rand"
	"sort"
	"time"

	"github.com/gofiber/fiber/v2"
)

type roomService struct {
	roomRepo      repository.RoomRepository
	roomMemberSer RoomMemberService
	lifestyleSer  LifestyleService
}

func NewRoomService(roomRepo repository.RoomRepository, roomMemberSer RoomMemberService, lifestyleSer LifestyleService) roomService {
	return roomService{
		roomRepo:      roomRepo,
		roomMemberSer: roomMemberSer,
		lifestyleSer:  lifestyleSer,
	}
}

func (s roomService) FetchAllRoom() ([]entities.Room, error) {
	rooms, err := s.roomRepo.FetchAllRoom()
	if err != nil {
		log.Println(err)
		return nil, err
	}

	roomResponses := []entities.Room{}
	for _, room := range rooms {
		roomResponse := entities.Room{
			RoomID: room.RoomID,
			// RoomDetails
			RoomName:               room.RoomName,
			RoomType:               room.RoomType,
			RoomMaxCapacity:        room.RoomMaxCapacity,
			RoomCurrentCapacity:    room.RoomCurrentCapacity,
			RoomDescription:        room.RoomDescription,
			RoomCode:               room.RoomCode,
			RoomCompatibilityScore: room.RoomCompatibilityScore,
			RoomPicture:            room.RoomPicture,
			// LivingSpaceDetails
			LivingSpaceName:        room.LivingSpaceName,
			RentCost:               room.RentCost,
			ElectricityCostPerUnit: room.ElectricityCostPerUnit,
			WaterCostPerUnit:       room.WaterCostPerUnit,
			OtherUtilityDetails:    room.OtherUtilityDetails,
			// RoommateAgreements
			QuietHoursStart: room.QuietHoursStart,
			GuestStayOver:   room.GuestStayOver,
			HandleCleaning:  room.HandleCleaning,
			SharedSpace:     room.SharedSpace,
			SplitCosts:      room.SplitCosts,
			// Personality Averages
			AvgTidiness:       room.AvgTidiness,
			AvgNoiseActivity:  room.AvgNoiseActivity,
			AvgSchedule:       room.AvgSchedule,
			AvgGuestFrequency: room.AvgGuestFrequency,
			AvgTaskStructure:  room.AvgTaskStructure,
			AvgMoneyAttitude:  room.AvgMoneyAttitude,
		}
		roomResponses = append(roomResponses, roomResponse)
	}
	return roomResponses, nil
}

func (s roomService) FetchAllRoomWithRoomMembersDetails() ([]dtos.FetchAllRoomWithRoomMembersResponse, error) {
	// Step 1: get all rooms
	rooms, err := s.roomRepo.FetchAllRoom()
	if err != nil {
		return nil, err
	}

	// Step 2: build response per room
	responses := make([]dtos.FetchAllRoomWithRoomMembersResponse, 0, len(rooms))
	for _, r := range rooms {
		// call RoomMemberService instead of repo
		members, err := s.roomMemberSer.FetchAllRoomMemberWithUserDetailsByRoomId(v.UintToInt(v.UintValue(r.RoomID)))
		if err != nil {
			return nil, err
		}

		responses = append(responses, dtos.FetchAllRoomWithRoomMembersResponse{
			// RoomDetails
			RoomID:                 r.RoomID,
			RoomName:               r.RoomName,
			RoomType:               r.RoomType,
			RoomMaxCapacity:        r.RoomMaxCapacity,
			RoomCurrentCapacity:    r.RoomCurrentCapacity,
			RoomDescription:        r.RoomDescription,
			RoomCode:               r.RoomCode,
			RoomCompatibilityScore: r.RoomCompatibilityScore,
			RoomPicture:            r.RoomPicture,

			// LivingSpaceDetails
			LivingSpaceName:        r.LivingSpaceName,
			RentCost:               r.RentCost,
			ElectricityCostPerUnit: r.ElectricityCostPerUnit,
			WaterCostPerUnit:       r.WaterCostPerUnit,
			OtherUtilityDetails:    r.OtherUtilityDetails,

			//// RoommateAgreements
			QuietHoursStart: r.QuietHoursStart,
			GuestStayOver:   r.GuestStayOver,
			HandleCleaning:  r.HandleCleaning,
			SharedSpace:     r.SharedSpace,
			SplitCosts:      r.SplitCosts,

			//// Personality Averages
			AvgTidiness:       r.AvgTidiness,
			AvgNoiseActivity:  r.AvgNoiseActivity,
			AvgSchedule:       r.AvgSchedule,
			AvgGuestFrequency: r.AvgGuestFrequency,
			AvgTaskStructure:  r.AvgTaskStructure,
			AvgMoneyAttitude:  r.AvgMoneyAttitude,

			Members: members,
		})
	}

	return responses, nil
}

func (s roomService) FetchAllRoomSuitUserLifestyleByUserId(userId int) ([]dtos.FetchAllRoomSuitUserLifestyleByUserIdResponse, error) {
	// Step 1: fetch all rooms
	rooms, err := s.roomRepo.FetchAllRoom()
	if err != nil {
		return nil, err
	}

	// Step 2: fetch user lifestyle
	userLifestyle, err := s.lifestyleSer.GetUserLifestyleByUserId(userId)
	if err != nil {
		return nil, err
	}

	// Step 3: calculate compatibility for each room
	responses := make([]dtos.FetchAllRoomSuitUserLifestyleByUserIdResponse, 0, len(rooms))
	for _, r := range rooms {
		percent := utils.CalculateCompatibility(*userLifestyle, r)

		responses = append(responses, dtos.FetchAllRoomSuitUserLifestyleByUserIdResponse{
			RoomID:                 r.RoomID,
			RoomName:               r.RoomName,
			RoomType:               r.RoomType,
			RoomMaxCapacity:        r.RoomMaxCapacity,
			RoomCurrentCapacity:    r.RoomCurrentCapacity,
			RoomDescription:        r.RoomDescription,
			RoomCode:               r.RoomCode,
			RoomCompatibilityScore: r.RoomCompatibilityScore,
			RoomPicture:            r.RoomPicture,
			CompatibilityPercent:   v.Ptr(percent),
		})
	}

	// Step 4: sort by compatibility descending
	sort.Slice(responses, func(i, j int) bool {
		return v.Float64Value(responses[i].CompatibilityPercent) > v.Float64Value(responses[j].CompatibilityPercent)
	})
	return responses, nil
}

////////////////////////////////////////////////////////////////////////////////////////////////////////

func (s roomService) CreateRoomByUserId(userId int, request dtos.CreateRoomByUserIdRequest) (*dtos.CreateRoomByUserIdResponse, error) {
	// Mock rng Room Picture
	roomPictures := []string{
		"https://minio.bocchikitsunei.com/fairnest/rng_room_1.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_2.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_3.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_4.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_5.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_6.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_7.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_8.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_9.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_10.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_11.png",
		"https://minio.bocchikitsunei.com/fairnest/rng_room_12.png",
	}
	rand.Seed(time.Now().UnixNano())
	randomRoomPicture := roomPictures[rand.Intn(len(roomPictures))]

	// Generate unique room code
	var code string
	for {
		code = utils.GenerateRoomCode(6)
		exists, err := s.roomRepo.ExistsByCode(code)
		if err != nil {
			return nil, err
		}
		if !exists {
			break
		}
	}
	// Get user personality to set initial avg personality of the room
	hostLifestyle, err := s.lifestyleSer.GetUserLifestyleByUserId(userId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	room := entities.Room{
		// RoomDetails
		RoomName:               request.RoomName,
		RoomType:               request.RoomType,
		RoomMaxCapacity:        request.RoomMaxCapacity,
		RoomCurrentCapacity:    v.Ptr(1), // Since the creator is the first member
		RoomDescription:        request.RoomDescription,
		RoomCode:               v.Ptr(code),
		RoomCompatibilityScore: request.RoomCompatibilityScore,
		RoomPicture:            v.Ptr(randomRoomPicture),

		// LivingSpaceDetails
		LivingSpaceName:        request.LivingSpaceName,
		RentCost:               request.RentCost,
		ElectricityCostPerUnit: request.ElectricityCostPerUnit,
		WaterCostPerUnit:       request.WaterCostPerUnit,
		OtherUtilityDetails:    request.OtherUtilityDetails,
		// RoommateAgreements
		QuietHoursStart: request.QuietHoursStart,
		GuestStayOver:   request.GuestStayOver,
		HandleCleaning:  request.HandleCleaning,
		SharedSpace:     request.SharedSpace,
		SplitCosts:      request.SplitCosts,

		// Personality Averages - set to host personality initially
		AvgTidiness:       hostLifestyle.UserTidiness,
		AvgNoiseActivity:  hostLifestyle.UserNoiseActivity,
		AvgSchedule:       hostLifestyle.UserSchedule,
		AvgGuestFrequency: hostLifestyle.UserGuestFrequency,
		AvgTaskStructure:  hostLifestyle.UserTaskStructure,
		AvgMoneyAttitude:  hostLifestyle.UserMoneyAttitude,
	}

	if err := s.roomRepo.CreateRoomByUserId(&room); err != nil {
		return nil, err
	}

	_, err = s.roomMemberSer.CreateRoomMemberByRoomIdAndUserId(v.IntValue(v.UintToIntPtr(room.RoomID)), userId)
	if err != nil {
		return nil, err
	}

	return &dtos.CreateRoomByUserIdResponse{
		RoomID:                 room.RoomID,
		RoomName:               room.RoomName,
		RoomType:               room.RoomType,
		RoomMaxCapacity:        room.RoomMaxCapacity,
		RoomCurrentCapacity:    room.RoomCurrentCapacity,
		RoomDescription:        room.RoomDescription,
		RoomCode:               room.RoomCode,
		RoomCompatibilityScore: room.RoomCompatibilityScore,
		RoomPicture:            room.RoomPicture,

		// LivingSpaceDetails
		LivingSpaceName:        room.LivingSpaceName,
		RentCost:               room.RentCost,
		ElectricityCostPerUnit: room.ElectricityCostPerUnit,
		WaterCostPerUnit:       room.WaterCostPerUnit,
		OtherUtilityDetails:    room.OtherUtilityDetails,

		// RoommateAgreements
		QuietHoursStart: room.QuietHoursStart,
		GuestStayOver:   room.GuestStayOver,
		HandleCleaning:  room.HandleCleaning,
		SharedSpace:     room.SharedSpace,
		SplitCosts:      room.SplitCosts,

		// Personality Averages - set to host personality initially
		AvgTidiness:       room.AvgTidiness,
		AvgNoiseActivity:  room.AvgNoiseActivity,
		AvgSchedule:       room.AvgSchedule,
		AvgGuestFrequency: room.AvgGuestFrequency,
		AvgTaskStructure:  room.AvgTaskStructure,
		AvgMoneyAttitude:  room.AvgMoneyAttitude,
	}, nil
}

func (s roomService) FetchAllPublicRoomSuitUserLifestyleByUserId(userId int) ([]dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse, error) {
	// Step 1: fetch all rooms
	rooms, err := s.roomRepo.FetchAllPublicRoom()
	if err != nil {
		return nil, err
	}

	// Step 2: fetch user lifestyle
	userLifestyle, err := s.lifestyleSer.GetUserLifestyleByUserId(userId)
	if err != nil {
		return nil, err
	}

	// Step 3: calculate compatibility for each room
	responses := make([]dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse, 0, len(rooms))
	for _, r := range rooms {
		percent := utils.CalculateCompatibility(*userLifestyle, r)

		responses = append(responses, dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse{
			RoomID:                 r.RoomID,
			RoomName:               r.RoomName,
			RoomType:               r.RoomType,
			RoomMaxCapacity:        r.RoomMaxCapacity,
			RoomCurrentCapacity:    r.RoomCurrentCapacity,
			RoomDescription:        r.RoomDescription,
			RoomCode:               r.RoomCode,
			RoomCompatibilityScore: r.RoomCompatibilityScore,
			RoomPicture:            r.RoomPicture,
			CompatibilityPercent:   v.Ptr(percent),
		})
	}

	// Step 4: sort by compatibility descending
	sort.Slice(responses, func(i, j int) bool {
		return v.Float64Value(responses[i].CompatibilityPercent) > v.Float64Value(responses[j].CompatibilityPercent)
	})
	return responses, nil
}

func (s roomService) GetMyRoomByUserId(userId int) (*dtos.GetMyRoomByUserIdResponse, error) {
	// Step 1: fetch room
	room, err := s.roomRepo.GetMyRoomByUserId(userId)
	if err != nil {
		return nil, err
	}

	// Step 2: fetch user lifestyle
	userLifestyle, err := s.lifestyleSer.GetUserLifestyleByUserId(userId)
	if err != nil {
		return nil, err
	}

	// Step 3: calculate compatibility
	percent := utils.CalculateCompatibility(*userLifestyle, *room)

	// Step 4: build response
	response := &dtos.GetMyRoomByUserIdResponse{
		RoomID:                 room.RoomID,
		RoomName:               room.RoomName,
		RoomType:               room.RoomType,
		RoomMaxCapacity:        room.RoomMaxCapacity,
		RoomCurrentCapacity:    room.RoomCurrentCapacity,
		RoomDescription:        room.RoomDescription,
		RoomCode:               room.RoomCode,
		RoomCompatibilityScore: room.RoomCompatibilityScore,
		RoomPicture:            room.RoomPicture,
		CompatibilityPercent:   v.Ptr(percent),
	}

	return response, nil
}

func (s roomService) FilterPublicRoomSuitUserLifestyleByUserId(userId int, filters map[string]interface{}) ([]dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse, error) {
	// Step 1: fetch all rooms
	rooms, err := s.roomRepo.FetchAllRoom()
	if err != nil {
		return nil, err
	}

	// Step 2: fetch user lifestyle
	userLifestyle, err := s.lifestyleSer.GetUserLifestyleByUserId(userId)
	if err != nil {
		return nil, err
	}

	// Step 3: Filter rooms at entity level BEFORE calculating compatibility
	filteredRooms := s.applyFiltersToEntities(rooms, filters)

	// Step 4: Calculate compatibility for filtered rooms and create response DTOs
	responses := make([]dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse, 0, len(filteredRooms))
	for _, r := range filteredRooms {
		percent := utils.CalculateCompatibility(*userLifestyle, r)

		responses = append(responses, dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse{
			RoomID:                 r.RoomID,
			RoomName:               r.RoomName,
			RoomType:               r.RoomType,
			RoomMaxCapacity:        r.RoomMaxCapacity,
			RoomCurrentCapacity:    r.RoomCurrentCapacity,
			RoomDescription:        r.RoomDescription,
			RoomCode:               r.RoomCode,
			RoomCompatibilityScore: r.RoomCompatibilityScore,
			RoomPicture:            r.RoomPicture,
			CompatibilityPercent:   v.Ptr(percent),
		})
	}

	// Step 5: Apply compatibility filter if specified (after compatibility calculation)
	finalResponses := s.applyCompatibilityFilter(responses, filters)

	// Step 6: Sort by compatibility descending
	sort.Slice(finalResponses, func(i, j int) bool {
		return v.Float64Value(finalResponses[i].CompatibilityPercent) > v.Float64Value(finalResponses[j].CompatibilityPercent)
	})

	return finalResponses, nil
}

// Add these new helper methods to your service:
func (s roomService) applyFiltersToEntities(rooms []entities.Room, filters map[string]interface{}) []entities.Room {
	if len(filters) == 0 {
		return rooms
	}

	filtered := make([]entities.Room, 0)

	for _, room := range rooms {
		if s.shouldIncludeRoomEntity(room, filters) {
			filtered = append(filtered, room)
		}
	}

	return filtered
}

func (s roomService) shouldIncludeRoomEntity(room entities.Room, filters map[string]interface{}) bool {
	// Max capacity filter
	if maxCap, ok := filters["maxCapacity"].(int); ok {
		if room.RoomMaxCapacity != nil && *room.RoomMaxCapacity > maxCap {
			return false
		}
	}

	// Rent cost filters
	if minRent, ok := filters["minRent"].(float64); ok {
		if room.RentCost != nil && float64(*room.RentCost) < minRent {
			return false
		}
	}
	if maxRent, ok := filters["maxRent"].(float64); ok {
		if room.RentCost != nil && float64(*room.RentCost) > maxRent {
			return false
		}
	}

	// Electricity cost filter
	if maxElec, ok := filters["maxElectricity"].(float64); ok {
		if room.ElectricityCostPerUnit != nil && float64(*room.ElectricityCostPerUnit) > maxElec {
			return false
		}
	}

	// Water cost filter
	if maxWater, ok := filters["maxWater"].(float64); ok {
		if room.WaterCostPerUnit != nil && float64(*room.WaterCostPerUnit) > maxWater {
			return false
		}
	}

	// Quiet hours filter
	if quietStart, ok := filters["quietHoursStart"].(string); ok {
		if room.QuietHoursStart != nil && *room.QuietHoursStart != quietStart {
			return false
		}
	}

	return true
}

func (s roomService) applyCompatibilityFilter(responses []dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse, filters map[string]interface{}) []dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse {
	if minCompat, ok := filters["minCompatibility"].(float64); !ok {
		return responses // No compatibility filter
	} else {
		filtered := make([]dtos.FetchAllPublicRoomSuitUserLifestyleByUserIdResponse, 0)
		for _, room := range responses {
			if room.CompatibilityPercent != nil && *room.CompatibilityPercent >= minCompat {
				filtered = append(filtered, room)
			}
		}
		return filtered
	}
}

func (s roomService) GetRoomDetailsByRoomId(roomId int) (*dtos.GetRoomDetailsByRoomIdResponse, error) {
	room, err := s.roomRepo.GetRoomDetailsByRoomId(roomId)
	if err != nil {
		return nil, err
	}

	members := make([]dtos.FetchAllRoomMemberWithUserDetailsResponse, 0, len(room.RoomMembers))
	for _, m := range room.RoomMembers {
		members = append(members, dtos.FetchAllRoomMemberWithUserDetailsResponse{
			RoomMemberID: m.RoomMemberID,
			UserID:       m.UserID,
			IsHost:       m.IsHost,
			Username:     m.User.Username,
			Email:        m.User.Email,
			Firstname:    m.User.Firstname,
			Lastname:     m.User.Lastname,
			PhoneNumber:  m.User.PhoneNumber,
			UserPicture:  m.User.UserPicture,
			UserAboutMe:  m.User.UserAboutMe,
		})
	}

	return &dtos.GetRoomDetailsByRoomIdResponse{
		RoomID:                 room.RoomID,
		RoomName:               room.RoomName,
		RoomType:               room.RoomType,
		RoomMaxCapacity:        room.RoomMaxCapacity,
		RoomCurrentCapacity:    room.RoomCurrentCapacity,
		RoomDescription:        room.RoomDescription,
		RoomCode:               room.RoomCode,
		RoomCompatibilityScore: room.RoomCompatibilityScore,
		RoomPicture:            room.RoomPicture,
		// LivingSpaceDetails
		LivingSpaceName:        room.LivingSpaceName,
		RentCost:               room.RentCost,
		ElectricityCostPerUnit: room.ElectricityCostPerUnit,
		WaterCostPerUnit:       room.WaterCostPerUnit,
		OtherUtilityDetails:    room.OtherUtilityDetails,
		// RoommateAgreements
		QuietHoursStart: room.QuietHoursStart,
		GuestStayOver:   room.GuestStayOver,
		HandleCleaning:  room.HandleCleaning,
		SharedSpace:     room.SharedSpace,
		SplitCosts:      room.SplitCosts,
		// Personality Averages
		AvgTidiness:       room.AvgTidiness,
		AvgNoiseActivity:  room.AvgNoiseActivity,
		AvgSchedule:       room.AvgSchedule,
		AvgGuestFrequency: room.AvgGuestFrequency,
		AvgTaskStructure:  room.AvgTaskStructure,
		AvgMoneyAttitude:  room.AvgMoneyAttitude,
		// Members with user details
		Members: members,
	}, nil
}

func (s roomService) GetRoomDetailsByRoomCode(roomCode string) (*dtos.GetRoomDetailsByRoomCodeResponse, error) {
	room, err := s.roomRepo.GetRoomDetailsByRoomCode(roomCode)
	if err != nil {
		return nil, err
	}

	members := make([]dtos.FetchAllRoomMemberWithUserDetailsResponse, 0, len(room.RoomMembers))
	for _, m := range room.RoomMembers {
		members = append(members, dtos.FetchAllRoomMemberWithUserDetailsResponse{
			RoomMemberID: m.RoomMemberID,
			UserID:       m.UserID,
			IsHost:       m.IsHost,
			Username:     m.User.Username,
			Email:        m.User.Email,
			Firstname:    m.User.Firstname,
			Lastname:     m.User.Lastname,
			PhoneNumber:  m.User.PhoneNumber,
			UserPicture:  m.User.UserPicture,
			UserAboutMe:  m.User.UserAboutMe,
		})
	}

	return &dtos.GetRoomDetailsByRoomCodeResponse{
		RoomID:                 room.RoomID,
		RoomName:               room.RoomName,
		RoomType:               room.RoomType,
		RoomMaxCapacity:        room.RoomMaxCapacity,
		RoomCurrentCapacity:    room.RoomCurrentCapacity,
		RoomDescription:        room.RoomDescription,
		RoomCode:               room.RoomCode,
		RoomCompatibilityScore: room.RoomCompatibilityScore,
		RoomPicture:            room.RoomPicture,
		// LivingSpaceDetails
		LivingSpaceName:        room.LivingSpaceName,
		RentCost:               room.RentCost,
		ElectricityCostPerUnit: room.ElectricityCostPerUnit,
		WaterCostPerUnit:       room.WaterCostPerUnit,
		OtherUtilityDetails:    room.OtherUtilityDetails,
		// RoommateAgreements
		QuietHoursStart: room.QuietHoursStart,
		GuestStayOver:   room.GuestStayOver,
		HandleCleaning:  room.HandleCleaning,
		SharedSpace:     room.SharedSpace,
		SplitCosts:      room.SplitCosts,
		// Personality Averages
		AvgTidiness:       room.AvgTidiness,
		AvgNoiseActivity:  room.AvgNoiseActivity,
		AvgSchedule:       room.AvgSchedule,
		AvgGuestFrequency: room.AvgGuestFrequency,
		AvgTaskStructure:  room.AvgTaskStructure,
		AvgMoneyAttitude:  room.AvgMoneyAttitude,
		// Members with user details
		Members: members,
	}, nil
}

func (s roomService) GetHouseRulesByRoomId(roomId int) (*entities.Room, error) {
	room, err := s.roomRepo.GetRoomDetailsByRoomId(roomId)
	if err != nil {
		return nil, err
	}

	if room.RoomID == nil &&
		room.QuietHoursStart == nil &&
		room.GuestStayOver == nil &&
		room.HandleCleaning == nil &&
		room.SharedSpace == nil &&
		room.SplitCosts == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "room data is not found")
	}

	roomResponse := entities.Room{
		RoomID:          room.RoomID,
		QuietHoursStart: room.QuietHoursStart,
		GuestStayOver:   room.GuestStayOver,
		HandleCleaning:  room.HandleCleaning,
		SharedSpace:     room.SharedSpace,
		SplitCosts:      room.SplitCosts,
	}
	return &roomResponse, nil
}

func (s roomService) PatchEditHouseRulesByRoomId(roomId int, req dtos.PatchEditHouseRulesByRoomIdRequest) (*entities.Room, error) {
	room := &entities.Room{
		RoomID:          v.UintPtr(roomId),
		QuietHoursStart: req.QuietHoursStart,
		GuestStayOver:   req.GuestStayOver,
		HandleCleaning:  req.HandleCleaning,
		SharedSpace:     req.SharedSpace,
		SplitCosts:      req.SplitCosts,
	}

	err := s.roomRepo.PatchEditHouseRulesByRoomId(room)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	return room, nil
}

func (s roomService) GetRoomOverallLifestyleByRoomId(roomId int) (*entities.Room, error) {
	room, err := s.roomRepo.GetRoomOverallLifestyleByRoomId(roomId)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if room.RoomID == nil &&
		room.AvgTidiness == nil &&
		room.AvgNoiseActivity == nil &&
		room.AvgSchedule == nil &&
		room.AvgGuestFrequency == nil &&
		room.AvgTaskStructure == nil &&
		room.AvgMoneyAttitude == nil {
		return nil, fiber.NewError(fiber.StatusNotFound, "room overall lifestyle data is not found")
	}

	roomResponse := entities.Room{
		RoomID:            room.RoomID,
		AvgTidiness:       room.AvgTidiness,
		AvgNoiseActivity:  room.AvgNoiseActivity,
		AvgSchedule:       room.AvgSchedule,
		AvgGuestFrequency: room.AvgGuestFrequency,
		AvgTaskStructure:  room.AvgTaskStructure,
		AvgMoneyAttitude:  room.AvgMoneyAttitude,
	}
	return &roomResponse, nil
}

func (s roomService) GetMyPendingRoomByUserID(userID int) (*dtos.GetMyPendingRoomByUserIDResponse, error) {
	// Step 1: fetch room
	room, err := s.roomRepo.GetMyPendingRoomByUserID(userID)
	if err != nil {
		return nil, err
	}

	// Step 2: fetch user lifestyle
	userLifestyle, err := s.lifestyleSer.GetUserLifestyleByUserId(userID)
	if err != nil {
		return nil, err
	}

	roomToCalculateCompatibility := &entities.Room{
		RoomID:                 room.RoomID,
		RoomName:               room.RoomName,
		RoomType:               room.RoomType,
		RoomMaxCapacity:        room.RoomMaxCapacity,
		RoomCurrentCapacity:    room.RoomCurrentCapacity,
		RoomDescription:        room.RoomDescription,
		RoomCode:               room.RoomCode,
		RoomCompatibilityScore: room.RoomCompatibilityScore,
		RoomPicture:            room.RoomPicture,
	}
	// Step 3: calculate compatibility
	percent := utils.CalculateCompatibility(*userLifestyle, *roomToCalculateCompatibility)

	// Step 4: build response
	response := &dtos.GetMyPendingRoomByUserIDResponse{
		RoomID:                 room.RoomID,
		RoomName:               room.RoomName,
		RoomType:               room.RoomType,
		RoomMaxCapacity:        room.RoomMaxCapacity,
		RoomCurrentCapacity:    room.RoomCurrentCapacity,
		RoomDescription:        room.RoomDescription,
		RoomCode:               room.RoomCode,
		RoomCompatibilityScore: room.RoomCompatibilityScore,
		RoomPicture:            room.RoomPicture,
		CompatibilityPercent:   v.Ptr(percent),

		RoomJoinRequestID: room.RoomJoinRequestID,
	}

	return response, nil
}

func (s roomService) GetMyPendingRoomDetailsByRoomIdRoomJoinRequestID(roomID int, roomJoinRequestID int) (*dtos.GetMyPendingRoomDetailsByRoomIdResponse, error) {
	room, err := s.roomRepo.GetRoomDetailsByRoomId(roomID)
	if err != nil {
		return nil, err
	}

	status, err := s.roomRepo.GetVotingStatisticsByRoomJoinRequestID(roomJoinRequestID)
	if err != nil {
		return nil, err
	}

	members := make([]dtos.FetchAllRoomMemberWithUserDetailsResponse, 0, len(room.RoomMembers))
	for _, m := range room.RoomMembers {
		members = append(members, dtos.FetchAllRoomMemberWithUserDetailsResponse{
			RoomMemberID: m.RoomMemberID,
			UserID:       m.UserID,
			IsHost:       m.IsHost,
			Username:     m.User.Username,
			Email:        m.User.Email,
			Firstname:    m.User.Firstname,
			Lastname:     m.User.Lastname,
			PhoneNumber:  m.User.PhoneNumber,
			UserPicture:  m.User.UserPicture,
			UserAboutMe:  m.User.UserAboutMe,
		})
	}

	return &dtos.GetMyPendingRoomDetailsByRoomIdResponse{
		RoomID:                 room.RoomID,
		RoomName:               room.RoomName,
		RoomType:               room.RoomType,
		RoomMaxCapacity:        room.RoomMaxCapacity,
		RoomCurrentCapacity:    room.RoomCurrentCapacity,
		RoomDescription:        room.RoomDescription,
		RoomCode:               room.RoomCode,
		RoomCompatibilityScore: room.RoomCompatibilityScore,
		RoomPicture:            room.RoomPicture,
		// LivingSpaceDetails
		LivingSpaceName:        room.LivingSpaceName,
		RentCost:               room.RentCost,
		ElectricityCostPerUnit: room.ElectricityCostPerUnit,
		WaterCostPerUnit:       room.WaterCostPerUnit,
		OtherUtilityDetails:    room.OtherUtilityDetails,
		// RoommateAgreements
		QuietHoursStart: room.QuietHoursStart,
		GuestStayOver:   room.GuestStayOver,
		HandleCleaning:  room.HandleCleaning,
		SharedSpace:     room.SharedSpace,
		SplitCosts:      room.SplitCosts,
		// Personality Averages
		AvgTidiness:       room.AvgTidiness,
		AvgNoiseActivity:  room.AvgNoiseActivity,
		AvgSchedule:       room.AvgSchedule,
		AvgGuestFrequency: room.AvgGuestFrequency,
		AvgTaskStructure:  room.AvgTaskStructure,
		AvgMoneyAttitude:  room.AvgMoneyAttitude,

		// Voting status
		VotingStatus: status,

		// Members with user details
		Members: members,
	}, nil
}
