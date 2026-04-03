# Get Withdraw Addresses

## Endpoint

```
POST /0/private/WithdrawAddresses
```

## Description

Retrieve a list of withdrawal addresses for a specified vault.

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
| `vault_id` | string | Yes | The unique identifier of the vault to retrieve withdrawal addresses for |
| `asset` | string | No | Filter withdrawal addresses by a specific asset symbol |
| `method` | string | No | Filter withdrawal addresses by a specific withdrawal method |

## Responses

### 200 - Success

Returns a list of withdrawal addresses for the specified vault.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/WithdrawAddresses" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&vault_id=VAULT_ID"
```

## Notes

- Use [Get Withdraw Methods](withdraw-methods.md) to determine available withdrawal methods before querying addresses.
- This endpoint is part of the Custody REST API under the Transfers section.

## Source

- [Kraken API Documentation - Withdraw Addresses](https://docs.kraken.com/api/docs/custody-api/withdraw-addresses)
