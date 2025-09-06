package handler

import (
	"fairnest/internal/dtos"
	"fairnest/internal/service"
	"fairnest/internal/utils/v"
	"github.com/gofiber/fiber/v2"
	"strconv"
)

type notificationHandler struct {
	notificationSer service.NotificationService
}

func NewNotificationHandler(notificationSer service.NotificationService) notificationHandler {
	return notificationHandler{notificationSer: notificationSer}
}

func (h *notificationHandler) FetchAllUnreadNotificationByUserId(c *fiber.Ctx) error {
	notificationsResponse := make([]dtos.FetchAllUnreadNotificationByUserIdResponse, 0)
	notificationIDReceive, err := strconv.Atoi(c.Params("UserID"))

	notifications, err := h.notificationSer.FetchAllUnreadNotificationByUserId(notificationIDReceive)
	if err != nil {
		return err
	}

	for _, notification := range notifications {
		notificationsResponse = append(notificationsResponse, dtos.FetchAllUnreadNotificationByUserIdResponse{
			NotificationID:      notification.NotificationID,
			SenderID:            notification.SenderID,
			ReceiverID:          notification.ReceiverID,
			NotificationMessage: notification.NotificationMessage,
			IsRead:              notification.IsRead,
			CreatedAt:           v.TimePtrToRFC3339Ptr(notification.CreatedAt),
		})
	}
	return c.JSON(notificationsResponse)
}

func (h *notificationHandler) FetchThreeNotificationByUserId(c *fiber.Ctx) error {
	notificationsResponse := make([]dtos.FetchThreeNotificationByUserIdResponse, 0)
	notificationIDReceive, err := strconv.Atoi(c.Params("UserID"))

	notifications, err := h.notificationSer.FetchThreeNotificationByUserId(notificationIDReceive)
	if err != nil {
		return err
	}

	for _, notification := range notifications {
		notificationsResponse = append(notificationsResponse, dtos.FetchThreeNotificationByUserIdResponse{
			NotificationID:      notification.NotificationID,
			SenderID:            notification.SenderID,
			ReceiverID:          notification.ReceiverID,
			NotificationMessage: notification.NotificationMessage,
			IsRead:              notification.IsRead,
			CreatedAt:           v.TimePtrToRFC3339Ptr(notification.CreatedAt),
		})
	}
	return c.JSON(notificationsResponse)
}
