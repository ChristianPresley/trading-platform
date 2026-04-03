# Get Withdraw Methods

## Endpoint

```
POST /0/private/WithdrawMethods
```

## Description

Retrieve a list of withdrawal methods available for a specified vault.

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
| `vault_id` | string | Yes | The unique identifier of the vault to retrieve withdrawal methods for |
| `asset` | string | No | Filter withdrawal methods by a specific asset symbol |

## Responses

### 200 - Success

Returns a list of available withdrawal methods for the specified vault.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/WithdrawMethods" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&vault_id=VAULT_ID"
```

## Notes

- Use the withdrawal method information returned by this endpoint when calling [Get Withdraw Addresses](withdraw-addresses.md).
- Different assets may support different withdrawal methods.
- This endpoint is part of the Custody REST API under the Transfers section.

## Source

- [Kraken API Documentation - Withdraw Methods](https://docs.kraken.com/api/docs/custody-api/withdraw-methods)
