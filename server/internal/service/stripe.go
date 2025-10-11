package service

type StripeService interface {
	CreatePaymentLink(title string, amount int) (string, error)
}
