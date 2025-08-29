package service

import (
	"fairnest/internal/entities"
	"fairnest/internal/repository"
	"log"
)

type roomService struct {
	roomRepo repository.RoomRepository
}

func NewRoomService(roomRepo repository.RoomRepository) roomService {
	return roomService{
		roomRepo: roomRepo,
	}
}

func (s roomService) FetchRooms() ([]entities.Room, error) {
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
