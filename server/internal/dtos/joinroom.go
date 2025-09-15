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

// * helper struct for voting statistics
type VotingStats struct {
	TotalVoters  int
	VotedCount   int
	ApproveCount int
	RejectCount  int
	PendingCount int
}
