package dtos

type FetchAllUnreadNotificationByUserIdResponse struct {
	NotificationID      *uint   `json:"notification_id" validate:"required"`
	SenderID            *uint   `json:"sender_id" validate:"required"`
	ReceiverID          *uint   `json:"receiver_id" validate:"required"`
	NotificationMessage *string `json:"notification_message" validate:"required"`
	IsRead              *bool   `json:"is_read" validate:"required"`
	CreatedAt           *string `json:"created_at" validate:"required"`
}
