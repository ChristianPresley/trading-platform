# Get Custody Vault

## Endpoint

```
POST /0/private/GetCustodyVault
```

## Description

Retrieve information and balances for a specific vault.

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
| `vault_id` | string | Yes | The unique identifier of the vault to retrieve |

## Responses

### 200 - Success

Returns information and balances for the specified vault.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/GetCustodyVault" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&vault_id=VAULT_ID"
```

## Notes

- Use [List Custody Vaults](list-custody-vaults.md) to obtain vault IDs.
- The response includes both vault metadata and current balance information.

## Source

- [Kraken API Documentation - Get Custody Vault](https://docs.kraken.com/api/docs/custody-api/get-custody-vault)
