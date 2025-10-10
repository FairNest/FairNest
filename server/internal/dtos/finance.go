package dtos

type FinanceDataResponse struct {
	FinanceID *uint   `json:"finance_id" validate:"required"`
	TitleName *string `json:"title_name" validate:"required"`
	DueDate   *string `json:"due_date" validate:"required"`
	Category  *string `json:"category" validate:"required"`
	SplitType *bool   `json:"split_type" validate:"required"`
	CreatedAt *string `json:"created_at" validate:"required"`
}

type FinanceByFinanceIDDataResponse struct {
	FinanceID *uint   `json:"finance_id" validate:"required"`
	TitleName *string `json:"title_name" validate:"required"`
	DueDate   *string `json:"due_date" validate:"required"`
	Category  *string `json:"category" validate:"required"`
	SplitType *bool   `json:"split_type" validate:"required"`
	CreatedAt *string `json:"created_at" validate:"required"`
}

type TransactionDataResponse struct {
	TransactionID     *uint   `json:"transaction_id" validate:"required"`
	FinanceID         *uint   `json:"finance_id" validate:"required"`
	PayerID           *uint   `json:"payer_id" validate:"required"`
	DebtorID          *uint   `json:"debtor_id" validate:"required"`
	TotalAmount       *int    `json:"total_amount" validate:"required"`
	TransactionStatus *bool   `json:"transaction_status" validate:"required"`
	QRCodeImage       *string `json:"qr_code_image" validate:"required"`
	CreatedAt         *string `json:"created_at" validate:"required"`
	PaidAt            *string `json:"paid_at" validate:"required"`
}

type TransactionByTransactionIDDataResponse struct {
	TransactionID     *uint   `json:"transaction_id" validate:"required"`
	FinanceID         *uint   `json:"finance_id" validate:"required"`
	PayerID           *uint   `json:"payer_id" validate:"required"`
	DebtorID          *uint   `json:"debtor_id" validate:"required"`
	TotalAmount       *int    `json:"total_amount" validate:"required"`
	TransactionStatus *bool   `json:"transaction_status" validate:"required"`
	QRCodeImage       *string `json:"qr_code_image" validate:"required"`
	CreatedAt         *string `json:"created_at" validate:"required"`
	PaidAt            *string `json:"paid_at" validate:"required"`
}

type GetMyMonthlySnapshotByUserIDResponse struct {
	TotalPaidByMe *int `json:"total_paid_by_me" validate:"required"` // Sum of transactions where PayerID=UserID and Status=true (settled)
	TotalOwedToMe *int `json:"total_owed_to_me" validate:"required"` // Sum of transactions where PayerID=UserID and Status=false (unsettled)
	TotalOwedByMe *int `json:"total_owed_by_me" validate:"required"` // Sum of transactions where DebtorID=UserID and Status=false (unsettled)
}

type FetchAllOutstandingBalancesByUserIDResponse struct {
	UserID        *uint   `json:"user_id" validate:"required"` // The other user/roommate's ID
	Username      *string `json:"username" validate:"required"`
	UserPicture   *string `json:"user_picture" validate:"required"`
	NetBalance    *int    `json:"net_balance" validate:"required"`    // Positive if user is owed, Negative if user owes
	BalanceStatus *string `json:"balance_status" validate:"required"` // "You Owe" (negative), "You Are Owed" (positive), or "Settled" (zero)
}

type FetchAllUpcomingPaymentByUserIDResponse struct {
	FinanceID         *uint   `json:"finance_id" validate:"required"`
	TransactionID     *uint   `json:"transaction_id" validate:"required"`
	TitleName         *string `json:"title_name" validate:"required"`
	DueDate           *string `json:"due_date" validate:"required"`
	Category          *string `json:"category" validate:"required"`
	TotalAmount       *int    `json:"total_amount" validate:"required"`
	TransactionStatus *bool   `json:"transaction_status" validate:"required"`
	QRCodeImage       *string `json:"qr_code_image" validate:"required"`
}

type FetchAllPaidTransactionHistoryByUserIDResponse struct {
	FinanceID         *uint   `json:"finance_id" validate:"required"`
	TransactionID     *uint   `json:"transaction_id" validate:"required"`
	TitleName         *string `json:"title_name" validate:"required"`
	Category          *string `json:"category" validate:"required"`
	TotalAmount       *int    `json:"total_amount" validate:"required"`
	TransactionStatus *bool   `json:"transaction_status" validate:"required"`
	PaidAt            *string `json:"paid_at" validate:"required"`

	// Paid to User Details
	PaidToUserID      *uint   `json:"paid_to_user_id" validate:"required"`
	PaidToUsername    *string `json:"paid_to_username" validate:"required"`
	PaidToUserPicture *string `json:"paid_to_user_picture" validate:"required"`
}

type TransactionDetailRequest struct {
	DebtorID    *uint `json:"debtor_id" validate:"required"`
	TotalAmount *int  `json:"total_amount" validate:"required"`
}

type CreateFinanceByPayerIDRequest struct {
	TitleName *string `json:"title_name" validate:"required"`
	DueDate   *string `json:"due_date" validate:"required"`
	Category  *string `json:"category" validate:"required"`
	SplitType *bool   `json:"split_type" validate:"required"`

	// Slice of individual transactions/debts
	Transactions []TransactionDetailRequest `json:"transactions" validate:"required,min=1,dive"`
}

type CreatedTransactionResponse struct {
	TransactionID     *uint   `json:"transaction_id"`
	DebtorID          *uint   `json:"debtor_id"`
	PayerID           *uint   `json:"payer_id"`
	TotalAmount       *int    `json:"total_amount"`
	TransactionStatus *bool   `json:"transaction_status"` // false (unsettled)
	QRCodeImage       *string `json:"qr_code_image"`
	CreatedAt         *string `json:"created_at"`
}

type CreateFinanceByPayerIDResponse struct {
	FinanceID *uint   `json:"finance_id"`
	TitleName *string `json:"title_name"`
	DueDate   *string `json:"due_date"`
	Category  *string `json:"category"`
	SplitType *bool   `json:"split_type"`
	CreatedAt *string `json:"created_at"`

	Transactions []CreatedTransactionResponse `json:"transactions"`
}
