package main

import (
	"fmt"

	jwtware "github.com/gofiber/contrib/jwt"
	"github.com/gofiber/fiber/v2"
	"github.com/minio/minio-go/v7"
	"gorm.io/driver/postgres"

	"fairnest/internal/entities"
	"fairnest/internal/handler"
	"fairnest/internal/repository"
	"fairnest/internal/service"
	"log"
	"strings"
	"time"

	"github.com/minio/minio-go/v7/pkg/credentials"

	"github.com/spf13/viper"
	"gorm.io/gorm"
)

func main() {
	initTimeZone()
	initConfig()
	jwtSecret := viper.GetString("jwt.jwtSecret")
	dsn := fmt.Sprintf("host=%v port=%v user=%v password=%v dbname=%v sslmode=disable TimeZone=Asia/Bangkok",
		viper.GetString("db.host"),
		viper.GetInt("db.port"),
		viper.GetString("db.username"),
		viper.GetString("db.password"),
		viper.GetString("db.database"),
	)
	log.Println(dsn)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("❌ Failed to connect to database: " + err.Error())
	}

	// AutoMigrate all entities
	err = db.AutoMigrate(
		// Core entities
		&entities.User{},
		&entities.Lifestyle{},
		&entities.Room{},
		&entities.RoomMember{},

		// Notification system
		&entities.Notification{},

		// Room joining system
		&entities.RoomJoinRequest{},
		&entities.RoomJoinVote{},

		// Chore management system
		&entities.Chore{},
		&entities.ChoreAssignment{},
		&entities.ChoreRotationUser{},

		// Finance management system
		&entities.Finance{},
		&entities.Transaction{},
	)
	if err != nil {
		panic("❌ Failed to AutoMigrate entities: " + err.Error())
	}

	log.Println("🎉 All migrations completed successfully!")

	minioEndpoint := fmt.Sprintf("%s:%d", viper.GetString("minio.host"), viper.GetInt("minio.port"))
	minioClient, err := minio.New(minioEndpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(viper.GetString("minio.accessKey"), viper.GetString("minio.secretKey"), ""),
		Secure: false, // change to true if using HTTPS
	})
	if err != nil {
		log.Fatalln(err)
	}
	log.Println("✅ FairNest Minio connected")

	stripeSecretKey := viper.GetString("stripe.secretKey")

	uploadSer := service.NewUploadService(minioClient)
	storageHandler := handler.NewStorageHandler(uploadSer)

	userRepositoryDB := repository.NewUserRepositoryDB(db)
	lifestyleRepositoryDB := repository.NewLifestyleRepositoryDB(db)
	roomRepositoryDB := repository.NewRoomRepositoryDB(db)
	roomMemberRepositoryDB := repository.NewRoomMemberRepositoryDB(db)
	notificationRepositoryDB := repository.NewNotificationRepositoryDB(db)
	choreRepositoryDB := repository.NewChoreRepositoryDB(db)
	roomJoinRepositoryDB := repository.NewRoomJoinRepositoryDB(db)
	financeRepositoryDB := repository.NewFinanceRepositoryDB(db)
	dashboardRepositoryDB := repository.NewDashboardRepositoryDB(db)
	userDashboardRepositoryDB := repository.NewUserDashboardRepositoryDB(db)

	uploadService := service.NewUploadService(minioClient)
	stripeService := service.NewStripeService(stripeSecretKey)

	lifestyleService := service.NewLifestyleService(lifestyleRepositoryDB)
	userService := service.NewUserService(userRepositoryDB, jwtSecret, lifestyleService)
	roomMemberService := service.NewRoomMemberService(roomMemberRepositoryDB, userService)
	notificationService := service.NewNotificationService(notificationRepositoryDB)
	choreService := service.NewChoreService(choreRepositoryDB, userService)
	roomService := service.NewRoomService(roomRepositoryDB, roomMemberService, lifestyleService)
	roomJoinService := service.NewRoomJoinService(roomJoinRepositoryDB, roomMemberService, roomService, userService, notificationService, lifestyleService)
	financeService := service.NewFinanceService(financeRepositoryDB, userService, stripeService)
	dashboardService := service.NewDashboardService(dashboardRepositoryDB, lifestyleRepositoryDB, lifestyleService)
	userDashboardService := service.NewUserDashboardSplitService(userDashboardRepositoryDB)

	go func() {
		if err := financeService.CheckOverduePenalty(); err != nil {
			log.Printf("Failed to apply overdue penalties at startup: %v", err)
		} else {
			log.Println("Overdue penalty check completed successfully at startup.")
		}

		if err := choreService.ProcessMissedChores(); err != nil {
			log.Printf("Failed to process missed chores at startup: %v", err)
		} else {
			log.Println("Missed chores processed successfully at startup.")
		}
	}()

	userHandler := handler.NewUserHandler(userService, jwtSecret, uploadService, roomService)
	lifestyleHandler := handler.NewLifestyleHandler(lifestyleService, lifestyleRepositoryDB)
	roomHandler := handler.NewRoomHandler(roomService)
	roomMemberHandler := handler.NewRoomMemberHandler(roomMemberService)
	notificationHandler := handler.NewNotificationHandler(notificationService)
	choreHandler := handler.NewChoreHandler(choreService, jwtSecret)
	roomJoinHandler := handler.NewRoomJoinHandler(roomJoinService)
	financeHandler := handler.NewFinanceHandler(financeService)
	dashboardHandler := handler.NewDashboardHandler(dashboardService, jwtSecret)
	userDashboardHandler := handler.NewUserDashboardSplitHandler(userDashboardService, jwtSecret)

	app := fiber.New()

	app.Use(func(c *fiber.Ctx) error {
		if c.Path() != "/Register" && c.Path() != "/Login" {
			jwtMiddleware := jwtware.New(jwtware.Config{
				SigningKey: jwtware.SigningKey{Key: []byte(jwtSecret)},
				ErrorHandler: func(c *fiber.Ctx, err error) error {
					return fiber.ErrUnauthorized
				},
			})
			return jwtMiddleware(c)
		}
		return c.Next()
	})

	//Endpoint ###########################################################################

	// Endpoints for test
	app.Get("/FetchAllUser", userHandler.FetchAllUser)
	app.Get("/GetUserByUserId/:UserID", userHandler.GetUserByUserId)
	app.Get("/GetUserByToken", userHandler.GetUserByToken) //%

	app.Get("/FetchAllRoom", roomHandler.FetchAllRoom)

	app.Get("/GetLifestyleByUserId/:UserID", lifestyleHandler.GetLifestyleByUserId)

	app.Get("/FetchAllRoomMemberByRoomId/:RoomID", roomMemberHandler.FetchAllRoomMemberByRoomId)
	app.Get("/FetchAllRoomMemberWithUserDetailsByRoomId/:RoomID", roomMemberHandler.FetchAllRoomMemberWithUserDetailsByRoomId)
	app.Get("/FetchAllRoomWithRoomMembersDetails", roomHandler.FetchAllRoomWithRoomMembersDetails)

	app.Get("/FetchAllRoomSuitUserLifestyleByUserId/:UserID", roomHandler.FetchAllRoomSuitUserLifestyleByUserId)

	app.Get("/GetNotificationByNotificationId/:NotificationID", notificationHandler.GetNotificationByNotificationId)

	app.Get("/FetchAllChore", choreHandler.FetchAllChore)

	app.Post("/upload", storageHandler.UploadFile)

	app.Get("/rooms/:RoomID/users/basic", roomMemberHandler.GetUsersBasicByRoomId)

	app.Get("/FetchAllVotesByRoomJoinRequestID/:RoomJoinRequestID", roomJoinHandler.FetchAllVotesByRoomJoinRequestID)
	app.Get("/FetchAllNotificationsByRoomJoinRequestID/:RoomJoinRequestID", notificationHandler.FetchAllNotificationsByRoomJoinRequestID)

	app.Get("/GetVotingStatisticsByRoomJoinRequestID/:RoomJoinRequestID", roomJoinHandler.GetVotingStatisticsByRoomJoinRequestID)

	app.Get("/FetchAllFinance", financeHandler.FetchAllFinance)
	app.Get("/GetFinanceByFinanceID/:FinanceID", financeHandler.GetFinanceByFinanceID)
	app.Get("/FetchAllTransaction", financeHandler.FetchAllTransaction)
	app.Get("/GetTransactionByTransactionID/:TransactionID", financeHandler.GetTransactionByTransactionID)

	//////////////////////////////////////////////////////////////////////////////////////

	// Endpoints for project
	app.Post("/Register", userHandler.Register)
	app.Post("/Login", userHandler.Login)

	app.Get("/GetCurrentUser", userHandler.GetCurrentUser)                                       //#
	app.Get("/GetCurrentUserDetailsByUserId/:UserID", userHandler.GetCurrentUserDetailsByUserId) //^H
	app.Get("/GetProfileOfCurrentUserByUserId/:UserID", userHandler.GetProfileOfCurrentUserByUserId)
	app.Get("/GetEditUserProfileByUserId/:UserID", userHandler.GetEditUserProfileByUserId)
	app.Patch("/PatchEditUserProfileByUserId/:UserID", userHandler.PatchEditUserProfileByUserId)

	app.Post("/CreateRoomByUserId/:UserID", roomHandler.CreateRoomByUserId)

	app.Get("/FetchAllPublicRoomSuitUserLifestyleByUserId/:UserID", roomHandler.FetchAllPublicRoomSuitUserLifestyleByUserId)
	app.Get("/FilterPublicRoomSuitUserLifestyleByUserId/:UserID", roomHandler.FilterPublicRoomSuitUserLifestyleByUserId)
	app.Get("/GetMyRoomByUserId/:UserID", roomHandler.GetMyRoomByUserId)

	app.Get("/GetMyPendingRoomByUserID/:UserID", roomHandler.GetMyPendingRoomByUserID)
	app.Get("/GetMyPendingRoomDetailsByRoomIdRoomJoinRequestID/:RoomID/:RoomJoinRequestID", roomHandler.GetMyPendingRoomDetailsByRoomIdRoomJoinRequestID)

	app.Get("/GetRoomDetailsByRoomId/:RoomID", roomHandler.GetRoomDetailsByRoomId)
	app.Get("/GetRoomDetailsByRoomCode/:RoomCode", roomHandler.GetRoomDetailsByRoomCode)

	app.Get("/GetCheckUserHasRoomOrNotByUserId/:UserID", roomMemberHandler.GetCheckUserHasRoomOrNotByUserId)

	// House Rules Endpoints
	app.Get("/GetHouseRulesByRoomId/:RoomID", roomHandler.GetHouseRulesByRoomId)
	app.Patch("/PatchEditHouseRulesByRoomId/:RoomID", roomHandler.PatchEditHouseRulesByRoomId)

	// Lifestyle & Compatibility Endpoints
	app.Get("/GetRoomOverallLifestyleByRoomId/:RoomID", roomHandler.GetRoomOverallLifestyleByRoomId)
	app.Get("/GetUserOverallLifestyleByUserId/:UserID", lifestyleHandler.GetUserOverallLifestyleByUserId)
	app.Get("/GetRoomAverageCompatibilityByRoomId/:RoomID", lifestyleHandler.GetRoomAverageCompatibilityByRoomId)
	app.Get("/GetCompatibilityMatchesByRoomAndUser/:RoomID/:UserID", lifestyleHandler.GetCompatibilityMatchesByRoomAndUser)

	app.Get("/FetchAllUnreadNotificationByUserId/:UserID", notificationHandler.FetchAllUnreadNotificationByUserId)
	app.Get("/FetchThreeNotificationByUserId/:UserID", notificationHandler.FetchThreeNotificationByUserId)
	app.Put("/PutMarkAsReadByNotificationId/:NotificationID", notificationHandler.PutMarkAsReadByNotificationId)
	app.Get("/GetCountOfUnreadNotificationByUserId/:UserID", notificationHandler.GetCountOfUnreadNotificationByUserId)

	// Notification Endpoints
	app.Post("/CreateNotification/:SenderID/:ReceiverID", notificationHandler.CreateNotification)
	app.Post("/CreateVoteNotification/:SenderID/:ReceiverID/:RoomJoinRequestID", notificationHandler.CreateVoteNotification) // DON'T USE, ALREADY AUTO IN SERVICE

	// Room Join Request and Voting Endpoints
	app.Post("/CreateRoomJoinRequestByUserIdRoomId/:UserID/:RoomID", roomJoinHandler.CreateRoomJoinRequestByUserIdRoomId)
	app.Get("/GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserID/:RoomJoinRequestID/:VoterUserID", roomJoinHandler.GetRoomJoinRequestForVotingByRoomJoinRequestIDVoterUserID)
	app.Put("/PutSubmitVoteByRoomJoinRequestIDVoterUserID/:RoomJoinRequestID/:VoterUserID", roomJoinHandler.PutSubmitVoteByRoomJoinRequestIDVoterUserID)

	// Finance Endpoints
	app.Get("/GetMyMonthlySnapshotByUserID/:UserID", financeHandler.GetMyMonthlySnapshotByUserID)
	app.Get("/FetchAllOutstandingBalancesByUserID/:UserID", financeHandler.FetchAllOutstandingBalancesByUserID)
	app.Get("/FetchAllUpcomingPaymentByUserID/:UserID", financeHandler.FetchAllUpcomingPaymentByUserID)
	app.Get("/FetchAllPaidTransactionHistoryByUserID/:UserID", financeHandler.FetchAllPaidTransactionHistoryByUserID)

	app.Post("/CreateFinanceByPayerID/:PayerID", financeHandler.CreateFinanceByPayerID)

	app.Get("/FetchAllOverdueTransactions", financeHandler.FetchAllOverdueTransactions)
	app.Post("/CheckOverduePenalty", financeHandler.CheckOverduePenalty)

	app.Get("/GetPaymentStatusByTransactionID/:TransactionID", financeHandler.GetPaymentStatusByTransactionID)

	//######################## NEW CHORE ENDPOINTS (BY CLAUDE) ########################

	// Chore Management
	app.Post("/rooms/:roomID/chores", choreHandler.CreateChore)      // Create new chore
	app.Get("/rooms/:roomID/chores", choreHandler.GetChoresByRoomID) // Get all chores for room
	app.Put("/chores/:choreID", choreHandler.UpdateChore)            // Update chore
	app.Delete("/chores/:choreID", choreHandler.DeleteChore)         // Delete chore

	// Chore Views and Completion
	app.Get("/rooms/:roomID/chores/calendar", choreHandler.GetChoreCalendar) // Calendar view with date range
	app.Get("/rooms/:roomID/chores/today", choreHandler.GetTodayChores)      // Get today's chores
	app.Post("/chores/complete", choreHandler.MarkChoreComplete)             // Mark chore as completed

	app.Get("/rooms/:roomID/chores/day", choreHandler.GetRoomTasksForDate)
	app.Get("/rooms/:roomID/chores/day/mine", choreHandler.GetMyTasksForDate)

	app.Get("/chores/:choreID", choreHandler.GetChoreDetailByID)

	// Dashboard Endpoint
	app.Get("/rooms/:roomID/dashboard", dashboardHandler.GetRoomDashboard)
	// User Dashboard Endpoints
	app.Get("/user/progress", userDashboardHandler.GetUserProgress)
	app.Get("/user/tasks/today", userDashboardHandler.GetUserTasksToday)
	app.Get("/user/tasks/completed", userDashboardHandler.GetUserTasksCompleted)
	app.Get("/user/tasks/upcoming", userDashboardHandler.GetUserTasksUpcoming)

	//###################################################################

	//#####################################################################################

	//// Print all routes before starting
	//for _, r := range app.GetRoutes() {
	//	fmt.Printf("%s\t%s\n", r.Method, r.Path)
	//}

	log.Printf("FairNest running at port:  %v", viper.GetInt("app.port"))
	app.Listen(fmt.Sprintf(":%v", viper.GetInt("app.port")))

}

func initConfig() {
	viper.SetConfigName("config") // config.yaml
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")        // current directory
	viper.AddConfigPath("./config") // optional extra path

	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	viper.AutomaticEnv()

	if err := viper.ReadInConfig(); err != nil {
		log.Printf("[config] could not read config file: %v", err)
	}

	secret := viper.GetString("jwt.jwtSecret")
	if secret == "" {
		log.Println("[config] jwt.jwtSecret is EMPTY")
	}
}

func initTimeZone() {
	ict, err := time.LoadLocation("Asia/Bangkok")
	if err != nil {
		panic(err)
	}

	time.Local = ict
}
