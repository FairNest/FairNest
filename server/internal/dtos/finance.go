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
