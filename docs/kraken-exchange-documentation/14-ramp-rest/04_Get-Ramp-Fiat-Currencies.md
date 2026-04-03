# List Fiat Currencies

## Endpoint

```
GET /b2b/ramp/fiat-currencies
```

## Description

Retrieve fiat currencies supported for funding Ramp transactions.

## Authentication

Required. Include `API-Key` and `API-Sign` headers with every request.

## Request Parameters

No request parameters are required for this endpoint.

## Response

### Success

- **200 OK** -- Returns a list of fiat currencies supported for funding Ramp transactions.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |

## Example Request

```http
GET /b2b/ramp/fiat-currencies HTTP/1.1
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

- Returns all fiat currencies that can be used for Ramp purchase transactions.
- Part of the Ramp REST API "Supported Options" section.
- This is a read-only query endpoint with no request body.

---

*Source: [Kraken API Documentation -- List Fiat Currencies](https://docs.kraken.com/api/docs/ramp-api/get-ramp-fiat-currencies)*
