package dtos

type GetNotificationByNotificationIdResponse struct {
	NotificationID      *uint   `json:"notification_id" validate:"required"`
	SenderID            *uint   `json:"sender_id" validate:"required"`
	ReceiverID          *uint   `json:"receiver_id" validate:"required"`
	NotificationMessage *string `json:"notification_message" validate:"required"`
	IsRead              *bool   `json:"is_read" validate:"required"`
	IsVoteNotification  *bool   `json:"is_vote_notification" validate:"required"`
	CreatedAt           *string `json:"created_at" validate:"required"`
}

type FetchAllUnreadNotificationByUserIdResponse struct {
	NotificationID      *uint   `json:"notification_id" validate:"required"`
	SenderID            *uint   `json:"sender_id" validate:"required"`
	ReceiverID          *uint   `json:"receiver_id" validate:"required"`
	NotificationMessage *string `json:"notification_message" validate:"required"`
	IsRead              *bool   `json:"is_read" validate:"required"`
	IsVoteNotification  *bool   `json:"is_vote_notification" validate:"required"`
	CreatedAt           *string `json:"created_at" validate:"required"`
}

type FetchThreeNotificationByUserIdResponse struct {
	NotificationID      *uint   `json:"notification_id" validate:"required"`
	SenderID            *uint   `json:"sender_id" validate:"required"`
	ReceiverID          *uint   `json:"receiver_id" validate:"required"`
	NotificationMessage *string `json:"notification_message" validate:"required"`
	IsRead              *bool   `json:"is_read" validate:"required"`
	IsVoteNotification  *bool   `json:"is_vote_notification" validate:"required"`
	CreatedAt           *string `json:"created_at" validate:"required"`
}

type PutMarkAsReadByNotificationIdResponse struct {
	NotificationID      *uint   `json:"notification_id" validate:"required"`
	SenderID            *uint   `json:"sender_id" validate:"required"`
	ReceiverID          *uint   `json:"receiver_id" validate:"required"`
	NotificationMessage *string `json:"notification_message" validate:"required"`
	IsRead              *bool   `json:"is_read" validate:"required"`
	IsVoteNotification  *bool   `json:"is_vote_notification" validate:"required"`
	CreatedAt           *string `json:"created_at" validate:"required"`
}

type GetCountOfUnreadNotificationByUserIdResponse struct {
	CountOfUnreadNotification *int `json:"count_of_unread_notification" validate:"required"`
}

type CreateNotificationRequest struct {
	SenderID            *uint   `json:"sender_id" validate:"required"`
	ReceiverID          *uint   `json:"receiver_id" validate:"required"`
	NotificationMessage *string `json:"notification_message" validate:"required"`
}

type CreateNotificationResponse struct {
	NotificationID      *uint   `json:"notification_id" validate:"required"`
	SenderID            *uint   `json:"sender_id" validate:"required"`
	ReceiverID          *uint   `json:"receiver_id" validate:"required"`
	NotificationMessage *string `json:"notification_message" validate:"required"`
	IsRead              *bool   `json:"is_read" validate:"required"`
	IsVoteNotification  *bool   `json:"is_vote_notification" validate:"required"`
	CreatedAt           *string `json:"created_at" validate:"required"`
}

type CreateVoteNotificationRequest struct {
	SenderID            *uint   `json:"sender_id" validate:"required"`
	ReceiverID          *uint   `json:"receiver_id" validate:"required"`
	NotificationMessage *string `json:"notification_message" validate:"required"`
}

type CreateVoteNotificationResponse struct {
	NotificationID      *uint   `json:"notification_id" validate:"required"`
	SenderID            *uint   `json:"sender_id" validate:"required"`
	ReceiverID          *uint   `json:"receiver_id" validate:"required"`
	NotificationMessage *string `json:"notification_message" validate:"required"`
	IsRead              *bool   `json:"is_read" validate:"required"`
	IsVoteNotification  *bool   `json:"is_vote_notification" validate:"required"`
	CreatedAt           *string `json:"created_at" validate:"required"`
}
