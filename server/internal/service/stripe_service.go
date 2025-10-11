package service

import (
	"github.com/stripe/stripe-go/v83"
	"github.com/stripe/stripe-go/v83/client"
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

// Function to create a Stripe Payment Link for a specific transaction amount and title.
func (s *stripeService) CreatePaymentLink(title string, amount int) (string, error) {
	// Create a new product.
	prodParams := &stripe.ProductParams{
		Name: stripe.String(title),
	}
	newProduct, err := product.New(prodParams)
	if err != nil {
		return "", err
	}

	// Create a price for the product.
	priceParams := &stripe.PriceParams{
		// CHANGED: Using Thai Baht (THB) currency. This enables PromptPay on the checkout page.
		Currency:    stripe.String(string(stripe.CurrencyTHB)),
		UnitAmount:  stripe.Int64(int64(amount)),
		Product:     stripe.String(newProduct.ID),
		TaxBehavior: stripe.String(string(stripe.PriceTaxBehaviorExclusive)),
	}
	newPrice, err := price.New(priceParams)
	if err != nil {
		return "", err
	}

	// Create the payment link.
	plParams := &stripe.PaymentLinkParams{
		LineItems: []*stripe.PaymentLinkLineItemParams{
			{
				Price:    stripe.String(newPrice.ID),
				Quantity: stripe.Int64(1),
			},
		},
		// NOTE: Stripe Payment Links automatically determine the best payment methods
		// based on the currency (THB enables PromptPay).
	}
	pl, err := paymentlink.New(plParams)
	if err != nil {
		return "", err
	}

	log.Printf("Created Stripe Payment Link with URL: %s", pl.URL)
	return pl.URL, nil
}
