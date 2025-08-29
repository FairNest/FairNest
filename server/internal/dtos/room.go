package dtos

type RoomDataResponse struct {
	RoomID *uint `json:"room_id" validate:"required"`

	// RoomDetails
	RoomName               *string `json:"room_name" validate:"required" `
	RoomType               *bool   `json:"room_type" validate:"required"`
	RoomMaxCapacity        *int    `json:"room_max_capacity" validate:"required"`
	RoomCurrentCapacity    *int    `json:"room_current_capacity" validate:"required"`
	RoomDescription        *string `json:"room_description" validate:"required"`
	RoomCode               *string `json:"room_code" validate:"required"`
	RoomCompatibilityScore *int    `json:"room_compatibility_score" validate:"required"`
	RoomPicture            *string `json:"room_picture" validate:"required"`

	// LivingSpaceDetails
	LivingSpaceName        *string `json:"living_space_name" validate:"required"`
	RentCost               *int    `json:"rent_cost" validate:"required"`
	ElectricityCostPerUnit *int    `json:"electricity_cost_per_unit" validate:"required"`
	WaterCostPerUnit       *int    `json:"water_cost_per_unit" validate:"required"`
	OtherUtilityDetails    *string `json:"other_utility_details" validate:"required"`

	// RoommateAgreements
	QuietHoursStart *string `json:"quiet_hours_start" validate:"required"`
	GuestStayOver   *string `json:"guest_stay_over" validate:"required"`
	HandleCleaning  *string `json:"handle_cleaning" validate:"required"`
	SharedSpace     *string `json:"shared_space" validate:"required"`
	SplitCosts      *bool   `json:"split_costs" validate:"required"`

	// Personality Averages
	AvgTidiness       *float64 `json:"avg_tidiness" validate:"required"`
	AvgNoiseActivity  *float64 `json:"avg_noise_activity" validate:"required"`
	AvgSchedule       *float64 `json:"avg_schedule" validate:"required"`
	AvgGuestFrequency *float64 `json:"avg_guest_frequency" validate:"required"`
	AvgTaskStructure  *float64 `json:"avg_task_structure" validate:"required"`
	AvgMoneyAttitude  *float64 `json:"avg_money_attitude" validate:"required"`

	// Members
	Members []RoomMemberDataResponse `json:"members" validate:"required"`
}

type RoomMemberDataResponse struct {
	RoomMemberID *uint `json:"room_member_id" validate:"required"`
	UserID       *uint `json:"user_id" validate:"required"`
	IsHost       *bool `json:"is_host" validate:"required"`

	// Flatten user subset
	Username    *string `json:"username" validate:"required"`
	Email       *string `json:"email" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	PhoneNumber *string `json:"phone_number" validate:"required"`
	UserPicture *string `json:"user_picture" validate:"required"`
	UserAboutMe *string `json:"user_about_me" validate:"required"`
}

type CreateRoomByUserIdRequest struct {
	// RoomDetails
	RoomName               *string `json:"room_name" validate:"required"`
	RoomType               *bool   `json:"room_type" validate:"required"`
	RoomMaxCapacity        *int    `json:"room_max_capacity" validate:"required"`
	RoomCurrentCapacity    *int    `json:"room_current_capacity" validate:"required"`
	RoomDescription        *string `json:"room_description" validate:"required"`
	RoomCompatibilityScore *int    `json:"room_compatibility_score" validate:"required"`
	RoomPicture            *string `json:"room_picture" validate:"required"`

	// LivingSpaceDetails
	LivingSpaceName        *string `json:"living_space_name" validate:"required"`
	RentCost               *int    `json:"rent_cost" validate:"required"`
	ElectricityCostPerUnit *int    `json:"electricity_cost_per_unit" validate:"required"`
	WaterCostPerUnit       *int    `json:"water_cost_per_unit" validate:"required"`
	OtherUtilityDetails    *string `json:"other_utility_details" validate:"required"`

	// RoommateAgreements
	QuietHoursStart *string `json:"quiet_hours_start" validate:"required"`
	GuestStayOver   *string `json:"guest_stay_over" validate:"required"`
	HandleCleaning  *string `json:"handle_cleaning" validate:"required"`
	SharedSpace     *string `json:"shared_space" validate:"required"`
	SplitCosts      *bool   `json:"split_costs" validate:"required"`
}

type CreateRoomByUserIdResponse struct {
	// RoomDetails
	RoomID                 *uint   `json:"room_id" validate:"required"`
	RoomName               *string `json:"room_name" validate:"required"`
	RoomType               *bool   `json:"room_type" validate:"required"`
	RoomMaxCapacity        *int    `json:"room_max_capacity" validate:"required"`
	RoomCurrentCapacity    *int    `json:"room_current_capacity" validate:"required"`
	RoomDescription        *string `json:"room_description" validate:"required"`
	RoomCode               *string `json:"room_code" validate:"required"`
	RoomCompatibilityScore *int    `json:"room_compatibility_score" validate:"required"`
	RoomPicture            *string `json:"room_picture" validate:"required"`

	// LivingSpaceDetails
	LivingSpaceName        *string `json:"living_space_name" validate:"required"`
	RentCost               *int    `json:"rent_cost" validate:"required"`
	ElectricityCostPerUnit *int    `json:"electricity_cost_per_unit" validate:"required"`
	WaterCostPerUnit       *int    `json:"water_cost_per_unit" validate:"required"`
	OtherUtilityDetails    *string `json:"other_utility_details" validate:"required"`

	// RoommateAgreements
	QuietHoursStart *string `json:"quiet_hours_start" validate:"required"`
	GuestStayOver   *string `json:"guest_stay_over" validate:"required"`
	HandleCleaning  *string `json:"handle_cleaning" validate:"required"`
	SharedSpace     *string `json:"shared_space" validate:"required"`
	SplitCosts      *bool   `json:"split_costs" validate:"required"`

	// Personality Averages
	AvgTidiness       *float64 `json:"avg_tidiness" validate:"required"`
	AvgNoiseActivity  *float64 `json:"avg_noise_activity" validate:"required"`
	AvgSchedule       *float64 `json:"avg_schedule" validate:"required"`
	AvgGuestFrequency *float64 `json:"avg_guest_frequency" validate:"required"`
	AvgTaskStructure  *float64 `json:"avg_task_structure" validate:"required"`
	AvgMoneyAttitude  *float64 `json:"avg_money_attitude" validate:"required"`
}
