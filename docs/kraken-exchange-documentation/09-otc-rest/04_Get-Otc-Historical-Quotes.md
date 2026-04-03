# Get OTC Historical Quotes

## Endpoint

```
POST /private/GetOtcHistoricalQuotes
```

## Description

Retrieves the historical record of OTC (Over-The-Counter) quotes.

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

**Description:** Historical quotes retrieved.

Returns the historical record of OTC quotes for the authenticated account.

### 500 - Internal Error

**Description:** Internal Error.

An unexpected server-side error occurred while processing the request.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/private/GetOtcHistoricalQuotes" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890"
```

## Notes

- This endpoint is part of the OTC REST API.
- The API key used must have "Orders and trades - Query open orders & trades" permission.
- For active/pending quotes, use [Get OTC Active Quotes](get-otc-active-quotes.md) instead.

## Source

- [Kraken API Documentation - Get OTC Historical Quotes](https://docs.kraken.com/api/docs/otc-api/get-otc-historical-quotes)
