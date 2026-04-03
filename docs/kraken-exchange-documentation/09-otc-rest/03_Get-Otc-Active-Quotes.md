# Get OTC Active Quotes

## Endpoint

```
POST /private/GetOtcActiveQuotes
```

## Description

Retrieves the currently active OTC (Over-The-Counter) quotes.

## Authentication

This is a private endpoint requiring authenticated API access.

### Required API Key Permissions

- **Orders and trades** - Query open orders & trades

## Request

### Headers

| Header | Type | Required | Description |
|--------|------|----------|-------------|
| `API-Key` | string | Yes | Your Kraken API key |
| `API-Sign` | string | Yes | Message signature using HMAC-SHA512 |
| `Content-Type` | string | Yes | `application/x-www-form-urlencoded` |

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Unique, incrementing integer used to prevent replay attacks |

## Responses

### 200 - Success

**Description:** Active quotes retrieved.

Returns the currently active OTC quotes for the authenticated account.

### 500 - Internal Error

**Description:** Internal Error.

An unexpected server-side error occurred while processing the request.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/private/GetOtcActiveQuotes" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890"
```

## Notes

- This endpoint is part of the OTC REST API.
- The API key used must have "Orders and trades - Query open orders & trades" permission.
- For historical/completed quotes, use [Get OTC Historical Quotes](get-otc-historical-quotes.md) instead.
- To create new OTC quotes, use [Create OTC Quote Request](create-otc-quote-request.md).

## Source

- [Kraken API Documentation - Get OTC Active Quotes](https://docs.kraken.com/api/docs/rest-api/get-otc-active-quotes)
- Note: The primary URL returned 404. Content sourced from alternate OTC API path.
