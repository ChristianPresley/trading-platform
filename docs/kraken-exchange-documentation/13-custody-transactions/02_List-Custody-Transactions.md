# List Custody Transactions

## Endpoint

```
POST /0/private/ListCustodyTransactions
```

## Description

Retrieve the transaction history for a specified vault.

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
| `vault_id` | string | Yes | The unique identifier of the vault to retrieve transaction history for |
| `asset` | string | No | Filter transactions by a specific asset symbol |
| `type` | string | No | Filter transactions by type |
| `start` | integer | No | Starting offset for pagination |
| `limit` | integer | No | Maximum number of transactions to return |

## Responses

### 200 - Success

Returns the transaction history for the specified vault.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/ListCustodyTransactions" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&vault_id=VAULT_ID"
```

## Notes

- Transaction IDs from this response can be used with [Get Custody Transaction](get-custody-transaction.md) for detailed transaction information.
- Use filter parameters to narrow results by asset or transaction type.
- This endpoint is part of the Custody REST API under the Portfolios section.

## Source

- [Kraken API Documentation - List Custody Transactions](https://docs.kraken.com/api/docs/custody-api/list-custody-transactions)
