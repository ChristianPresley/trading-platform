# Get OTC Pairs

## Endpoint

```
POST /private/GetOtcPairs
```

## Description

Retrieves the list of OTC (Over-The-Counter) trading pairs.

## Authentication

This is a private endpoint requiring authenticated API access.

### Required API Key Permissions

- **Funds permissions** - Query
- **Funds permissions** - Deposit

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

No additional parameters are required beyond the nonce.

## Responses

### 200 - Success

**Description:** Available OTC pairs.

Returns the list of trading pairs available for OTC trading.

### 500 - Internal Error

**Description:** Internal Error.

An unexpected server-side error occurred while processing the request.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/private/GetOtcPairs" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890"
```

## Notes

- This endpoint is part of the OTC REST API.
- The API key used must have both "Funds permissions - Query" and "Funds permissions - Deposit" permissions.
- Use the pairs returned by this endpoint when creating OTC quote requests via [Create OTC Quote Request](create-otc-quote-request.md).

## Source

- [Kraken API Documentation - Get OTC Pairs](https://docs.kraken.com/api/docs/otc-api/get-otc-pairs)
