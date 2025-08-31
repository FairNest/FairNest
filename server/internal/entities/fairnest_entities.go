package entities

import "time"

type User struct {
	UserID                     *uint   `gorm:"primaryKey;autoIncrement"`
	Username                   *string `gorm:"unique;not null"`
	Password                   *string
	Email                      *string `gorm:"unique;not null"`
	Firstname                  *string
	Lastname                   *string
	PhoneNumber                *string
	UserPicture                *string
	UserAboutMe                *string
	BankAccountNumber          *string
	RoommateScore              *float64
	UserVerificationPicture    *string
	UserIdentityDocumentNumber *string `gorm:"unique;not null"`
	UserIdentityDocumentType   *bool

	// Relations
	RoomMembers []RoomMember
}

type Lifestyle struct {
	LifestyleID *uint `gorm:"primaryKey;autoIncrement"`
	UserID      *uint `gorm:"uniqueIndex"` // one-to-one
	Q1          *int
	Q2          *int
	Q3          *int
	Q4          *int
	Q5          *int
	Q6          *int
	Q7          *int
	Q8          *int
	Q9          *int
	Q10         *int
	Q11         *int
	Q12         *int

	// Personality Traits
	UserTidiness       *float64
	UserNoiseActivity  *float64
	UserSchedule       *float64
	UserGuestFrequency *float64
	UserTaskStructure  *float64
	UserMoneyAttitude  *float64

	// Relations
	User *User `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type Room struct {
	RoomID *uint `gorm:"primaryKey;autoIncrement"`

	// RoomDetails
	RoomName               *string
	RoomType               *bool // "true = Private", "false = Public"
	RoomMaxCapacity        *int
	RoomCurrentCapacity    *int
	RoomDescription        *string
	RoomCode               *string `gorm:"uniqueIndex"`
	RoomCompatibilityScore *int    // average of all members' roommate scores
	RoomPicture            *string

	// LivingSpaceDetails
	LivingSpaceName        *string
	RentCost               *int
	ElectricityCostPerUnit *int
	WaterCostPerUnit       *int
	OtherUtilityDetails    *string

	// RoommateAgreements
	QuietHoursStart *string
	GuestStayOver   *string
	HandleCleaning  *string
	SharedSpace     *string
	SplitCosts      *bool // "true = Equal split", "false = By usage/room size"

	// Personality Averages
	AvgTidiness       *float64
	AvgNoiseActivity  *float64
	AvgSchedule       *float64
	AvgGuestFrequency *float64
	AvgTaskStructure  *float64
	AvgMoneyAttitude  *float64

	// Relations
	RoomMembers []RoomMember
}

type RoomMember struct {
	RoomMemberID *uint `gorm:"primaryKey;autoIncrement"`
	RoomID       *uint `gorm:"not null;uniqueIndex:idx_user_room"`
	UserID       *uint `gorm:"not null;uniqueIndex:idx_user_room"`
	IsHost       *bool // "true = Host", "false = Member"

	// Relations
	User *User `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Room *Room `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type RoomJoinRequest struct {
	RoomJoinRequestID *uint `gorm:"primaryKey;autoIncrement"`
	RoomID            *uint `gorm:"not null;index"`
	ApplicantUserID   *uint `gorm:"not null;index"`

	// Tri-state: nil=pending, true=approved, false=rejected
	Decision *bool `gorm:"index"`

	EligibleVoterCount *int    `gorm:"not null"`
	EligibleVoterIDs   *string // JSON snapshot of voter userIDs (optional but recommended)
	CreatedAt          time.Time

	// Relations
	Room *Room `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type RoomJoinVote struct {
	RoomJoinVoteID    *uint `gorm:"primaryKey;autoIncrement"`
	RoomJoinRequestID *uint `gorm:"not null;index"`
	VoterUserID       *uint `gorm:"not null;index"`

	// Tri-state: nil=pending (hasn’t voted), true=approve, false=reject
	Decision  *bool `gorm:"index"`
	CreatedAt time.Time

	// Relations
	Request *RoomJoinRequest `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
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

	// Relations
	UserA *User `gorm:"foreignKey:UserAID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	UserB *User `gorm:"foreignKey:UserBID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Room  *Room `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type Notification struct {
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

	// Relations
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

	// Relations
	Chore *Chore `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	User  *User  `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type ChoreRotationUser struct {
	ChoreRotationUserID *uint `gorm:"primaryKey;autoIncrement"`
	ChoreID             *uint `gorm:"not null"`
	UserID              *uint `gorm:"not null"`

	// Relations
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

	// Relations
	Room *Room `gorm:"foreignKey:RoomID"`
}

type BillSplit struct {
	BillSplitID *uint    `gorm:"primaryKey;autoIncrement"`
	BillID      *uint    `gorm:"not null"`
	UserID      *uint    `gorm:"not null"`
	Amount      *float64 // how much this user is responsible for

	// Relations
	User *User `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Bill *Bill `gorm:"foreignKey:BillID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
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

	// Relations
	Requester *User `gorm:"foreignKey:RequesterID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Payer     *User `gorm:"foreignKey:PayerID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Bill      *Bill `gorm:"foreignKey:BillID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL"`
}

type SCBAccessToken struct {
	ID          *uint `gorm:"primaryKey;autoIncrement"`
	AccessToken *string
	TokenType   *string
	ExpiresIn   *int
	Scope       *string
	CreatedAt   *time.Time
}
