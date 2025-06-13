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

	RoomMembers []RoomMember
}

type LifestyleQuiz struct {
	LifestyleQuizID       *uint `gorm:"primaryKey;autoIncrement"`
	UserID                *uint `gorm:"uniqueIndex"` // one-to-one
	Q1                    *int
	Q2                    *int
	Q3                    *int
	Q4                    *int
	Q5                    *int
	Q6                    *int
	Q7                    *int
	Q8                    *int
	Q9                    *int
	Q10                   *int
	Q11                   *int
	Q12                   *int
	UserOpenness          *float64
	UserConscientiousness *float64
	UserExtraversion      *float64
	UserAgreeableness     *float64
	UserNeuroticism       *float64

	// Relations
	User *User `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type Room struct {
	RoomID               *uint `gorm:"primaryKey;autoIncrement"`
	LocationID           *uint // one-to-one
	RoomName             *string
	RoomDescription      *string
	RoomType             *bool
	RoomCode             *string
	RoomCapacity         *int
	OpennessAvg          *float64
	ConscientiousnessAvg *float64
	ExtraversionAvg      *float64
	AgreeablenessAvg     *float64
	NeuroticismAvg       *float64
	CompatibilityScore   *float64

	// Relations
	Location    *Location
	RoomMembers []RoomMember
}

type Location struct {
	LocationID *uint `gorm:"primaryKey;autoIncrement"`
	City       *string
	District   *string
	Address    *string
}

type RoomMember struct {
	RoomMemberID *uint `gorm:"primaryKey;autoIncrement"`
	UserID       *uint `gorm:"not null;uniqueIndex:idx_user_room"`
	RoomID       *uint `gorm:"not null;uniqueIndex:idx_user_room"`
	IsAdmin      *bool

	// Relations
	User *User `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Room *Room `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

//type UserCompatibility struct {
//	UserCompatibilityID *uint `gorm:"primaryKey;autoIncrement"`
//
//	RoomID  *uint `gorm:"not null"` // scope this match to a specific room
//	UserAID *uint `gorm:"not null;index:idx_user_pair"`
//	UserBID *uint `gorm:"not null;index:idx_user_pair"`
//
//	CompatibilityScore *float64
//
//	// Optional: prevent duplicate A-B and B-A pairs
//	// Or enforce AID < BID ordering to avoid duplicates
//
//	CreatedAt time.Time
//
//	// Relations
//	UserA *User `gorm:"foreignKey:UserAID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
//	UserB *User `gorm:"foreignKey:UserBID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
//	Room  *Room `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
//}
