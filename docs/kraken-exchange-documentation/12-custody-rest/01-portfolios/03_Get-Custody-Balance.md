# Get Custody Balance

## Endpoint

```
POST /0/private/GetCustodyBalance
```

## Description

Retrieve the balance for each asset held in the specified vault.

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
| `vault_id` | string | Yes | The unique identifier of the vault to query balances for |

## Responses

### 200 - Success

Returns the balance for each asset held in the specified vault.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/GetCustodyBalance" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&vault_id=VAULT_ID"
```

## Notes

- The original URL path for this endpoint was `/0/private/BalanceEx`, but has been updated to `/0/private/GetCustodyBalance`.
- Returns per-asset balances for the specified vault.
- Use [Get Custody Vault](get-custody-vault.md) if you need both vault information and balances in a single call.

## Source

- [Kraken API Documentation - Get Custody Balance](https://docs.kraken.com/api/docs/custody-api/get-custody-balance)
