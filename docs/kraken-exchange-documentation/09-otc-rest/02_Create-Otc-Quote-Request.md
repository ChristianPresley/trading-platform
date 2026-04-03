# Create OTC Quote Request

## Endpoint

```
POST /private/CreateOtcQuoteRequest
```

## Description

Creates a new OTC (Over-The-Counter) request for quote.

## Authentication

This is a private endpoint requiring authenticated API access.

### Required API Key Permissions

- **Orders and trades** - Create & modify orders

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
| `pair` | string | Yes | The trading pair for the OTC quote (e.g., `BTC/USD`) |
| `side` | string | Yes | The side of the trade (`buy` or `sell`) |
| `volume` | string | Yes | The volume/quantity for the quote request |

## Responses

### 200 - Success

**Description:** Create OTC quote result.

Returns the created OTC quote request details.

### 500 - Internal Error

**Description:** Internal Error.

An unexpected server-side error occurred while processing the request.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/private/CreateOtcQuoteRequest" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&pair=BTC/USD&side=buy&volume=10"
```

## Notes

- This endpoint is part of the OTC REST API.
- The API key used must have "Orders and trades - Create & modify orders" permission.
- Use [Get OTC Pairs](get-otc-pairs.md) to determine available trading pairs for OTC quotes.
- Active quotes can be retrieved via [Get OTC Active Quotes](get-otc-active-quotes.md).
- Historical quotes can be retrieved via [Get OTC Historical Quotes](get-otc-historical-quotes.md).

## Source

- [Kraken API Documentation - Create OTC Quote Request](https://docs.kraken.com/api/docs/otc-api/create-otc-quote-request)
