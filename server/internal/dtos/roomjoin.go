package dtos

// * response when join request is created
type CreateRoomJoinRequestByUserIdResponse struct {
	RoomJoinRequestID  *uint   `json:"room_join_request_id" validate:"required"`
	RoomID             *uint   `json:"room_id" validate:"required"`
	RequesterUserID    *uint   `json:"requester_user_id" validate:"required"`
	Status             *string `json:"status" validate:"required"` // * "pending", "approved", "rejected"
	EligibleVoterCount *int    `json:"eligible_voter_count" validate:"required"`
	CreatedAt          *string `json:"created_at" validate:"required"`
}

// * get join request details for voting
type GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserIDResponse struct {
	RoomJoinRequestID  *uint   `json:"room_join_request_id" validate:"required"`
	RoomID             *uint   `json:"room_id" validate:"required"`
	RequesterUserID    *uint   `json:"requester_user_id" validate:"required"`
	Status             *string `json:"status" validate:"required"`
	EligibleVoterCount *int    `json:"eligible_voter_count" validate:"required"`
	CreatedAt          *string `json:"created_at" validate:"required"`

	// Room details
	RoomName    *string `json:"room_name" validate:"required"`
	RoomPicture *string `json:"room_picture" validate:"required"`

	// Requester details
	UserID      *uint   `json:"user_id" validate:"required"`
	Username    *string `json:"username" validate:"required"`
	Firstname   *string `json:"firstname" validate:"required"`
	Lastname    *string `json:"lastname" validate:"required"`
	UserPicture *string `json:"user_picture" validate:"required"`
	UserAboutMe *string `json:"user_about_me" validate:"required"`

	// User compatibility scores
	UserTidiness         *float64 `json:"user_tidiness" validate:"required"`
	UserNoiseActivity    *float64 `json:"user_noise_activity" validate:"required"`
	UserSchedule         *float64 `json:"user_schedule" validate:"required"`
	UserGuestFrequency   *float64 `json:"user_guest_frequency" validate:"required"`
	UserTaskStructure    *float64 `json:"user_task_structure" validate:"required"`
	UserMoneyAttitude    *float64 `json:"user_money_attitude" validate:"required"`
	CompatibilityPercent *float64 `json:"compatibility_percent" validate:"required"`

	// Voting statistics
	TotalVoters  *int    `json:"total_voters"`  // * total number of eligible voters
	VotedCount   *int    `json:"voted_count"`   // * number of voters who have voted
	ApproveCount *int    `json:"approve_count"` // * number of "approve" votes
	RejectCount  *int    `json:"reject_count"`  // * number of "reject" votes
	PendingCount *int    `json:"pending_count"` // * number of voters who have not voted yet
	IsCompleted  *bool   `json:"is_completed"`  // * whether all votes are in
	FinalResult  *string `json:"final_result"`  // * "approved", "rejected", "pending"

	// My vote
	MyVote      *string              `json:"my_vote"` // * "pending", "approve", "reject"
	VoteDetails []RoomJoinVoteDetail `json:"vote_details"`
}

// * helper struct for voting statistics
type VotingStats struct {
	TotalVoters  int
	VotedCount   int
	ApproveCount int
	RejectCount  int
	PendingCount int
}

type RoomJoinVoteDetail struct {
	VoterUserID   *uint   `json:"voter_user_id"`
	VoterUsername *string `json:"voter_username"`
	Vote          *string `json:"vote"` // * "pending", "approve", "reject"
	VotedAt       *string `json:"voted_at"`
}
