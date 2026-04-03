# Get Ramp Limits

## Endpoint

```
GET /b2b/ramp/limits
```

## Description

Retrieve combined min/max limits for a Ramp transaction configuration.

## Authentication

Required. Include `API-Key` and `API-Sign` headers with every request.

## Request Parameters

Query parameters should specify the transaction configuration for which to retrieve limits. Specific parameter details are defined by the Ramp API schema.

## Response

### Success

- **200 OK** -- Returns the combined minimum and maximum limits for the specified Ramp transaction configuration.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |

## Example Request

```http
GET /b2b/ramp/limits HTTP/1.1
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

- Returns combined limits accounting for the specified transaction configuration (crypto asset, fiat currency, payment method, etc.).
- Use this endpoint to validate transaction amounts before creating a checkout URL.
- Related endpoints: [Get Ramp Prospective Quote](get-ramp-prospective-quote.md), [Get Ramp Checkout](get-ramp-checkout.md).

---

*Source: [Kraken API Documentation -- Get Ramp Limits](https://docs.kraken.com/api/docs/ramp-api/get-ramp-limits)*
