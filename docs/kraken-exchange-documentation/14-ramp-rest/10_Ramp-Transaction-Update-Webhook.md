# Ramp Transaction Update Webhook

## Endpoint

```
POST /webhooks/payward/transaction-update
```

## Description

This endpoint can be implemented by the partner to receive real-time transaction status updates from Payward. Partners' configured webhook URLs receive POST requests containing transaction details and status information when Ramp transactions are created or change state.

## Authentication

All webhook requests include an `X-Signature` header with an HMAC-SHA256 signature of the request body. Partners must verify this signature to confirm request integrity.

### Signature Verification Steps

1. Extract the `X-Signature` header value from the incoming request.
2. Compute HMAC-SHA256 of the raw request body using your webhook secret.
3. Compare the computed signature with the `X-Signature` header value (hex-encoded).

The HMAC secret key should be securely exchanged with your Payward integration contact.

## Request Body (Incoming Webhook Payload)

The webhook POST body contains transaction details and status information. The payload includes the current transaction status.

### Transaction Status Values

| Status | Description |
|--------|-------------|
| `new` | Transaction initiated. |
| `paid` | Payment received. |
| `pending` | Transaction processing. |
| `completed` | Successfully completed. |
| `failed` | Transaction failed. |
| `canceled` | Transaction canceled. |

## Response Requirements

Your webhook endpoint should respond with the following:

| Status Code | Description |
|-------------|-------------|
| 200 | Webhook received and processed successfully. Return any 2xx status code to acknowledge receipt. |
| 500 | Internal server error on partner side. Payward will retry delivery. |

## Retry Behavior

Payward automatically retries failed webhook deliveries using exponential backoff. Non-2xx responses trigger retries.

## Example Request (Incoming)

```http
POST /webhooks/payward/transaction-update HTTP/1.1
Content-Type: application/json
X-Signature: <hmac-sha256-hex-signature>
```

## Notes

- This is an endpoint that the **partner** implements to receive webhooks from Payward -- not an endpoint you call.
- Always verify the `X-Signature` header before processing the webhook payload.
- Return a 2xx status code to acknowledge receipt and prevent retries.
- Non-2xx responses will trigger automatic retries with exponential backoff.
- Contact your Payward integration contact to securely exchange the HMAC secret key.
- Webhooks are sent when transactions are created or change state.

---

*Source: [Kraken API Documentation -- Ramp Transaction Update Webhook](https://docs.kraken.com/api/docs/ramp-api/ramp-transaction-update-webhook)*
