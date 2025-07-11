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
	"github.com/minio/minio-go/v7/pkg/credentials"
	"log"
	"strings"
	"time"

	"github.com/spf13/viper"
	"gorm.io/gorm"
)

const jwtSecret = "FriendSecret"

func main() {
	initTimeZone()
	initConfig()
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

	models := []interface{}{
		&entities.User{},
		&entities.LifestyleQuiz{},
		&entities.Location{},
		&entities.RoomMember{},
		&entities.Room{},
		&entities.Notice{},
		&entities.UserCompatibilityProfile{},
		&entities.Chore{},
		&entities.ChoreAssignment{},
		&entities.ChoreRotationUser{},
		&entities.Bill{},
		&entities.BillSplit{},
		&entities.PaymentRequest{},
		&entities.SCBAccessToken{},
	}

	for _, model := range models {
		log.Printf("📦 Starting migration for: %T", model)

		if err := db.AutoMigrate(model); err != nil {
			log.Fatalf("❌ Failed to migrate %T: %v", model, err)
		}

		log.Printf("✅ Successfully migrated: %T", model)
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
	fmt.Println("FairNest Minio connected")

	uploadSer := service.NewUploadService(minioClient)
	storageHandler := handler.NewStorageHandler(uploadSer)

	userRepositoryDB := repository.NewUserRepositoryDB(db)

	userService := service.NewUserService(userRepositoryDB, jwtSecret)
	uploadService := service.NewUploadService(minioClient)

	userHandler := handler.NewUserHandler(userService, jwtSecret, uploadService)

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

	// Endpoint for test
	app.Get("/GetUsers", userHandler.GetUsers)
	app.Get("/GetUserByUserId/:UserID", userHandler.GetUserByUserId)
	app.Get("/GetUserByToken", userHandler.GetUserByToken) //#

	app.Post("/upload", storageHandler.UploadFile)

	//////////////////////////////////////////////////////////////////////////////////////

	// Endpoint for project
	app.Post("/Register", userHandler.Register)
	app.Post("/Login", userHandler.Login)

	app.Get("/GetCurrentUser", userHandler.GetCurrentUser) //#
	app.Get("/GetProfileOfCurrentUserByUserId/:UserID", userHandler.GetProfileOfCurrentUserByUserId)
	app.Get("/GetEditUserProfileByUserId/:UserID", userHandler.GetEditUserProfileByUserId)
	app.Patch("/PatchEditUserProfileByUserId/:UserID", userHandler.PatchEditUserProfileByUserId)

	//#####################################################################################

	log.Printf("FairNest running at port:  %v", viper.GetInt("app.port"))
	app.Listen(fmt.Sprintf(":%v", viper.GetInt("app.port")))

}

func initConfig() {
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	err := viper.ReadInConfig()
	if err != nil {
		panic(err)
	}
}

func initTimeZone() {
	ict, err := time.LoadLocation("Asia/Bangkok")
	if err != nil {
		panic(err)
	}

	time.Local = ict
}
