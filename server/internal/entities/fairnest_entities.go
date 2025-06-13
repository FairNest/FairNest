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
	QuizID  *uint `gorm:"primaryKey;autoIncrement"`
	UserID  *uint `gorm:"uniqueIndex"` // one-to-one
	Answers *string

	// Relations
	User *User `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type Room struct {
	RoomID     *uint `gorm:"primaryKey;autoIncrement"`
	LocationID *uint // one-to-one
	Name       *string
	Capacity   *uint

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
