# Get Deposit Addresses

## Endpoint

```
POST /0/private/DepositAddresses
```

## Description

Retrieve existing deposit addresses or generate new ones for a specific asset and funding method. Consult the [Get Deposit Methods](deposit-methods.md) endpoint first to determine the appropriate deposit method for your use case.

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
| `asset` | string | Yes | The asset symbol to retrieve deposit addresses for (e.g., `XBT`, `ETH`) |
| `method` | string | Yes | The deposit method name (obtained from [Get Deposit Methods](deposit-methods.md)) |
| `new` | boolean | No | Whether to generate a new deposit address. Default: `false` |

## Responses

### 200 - Success

Returns existing deposit addresses or a newly generated address for the specified asset and method.

### Error Responses

Standard Kraken error format applies. Errors are returned in the `error` array of the response body.

## Example

### Request

```bash
curl -X POST "https://api.kraken.com/0/private/DepositAddresses" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_SIGNATURE" \
  -d "nonce=1234567890&asset=XBT&method=Bitcoin"
```

## Notes

- Always call [Get Deposit Methods](deposit-methods.md) first to determine valid deposit methods before requesting addresses.
- Setting `new=true` will generate a fresh deposit address. Use this when you need a unique address for a specific deposit.
- This endpoint is part of the Custody REST API under the Portfolios section.

## Source

- [Kraken API Documentation - Deposit Addresses](https://docs.kraken.com/api/docs/custody-api/deposit-addresses)
