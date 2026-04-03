# List Payment Methods

## Endpoint

```
GET /b2b/ramp/payment-methods
```

## Description

List fiat payment methods supported for Ramp deposits, including optional mapping to provider-specific identifiers.

## Authentication

Required. Include `API-Key` and `API-Sign` headers with every request.

## Request Parameters

No request parameters are required for this endpoint.

## Response

### Success

- **200 OK** -- Returns a list of supported fiat payment methods with optional provider-specific identifier mappings.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |

## Example Request

```http
GET /b2b/ramp/payment-methods HTTP/1.1
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

- Returns all supported payment methods for Ramp fiat deposits.
- Includes optional mapping to provider-specific identifiers for integration convenience.
- Part of the Ramp REST API "Supported Options" section.

---

*Source: [Kraken API Documentation -- List Payment Methods](https://docs.kraken.com/api/docs/ramp-api/get-ramp-payment-methods)*
