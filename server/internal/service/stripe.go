package service

type StripeService interface {
	CreatePaymentLink(title string, amount int, transactionID int) (string, error)
}
