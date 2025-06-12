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

	// Define associations
	LifestyleQuiz      []LifestyleQuiz  `gorm:"foreignKey:UserID"`
	Followers          []Follow         `gorm:"foreignKey:FollowingID"`
	Followings         []Follow         `gorm:"foreignKey:UserID"`
	WishlistCopyByUser []CopiedWishlist `gorm:"foreignKey:UserWhoCopyID"`
}

type LifestyleQuiz struct {
	LifestyleQuizID *uint `gorm:"primaryKey;autoIncrement"`
	UserID          *uint `gorm:"not null"`
	Q1              *int
	Q2              *int
	Q3              *int
	Q4              *int
	Q5              *int
	Q6              *int
	Q7              *int
	Q8              *int
	Q9              *int
	Q10             *int
	Q11             *int
	Q12             *int

	//// Define associations
	//WishlistBeingCopy []CopiedWishlist `gorm:"foreignKey:WishlistID"`
}

type Follow struct {
	UserID            *uint   `gorm:"not null"`
	FollowingID       *uint   `gorm:"not null;index"`
	FollowingUsername *string `gorm:"->"`
	FollowingUserPic  *string `gorm:"->"`
	FollowerUsername  *string `gorm:"->"`
	FollowerUserPic   *string `gorm:"->"`

	// Define associations
	User      User `gorm:"foreignKey:UserID"`
	Following User `gorm:"foreignKey:FollowingID"`
}

type CopiedWishlist struct {
	WishlistID    *uint `gorm:"not null"`
	UserWhoCopyID *uint `gorm:"not null"`
}
