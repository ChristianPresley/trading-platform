# List Custody Vaults

## Endpoint

```
POST /0/private/ListCustodyVaults
```

## Description

Retrieve all vaults within the custody domain.

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

## Responses

### 200 - Success

Returns a list of all vaults within the custody domain.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/ListCustodyVaults" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890"
```

## Notes

- This endpoint returns all vaults accessible under the authenticated account's custody domain.
- Use the vault IDs returned by this endpoint to query individual vault details via the [Get Custody Vault](get-custody-vault.md) endpoint.

## Source

- [Kraken API Documentation - List Custody Vaults](https://docs.kraken.com/api/docs/custody-api/list-custody-vaults)
