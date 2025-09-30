package service

import "fairnest/internal/dtos"

type RoomJoinService interface {
	// * create join request and send notifications
	CreateRoomJoinRequestByUserIdRoomId(int, int) (*dtos.CreateRoomJoinRequestByUserIdResponse, error)

	// * get join request details for voting
	GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserID(roomJoinRequestID int, voterUserID int) (*dtos.GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserIDResponse, error)

	// * submit vote (approve/reject)
	SubmitVoteByRoomJoinRequestIDVoterUserID(roomJoinRequestID int, voterUserID int, request *dtos.SubmitRoomJoinVoteRequest) (*dtos.SubmitRoomJoinVoteResponse, error)
}
