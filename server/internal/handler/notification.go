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

func (h *notificationHandler) GetNotificationByNotificationId(c *fiber.Ctx) error {
	notificationIDReceive, err := strconv.Atoi(c.Params("NotificationID"))

	notification, err := h.notificationSer.GetNotificationByNotificationId(notificationIDReceive)
	if err != nil {
		return err
	}

	notificationResponse := dtos.GetNotificationByNotificationIdResponse{
		NotificationID:      notification.NotificationID,
		SenderID:            notification.SenderID,
		ReceiverID:          notification.ReceiverID,
		NotificationMessage: notification.NotificationMessage,
		IsRead:              notification.IsRead,
		IsVoteNotification:  notification.IsVoteNotification,
		CreatedAt:           v.TimePtrToRFC3339Ptr(notification.CreatedAt),
	}
	return c.JSON(notificationResponse)
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
			IsVoteNotification:  notification.IsVoteNotification,
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
			IsVoteNotification:  notification.IsVoteNotification,
			CreatedAt:           v.TimePtrToRFC3339Ptr(notification.CreatedAt),
		})
	}
	return c.JSON(notificationsResponse)
}

func (h *notificationHandler) PutMarkAsReadByNotificationId(c *fiber.Ctx) error {
	notificationIDReceive, err := strconv.Atoi(c.Params("NotificationID"))

	notification, err := h.notificationSer.PutMarkAsReadByNotificationId(notificationIDReceive)
	if err != nil {
		return err
	}

	notificationResponse := dtos.PutMarkAsReadByNotificationIdResponse{
		NotificationID:      notification.NotificationID,
		SenderID:            notification.SenderID,
		ReceiverID:          notification.ReceiverID,
		NotificationMessage: notification.NotificationMessage,
		IsRead:              notification.IsRead,
		IsVoteNotification:  notification.IsVoteNotification,
		CreatedAt:           v.TimePtrToRFC3339Ptr(notification.CreatedAt),
	}
	return c.JSON(notificationResponse)
}

func (h *notificationHandler) GetCountOfUnreadNotificationByUserId(c *fiber.Ctx) error {
	userIDReceive, err := strconv.Atoi(c.Params("UserID"))

	count, err := h.notificationSer.GetCountOfUnreadNotificationByUserId(userIDReceive)
	if err != nil {
		return err
	}

	countResponse := dtos.GetCountOfUnreadNotificationByUserIdResponse{
		CountOfUnreadNotification: v.Ptr(count),
	}
	return c.JSON(countResponse)
}
