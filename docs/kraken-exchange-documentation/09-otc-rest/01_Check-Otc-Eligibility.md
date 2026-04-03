# Check OTC Eligibility

## Endpoint

```
POST /private/CheckOtcClient
```

## Description

Retrieves the client permissions for the OTC Portal. Use this endpoint to verify whether the authenticated account is eligible to use OTC trading features.

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

**Description:** OTC client check result.

Returns the OTC eligibility status and permissions for the authenticated client.

### 500 - Internal Error

**Description:** Internal Error.

An unexpected server-side error occurred while processing the request.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/private/CheckOtcClient" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890"
```

## Notes

- This endpoint is part of the OTC REST API.
- The API key used must have both "Funds permissions - Query" and "Funds permissions - Deposit" permissions.
- Call this endpoint before attempting OTC operations to verify account eligibility.
- The original URL path was `/rest-api/check-otc-client` but may also be accessible under the OTC API path.

## Source

- [Kraken API Documentation - Check OTC Client](https://docs.kraken.com/api/docs/otc-api/check-otc-client)
