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
		&entities.User{},
		&entities.Lifestyle{},
		&entities.RoomMember{},
		&entities.Room{},
		&entities.Notification{},
		&entities.UserCompatibilityProfile{},
		&entities.Chore{},
		&entities.ChoreAssignment{},
		&entities.ChoreRotationUser{},
		//&entities.Bill{},
		//&entities.BillSplit{},
		//&entities.PaymentRequest{},
		//&entities.SCBAccessToken{},
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

	uploadSer := service.NewUploadService(minioClient)
	storageHandler := handler.NewStorageHandler(uploadSer)

	userRepositoryDB := repository.NewUserRepositoryDB(db)
	lifestyleRepositoryDB := repository.NewLifestyleRepositoryDB(db)
	roomRepositoryDB := repository.NewRoomRepositoryDB(db)
	roomMemberRepositoryDB := repository.NewRoomMemberRepositoryDB(db)
	notificationRepositoryDB := repository.NewNotificationRepositoryDB(db)
	choreRepositoryDB := repository.NewChoreRepositoryDB(db)

	uploadService := service.NewUploadService(minioClient)
	lifestyleService := service.NewLifestyleService(lifestyleRepositoryDB)
	userService := service.NewUserService(userRepositoryDB, jwtSecret, lifestyleService)
	roomMemberService := service.NewRoomMemberService(roomMemberRepositoryDB, userService)
	roomService := service.NewRoomService(roomRepositoryDB, roomMemberService, lifestyleService)
	notificationService := service.NewNotificationService(notificationRepositoryDB)
	choreService := service.NewChoreService(choreRepositoryDB)

	userHandler := handler.NewUserHandler(userService, jwtSecret, uploadService, roomService)
	lifestyleHandler := handler.NewLifestyleHandler(lifestyleService)
	roomHandler := handler.NewRoomHandler(roomService)
	roomMemberHandler := handler.NewRoomMemberHandler(roomMemberService)
	notificationHandler := handler.NewNotificationHandler(notificationService)
	choreHandler := handler.NewChoreHandler(choreService)

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

	app.Post("/upload", storageHandler.UploadFile)

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
	app.Get("/GetMyRoomByUserId/:UserID", roomHandler.GetMyRoomByUserId)

	app.Get("/GetRoomDetailsByRoomId/:RoomID", roomHandler.GetRoomDetailsByRoomId)
	app.Get("/GetRoomDetailsByRoomCode/:RoomCode", roomHandler.GetRoomDetailsByRoomCode)

	app.Get("/CheckUserHasRoomOrNot/:UserID", roomMemberHandler.CheckUserHasRoomOrNot)

	app.Get("/GetHouseRulesByRoomId/:RoomID", roomHandler.GetHouseRulesByRoomId)
	app.Patch("/PatchEditHouseRulesByRoomId/:RoomID", roomHandler.PatchEditHouseRulesByRoomId)

	app.Get("/GetRoomOverallLifestyleByRoomId/:RoomID", roomHandler.GetRoomOverallLifestyleByRoomId)
	app.Get("/GetUserOverallLifestyleByUserId/:UserID", lifestyleHandler.GetUserOverallLifestyleByUserId)

	app.Get("/FetchAllUnreadNotificationByUserId/:UserID", notificationHandler.FetchAllUnreadNotificationByUserId)
	app.Get("/FetchThreeNotificationByUserId/:UserID", notificationHandler.FetchThreeNotificationByUserId)
	app.Put("/PutMarkAsReadByNotificationId/:NotificationID", notificationHandler.PutMarkAsReadByNotificationId)
	app.Get("/GetCountOfUnreadNotificationByUserId/:UserID", notificationHandler.GetCountOfUnreadNotificationByUserId)

	app.Get("/FetchAllChore", choreHandler.FetchAllChore)

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
