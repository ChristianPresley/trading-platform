# Get Custody Transaction

## Endpoint

```
POST /0/private/GetCustodyTransaction
```

## Description

Retrieve details for a specific custody transaction by its transaction ID.

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
| `transaction_id` | string | Yes | The unique identifier of the transaction to retrieve |

## Responses

### 200 - Success

**Description:** Transaction retrieved.

Returns detailed information for the specified custody transaction.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/GetCustodyTransaction" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&transaction_id=TRANSACTION_ID"
```

## Notes

- Use [List Custody Transactions](list-custody-transactions.md) to obtain transaction IDs.
- This endpoint is part of the Custody REST API.

## Source

- [Kraken API Documentation - Get Custody Transaction](https://docs.kraken.com/api/docs/custody-api/get-custody-transaction)
