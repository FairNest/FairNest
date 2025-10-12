package service

import (
	"fmt"
	"github.com/stripe/stripe-go/v83"
	"github.com/stripe/stripe-go/v83/client"
	"github.com/stripe/stripe-go/v83/paymentintent"
	"github.com/stripe/stripe-go/v83/paymentlink"
	"github.com/stripe/stripe-go/v83/price"
	"github.com/stripe/stripe-go/v83/product"
	"log"
)

// The adapter for the Stripe service.
type stripeService struct {
	client *client.API
}

// Creates a new instance of the Stripe service adapter.
func NewStripeService(secretKey string) StripeService {
	stripe.Key = secretKey
	return &stripeService{
		client: client.New(secretKey, nil),
	}
}

func (s *stripeService) CreatePaymentLink(title string, amount int, transactionID int) (string, error) {
	// 1. Create a new product (no metadata needed here).
	prodParams := &stripe.ProductParams{
		Name: stripe.String(title),
	}
	newProduct, err := product.New(prodParams)
	if err != nil {
		return "", err
	}

	// 2. Create a price for the product.
	priceParams := &stripe.PriceParams{
		Currency:    stripe.String(string(stripe.CurrencyTHB)),
		UnitAmount:  stripe.Int64(int64(amount)),
		Product:     stripe.String(newProduct.ID),
		TaxBehavior: stripe.String(string(stripe.PriceTaxBehaviorExclusive)),
	}
	newPrice, err := price.New(priceParams)
	if err != nil {
		return "", err
	}

	// 3. Create the payment link.
	// We MUST embed the metadata inside PaymentIntentData to ensure it is copied
	// to the final PaymentIntent/Charge object in the Stripe Dashboard.
	plParams := &stripe.PaymentLinkParams{
		LineItems: []*stripe.PaymentLinkLineItemParams{
			{
				Price:    stripe.String(newPrice.ID),
				Quantity: stripe.Int64(1),
			},
		},
		PaymentIntentData: &stripe.PaymentLinkPaymentIntentDataParams{
			Metadata: map[string]string{
				"transaction_id": fmt.Sprintf("%d", transactionID),
			},
		},
	}
	pl, err := paymentlink.New(plParams)
	if err != nil {
		log.Printf("Failed to create Stripe Payment Link: %v", err)
		return "", err
	}

	log.Printf("Created Stripe Payment Link with URL: %s", pl.URL)
	return pl.URL, nil
}

// SearchPaymentIntentByTransactionID searches for a PaymentIntent using the custom transaction_id stored in its metadata.
func (s *stripeService) SearchPaymentStatusByTransactionID(transactionID int) (*stripe.PaymentIntent, error) {
	query := fmt.Sprintf("metadata['transaction_id']:'%d'", transactionID)

	params := &stripe.PaymentIntentSearchParams{}
	params.SearchParams.Query = query

	i := paymentintent.Search(params)

	if !i.Next() {
		if i.Err() != nil {
			log.Printf("Stripe SearchPaymentStatus error: %v", i.Err())
			return nil, i.Err()
		}
		return nil, fmt.Errorf("PaymentStatus not found for transaction_id: %d", transactionID)
	}

	pi := i.PaymentIntent()

	if i.Next() {
		log.Printf("Warning: Multiple PaymentStatus found for unique transaction_id: %d", transactionID)
	}

	return pi, nil
}
