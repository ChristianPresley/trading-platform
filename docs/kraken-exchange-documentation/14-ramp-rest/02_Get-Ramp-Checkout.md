# Get Ramp Checkout

## Endpoint

```
GET /b2b/ramp/checkout
```

## Description

Generate a hosted Ramp checkout URL for the provided transaction configuration. The response echoes the request parameters so the Ramp partner can confirm what was submitted.

## Authentication

Required. Include `API-Key` and `API-Sign` headers with every request.

## Request Parameters

Query parameters should specify the full transaction configuration (crypto asset, fiat currency, amount, payment method, country, etc.) for generating the checkout URL. Specific parameter details are defined by the Ramp API schema.

## Response

### Success

- **200 OK** -- Returns a hosted checkout URL along with an echo of the submitted request parameters for confirmation.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |

## Example Request

```http
GET /b2b/ramp/checkout HTTP/1.1
Host: nexus.kraken.com
API-Key: <your-api-key>
API-Sign: <your-api-signature>
Payward-Version: 2025-04-15
```

## Example Response

```
HTTP/1.1 200 OK
Content-Type: application/json
```

## Notes

- The response echoes submitted request parameters for partner confirmation.
- The generated checkout URL provides a hosted experience for the end user to complete the purchase.
- Use [Get Ramp Limits](get-ramp-limits.md) and [Get Ramp Prospective Quote](get-ramp-prospective-quote.md) before generating a checkout URL to validate amounts and preview pricing.
- Transaction status updates are delivered via the [Ramp Transaction Update Webhook](ramp-transaction-update-webhook.md).

---

*Source: [Kraken API Documentation -- Get Ramp Checkout](https://docs.kraken.com/api/docs/ramp-api/get-ramp-checkout)*
