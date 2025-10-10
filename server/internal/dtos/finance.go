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

type FetchAllOutstandingBalancesByUserIDResponse struct {
	UserID        *uint   `json:"user_id" validate:"required"` // The other user/roommate's ID
	Username      *string `json:"username" validate:"required"`
	UserPicture   *string `json:"user_picture" validate:"required"`
	NetBalance    *int    `json:"net_balance" validate:"required"`    // Positive if user is owed, Negative if user owes
	BalanceStatus *string `json:"balance_status" validate:"required"` // "You Owe" (negative), "You Are Owed" (positive), or "Settled" (zero)
}
