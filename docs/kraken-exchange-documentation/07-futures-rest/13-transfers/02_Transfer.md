# Initiate Wallet Transfer

## Endpoint

```
POST /transfer
```

## Description

Initiates a transfer between margin accounts sharing the same collateral currency, or between a margin account and a cash account. This allows redistribution of funds across different account types within the Kraken Futures platform.

## Authentication

Requires API key authentication with Futures trading and withdrawal permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `fromAccount` | string | Yes | Source account wallet name |
| `toAccount` | string | Yes | Destination account wallet name |
| `unit` | string | Yes | Currency unit to transfer (e.g., `XBT`, `USD`) |
| `amount` | number | Yes | Amount to transfer |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

```bash
curl -X POST "https://futures.kraken.com/derivatives/api/v3/transfer" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "fromAccount=fi_xbtusd&toAccount=cash&unit=XBT&amount=0.5"
```

## Example Response

```json
{
  "result": "success"
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 400 | Bad request - invalid parameters, insufficient balance, or incompatible account types |
| 401 | Unauthorized - invalid or missing API credentials |
| 500 | Internal server error |

## Notes

- Wallet names can be found within the `accounts` structure returned by the Get Wallets (`GET /accounts`) endpoint.
- Transfers between margin accounts are only possible when both accounts share the same collateral currency.
- Transfers are processed immediately and are not subject to blockchain confirmation times.
- Related endpoints: Sub Account Transfer (`POST /transfer/subaccount`), Withdrawal (`POST /withdrawal`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/transfer)
