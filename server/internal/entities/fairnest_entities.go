package entities

type User struct {
	UserID            *uint `gorm:"primaryKey;autoIncrement"`
	Username          *string
	Password          *string
	Email             *string
	Firstname         *string
	Lastname          *string
	PhoneNumber       *string
	UserPicture       *string
	UserAboutMe       *string
	BankAccountNumber *string
	RoommateScore     *float64

	LifestyleQuiz LifestyleQuiz `gorm:"foreignKey:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Rooms         []Room        `gorm:"foreignKey:CreatorID"`
}

type LifestyleQuiz struct {
	LifestyleQuizID *uint `gorm:"primaryKey;autoIncrement"`
	UserID          *uint `gorm:"not null;unique"`

	Q1  *int
	Q2  *int
	Q3  *int
	Q4  *int
	Q5  *int
	Q6  *int
	Q7  *int
	Q8  *int
	Q9  *int
	Q10 *int
	Q11 *int
	Q12 *int
}

type Room struct {
	RoomID     *uint `gorm:"primaryKey;autoIncrement"`
	CreatorID  *uint `gorm:"not null"`
	LocationID *uint `gorm:"not null"`

	RoomCode           *string
	RoomName           *string
	RoomDescription    *string
	RoomType           *bool
	MaxSize            *int
	CompatibilityRange *float64
	RentPrice          *float64
	ElectricityUnit    *float64
	WaterUnit          *float64
	WiFi               *bool
	WashingMachine     *bool
	PetAllow           *bool

	// Associations
	Creator  User     `gorm:"foreignKey:CreatorID;references:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Location Location `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type Location struct {
	LocationID *uint `gorm:"primaryKey;autoIncrement"`
	District   *string
}

//type RoomMember struct {
//	RoomMemberID *uint `gorm:"primaryKey;autoIncrement"`
//	UserID       *uint `gorm:"not null"`
//	RoomID       *uint `gorm:"not null"`
//	IsAdmin      *bool
//	JoinedAt     *time.Time `gorm:"autoCreateTime"`
//
//	User *User `gorm:"foreignKey:UserID;references:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
//	Room *Room `gorm:"foreignKey:RoomID;references:RoomID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
//}
