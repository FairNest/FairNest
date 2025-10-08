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
	RoomType               *bool // "true = Public", "false = Private"
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

type Notification struct {
	NotificationID *uint `gorm:"primaryKey;autoIncrement"`
	SenderID       *uint `gorm:"not null"` // user_id = 1 is system, not real user
	ReceiverID     *uint `gorm:"not null"` // user who receives the notice

	//NotificationTitle *string
	NotificationMessage               *string
	IsRead                            *bool // true = read, false = unread
	VoteNotificationRoomJoinRequestID *uint

	CreatedAt *time.Time

	// Relations
	Receiver        *User            `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Sender          *User            `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	RoomJoinRequest *RoomJoinRequest `gorm:"foreignKey:VoteNotificationRoomJoinRequestID;references:RoomJoinRequestID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL"`
}

type RoomJoinRequest struct {
	RoomJoinRequestID *uint `gorm:"primaryKey;autoIncrement"`
	RoomID            *uint `gorm:"not null;uniqueIndex:idx_user_room"`
	RequesterUserID   *uint `gorm:"not null;uniqueIndex:idx_user_room"`

	// * tri-state: nil=pending, true=approved, false=rejected
	Status *bool `gorm:"index"`

	EligibleVoterCount *int    `gorm:"not null"`
	EligibleVoterIDs   *string // * json snapshot of voter userIDs (optional but recommended)
	CreatedAt          *time.Time

	// Relations with proper foreign key definitions
	Room      *Room `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Requester *User `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type RoomJoinVote struct {
	RoomJoinVoteID    *uint `gorm:"primaryKey;autoIncrement"`
	RoomJoinRequestID *uint `gorm:"not null;uniqueIndex:idx_request_voter"`
	VoterUserID       *uint `gorm:"not null;uniqueIndex:idx_request_voter"`

	Vote      *bool `gorm:"index"`
	CreatedAt *time.Time

	// Relations
	RoomJoinRequest *RoomJoinRequest `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	VoterUser       *User            `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type Chore struct {
	ChoreID           *uint   `gorm:"primaryKey;autoIncrement"`
	RoomID            *uint   `gorm:"not null"`
	ChoreTitle        *string `gorm:"not null"`
	ChoreDescription  *string
	Category          *string `gorm:"not null"` // * bathroom, kitchen, living room, etc
	DueDayOfWeek      *string `gorm:"not null"` // * monday, tuesday, etc
	DueTime           *string `gorm:"not null"` // * 14:00, 18:30, etc
	ReminderDayOfWeek *string // * optional reminder day
	ReminderTime      *string // * optional reminder time
	Recurrence        *string `gorm:"not null"`      // * weekly, monthly, once
	AutoRotate        *bool   `gorm:"default:false"` // * auto rotation between users
	ChoreScore        *int    `gorm:"not null"`      // * positive points for completion, negative for missing

	CreatedAt time.Time
	UpdatedAt time.Time

	// * relations with CASCADE DELETE
	Room             *Room               `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	ChoreAssignments []ChoreAssignment   `gorm:"foreignKey:ChoreID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	ChoreRotations   []ChoreRotationUser `gorm:"foreignKey:ChoreID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type ChoreAssignment struct {
	ChoreAssignmentID *uint      `gorm:"primaryKey;autoIncrement"`
	ChoreID           *uint      `gorm:"not null"`
	UserID            *uint      `gorm:"not null"`
	AssignedDate      *time.Time `gorm:"not null"`          // * specific date for this assignment
	DueDateTime       *time.Time `gorm:"not null"`          // * exact due date and time
	Status            *string    `gorm:"default:'pending'"` // * pending, completed, missed, overdue
	CompletedAt       *time.Time
	ScoreEarned       *int // * actual score earned (positive for completion, negative for miss)

	// * relations
	Chore *Chore `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	User  *User  `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type ChoreRotationUser struct {
	ChoreRotationUserID *uint `gorm:"primaryKey;autoIncrement"`
	ChoreID             *uint `gorm:"not null"`
	UserID              *uint `gorm:"not null"`
	RotationOrder       *int  `gorm:"not null"` // * order in rotation: 1, 2, 3, etc

	// * relations
	Chore *Chore `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	User  *User  `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}

type Finance struct {
	FinanceID *uint   `gorm:"primaryKey;autoIncrement"`
	TitleName *string `gorm:"not null"`
	DueDate   *time.Time
	Category  *string // * Bill, Groceries, Outing/Activity, Shared Subscription, Other (custom)
	SplitType *bool   // * Fair split = True, Custom = False
	CreatedAt *time.Time

	// * relations
	Transactions []Transaction
}

type Transaction struct {
	TransactionID     *uint `gorm:"primaryKey;autoIncrement"`
	FinanceID         *uint `gorm:"not null"`
	PayerID           *uint `gorm:"not null"` // user who paid
	DebtorID          *uint `gorm:"not null"` // user who owes
	TotalAmount       *int  `gorm:"not null"` // total amount paid
	TransactionStatus *bool // true = settled, false = unsettled
	QRCodeImage       *string
	CreatedAt         *time.Time
	PaidAt            *time.Time

	// * relations
	Finance *Finance `gorm:"constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Payer   *User    `gorm:"foreignKey:PayerID;references:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
	Debtor  *User    `gorm:"foreignKey:DebtorID;references:UserID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE"`
}
