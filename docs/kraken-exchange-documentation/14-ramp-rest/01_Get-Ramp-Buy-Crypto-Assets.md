# List Buy Crypto Assets

## Endpoint

```
GET /b2b/ramp/buy/crypto
```

## Description

List cryptocurrency assets available for Ramp buy transactions, including the networks, withdrawal methods, and provider-specific identifiers surfaced to Ramp partners.

## Authentication

Required. Include `API-Key` and `API-Sign` headers with every request.

## Request Parameters

No request parameters are required for this endpoint.

## Response

### Success

- **200 OK** -- Returns a list of cryptocurrency assets available for Ramp buy transactions, including network information, withdrawal methods, and provider-specific identifiers.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |

## Example Request

```http
GET /b2b/ramp/buy/crypto HTTP/1.1
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

- Returns all crypto assets available for purchase through the Ramp API.
- Response includes network-level details and provider-specific identifiers for each asset.
- Part of the Ramp REST API "Supported Options" section.

---

*Source: [Kraken API Documentation -- List Buy Crypto Assets](https://docs.kraken.com/api/docs/ramp-api/get-ramp-buy-crypto-assets)*
