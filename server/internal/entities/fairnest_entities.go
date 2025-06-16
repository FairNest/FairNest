package entities

import "time"

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
	RoomType             *bool // "true = Private", "false = Public"
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
	LocationID *uint   `gorm:"primaryKey;autoIncrement"`
	City       *string // "Bangkok"
	District   *string // "Phaya Thai"
	Address    *string // "123/45 Soi Sukhumvit 11 10140 Bangkok"
}

type RoomMember struct {
	RoomMemberID *uint `gorm:"primaryKey;autoIncrement"`
	UserID       *uint `gorm:"not null;uniqueIndex:idx_user_room"`
	RoomID       *uint `gorm:"not null;uniqueIndex:idx_user_room"`
	IsHost       *bool // "true = Host", "false = Member"

	// Relations
	User *User `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Room *Room `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type UserCompatibilityProfile struct {
	UserCompatibilityProfileID *uint `gorm:"primaryKey;autoIncrement"`

	RoomID  *uint `gorm:"not null"`
	UserAID *uint `gorm:"not null;index:idx_user_pair"`
	UserBID *uint `gorm:"not null;index:idx_user_pair"`

	// Optional: prevent duplicate A-B and B-A pairs
	// Or enforce AID < BID ordering to avoid duplicates
	CompatibilityScore *float64 // 0.0 to 1.0 → shown as 88%
	SharedTraits       *string  // e.g. "Likes Quiet Time, Prefers Clean Spaces"
	ConflictTraits     *string  // e.g. "Dislikes Guest Noise"
	SuggestionMessage  *string  // e.g. "Consider aligning on quiet hours..."

	CreatedAt *time.Time

	UserA *User `gorm:"foreignKey:UserAID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	UserB *User `gorm:"foreignKey:UserBID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Room  *Room `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type Notice struct {
	NoticeID   *uint `gorm:"primaryKey;autoIncrement"`
	ReceiverID *uint `gorm:"not null"` // user who receives the notice
	SenderID   *uint `gorm:"not null"` // user_id = 1 is system, not real user
	//SenderID   *uint // nullable: if null → system message
	//RoomID        *uint // optional: only if related to a room
	NoticeTitle   *string
	NoticeMessage *string
	IsRead        *bool   // true = read, nil = unread
	Type          *string // e.g. "chore", "system", "reminder", etc.
	CreatedAt     *time.Time

	// Relations
	Receiver *User `gorm:"foreignKey:ReceiverID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Sender   *User `gorm:"foreignKey:SenderID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	//Sender   *User `gorm:"foreignKey:SenderID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL"`
	//Room     *Room `gorm:"foreignKey:RoomID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL"`
}

type Chore struct {
	ChoreID           *uint `gorm:"primaryKey;autoIncrement"`
	RoomID            *uint `gorm:"not null"`
	ChoreTitle        *string
	ChoreDescription  *string
	DueDayOfWeek      *string // e.g. "Tuesday"
	DueTime           *string // e.g. "17:00"
	ReminderDayOfWeek *string // e.g. "Monday"
	ReminderTime      *string // e.g. "16:00"
	Recurrence        *string // e.g. "Weekly"
	AutoRotate        *bool   // "true = Auto Rotate", "false = No Auto Rotate"
	ChoreScore        *int    // +10 or -10, etc.

	CreatedAt time.Time
	UpdatedAt time.Time

	Room *Room `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type ChoreAssignment struct {
	ChoreAssignmentID *uint `gorm:"primaryKey;autoIncrement"`
	ChoreID           *uint `gorm:"not null"`
	UserID            *uint `gorm:"not null"`
	AssignedDate      *time.Time
	Status            *bool // "nil = Not Completed", "true = Completed", "false = Missed"
	CompletedAt       *time.Time
	ScoreEarned       *int // e.g. +10 or -10

	Chore *Chore `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	User  *User  `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type ChoreRotationUser struct {
	ChoreRotationUserID *uint `gorm:"primaryKey;autoIncrement"`
	ChoreID             *uint `gorm:"not null"`
	UserID              *uint `gorm:"not null"`

	Chore *Chore `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	User  *User  `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type Bill struct {
	BillID          *uint    `gorm:"primaryKey;autoIncrement"`
	RoomID          *uint    `gorm:"not null"`
	BillName        *string  // "Electricity", "Netflix", "Water"
	Amount          *float64 // Total cost
	Recurrence      *string  // "monthly", "weekly", "once"
	DueDayOfMonth   *int     // 1-31, 3 = due on 3rd each month
	IsSplitEvenly   *bool    // true -> split even, false -> use BillSplit
	BillDescription *string

	CreatedAt *time.Time
	UpdatedAt *time.Time
}

type BillSplit struct {
	BillSplitID *uint    `gorm:"primaryKey;autoIncrement"`
	BillID      *uint    `gorm:"not null"`
	UserID      *uint    `gorm:"not null"`
	Amount      *float64 // how much this user is responsible for

	User *User `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type PaymentRequest struct {
	PaymentRequestID *uint `gorm:"primaryKey;autoIncrement"`
	BillID           *uint // link to original Bill
	//BillID           *uint `gorm:"not null"` // link to original Bill
	RequesterID *uint `gorm:"not null"` // the one who paid
	PayerID     *uint `gorm:"not null"` // the one who owes

	Amount      *float64
	Description *string

	IsPaid    *bool
	PaidAt    *time.Time
	CreatedAt *time.Time

	QRCodeURL      *string // For SCB QR code payment
	TransactionRef *string // Ref1 or transaction_id from SCB response
	SlipVerifyCode *string // For verifying slip scan (optional)

	// For async webhook (if SCB notifies you)
	SCBStatus *string // "PENDING", "SUCCESS", "FAILED"

	Requester *User `gorm:"foreignKey:RequesterID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Payer     *User `gorm:"foreignKey:PayerID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type SCBAccessToken struct {
	ID          *uint `gorm:"primaryKey;autoIncrement"`
	AccessToken *string
	TokenType   *string
	ExpiresIn   *int
	Scope       *string
	CreatedAt   *time.Time
}
