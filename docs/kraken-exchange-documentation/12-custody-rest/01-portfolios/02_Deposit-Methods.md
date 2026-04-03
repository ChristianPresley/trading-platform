# Get Deposit Methods

## Endpoint

```
POST /0/private/DepositMethods
```

## Description

Retrieve the available deposit funding methods for depositing a specific asset. This endpoint is a prerequisite for using the [Get Deposit Addresses](deposit-addresses.md) endpoint, as deposit method information is required to retrieve or generate deposit addresses.

## Authentication

This is a private endpoint requiring authenticated API access. Requests must include valid API key credentials and signature.

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
| `asset` | string | Yes | The asset symbol to retrieve deposit methods for (e.g., `XBT`, `ETH`) |

## Responses

### 200 - Success

Returns the available deposit funding methods for the specified asset.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/DepositMethods" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&asset=XBT"
```

## Notes

- You must call this endpoint first to determine which deposit method to use before calling [Get Deposit Addresses](deposit-addresses.md).
- Different assets may have different available deposit methods (e.g., on-chain, Lightning Network).
- This endpoint is part of the Custody REST API under the Portfolios section.

## Source

- [Kraken API Documentation - Deposit Methods](https://docs.kraken.com/api/docs/custody-api/deposit-methods)
