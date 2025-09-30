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

// * submit vote request
type SubmitRoomJoinVoteRequest struct {
	Vote *bool `json:"vote" validate:"required"` // * true = approve, false = reject
}

// * submit vote response
type SubmitRoomJoinVoteResponse struct {
	RoomJoinVoteID    *uint         `json:"room_join_vote_id" validate:"required"`
	RoomJoinRequestID *uint         `json:"room_join_request_id" validate:"required"`
	VoterUserID       *uint         `json:"voter_user_id" validate:"required"`
	Vote              *string       `json:"vote" validate:"required"`
	VotedAt           *string       `json:"voted_at" validate:"required"`
	VotingStatus      *VotingStatus `json:"voting_status" validate:"required"`
	Message           *string       `json:"message" validate:"required"`
}

type VotingStatus struct {
	TotalVoters  *int    `json:"total_voters"`
	VotedCount   *int    `json:"voted_count"`
	ApproveCount *int    `json:"approve_count"`
	RejectCount  *int    `json:"reject_count"`
	PendingCount *int    `json:"pending_count"`
	IsCompleted  *bool   `json:"is_completed"`
	FinalResult  *string `json:"final_result"` // * "null = pending", "true = approved", "false = rejected"
}

type RoomJoinVoteDetail struct {
	VoterUserID   *uint   `json:"voter_user_id"`
	VoterUsername *string `json:"voter_username"`
	Vote          *string `json:"vote"` // * "null = pending", "true = approve", "false = reject"
	VotedAt       *string `json:"voted_at"`
}

type FetchAllVotesByRoomJoinRequestIDResponse struct {
	RoomJoinVoteID    *uint   `json:"room_join_vote_id"`
	RoomJoinRequestID *uint   `json:"room_join_request_id"`
	VoterUserID       *uint   `json:"voter_user_id"`
	Vote              *bool   `json:"vote"` // * "null = pending", "true = approve", "false = reject"
	VotedAt           *string `json:"voted_at"`
}
