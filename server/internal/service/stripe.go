package service

import "github.com/stripe/stripe-go/v83"

type StripeService interface {
	CreatePaymentLink(title string, amount int, transactionID int) (string, error)

	// SearchPaymentIntentByTransactionID searches for a PaymentIntent using a custom transaction ID stored in metadata.
	SearchPaymentStatusByTransactionID(transactionID int) (*stripe.PaymentIntent, error)
}
