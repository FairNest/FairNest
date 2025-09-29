package service

import "fairnest/internal/dtos"

type RoomJoinService interface {
	// * create join request and send notifications
	CreateRoomJoinRequestByUserIdRoomId(int, int) (*dtos.CreateRoomJoinRequestByUserIdResponse, error)

	// * get join request details for voting
	GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserID(roomJoinRequestID int, voterUserID int) (*dtos.GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserIDResponse, error)
}
