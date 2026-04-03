# Initiate Withdrawal to Spot Wallet

## Endpoint

```
POST /withdrawal
```

## Description

Initiates a withdrawal of digital assets from the Kraken Futures platform to the user's Kraken Spot wallet. This moves funds from Futures back to the Spot exchange.

## Authentication

Requires API key authentication with Futures trading and withdrawal permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `amount` | number | Yes | Amount to withdraw |
| `unit` | string | Yes | Currency unit to withdraw (e.g., `XBT`, `ETH`, `USD`) |
| `sourceAccount` | string | Yes | The Futures wallet name to withdraw from |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

```bash
curl -X POST "https://futures.kraken.com/derivatives/api/v3/withdrawal" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "amount=0.5&unit=XBT&sourceAccount=cash"
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
| 400 | Bad request - invalid parameters or insufficient balance |
| 401 | Unauthorized - invalid or missing API credentials |
| 500 | Internal server error |

## Notes

- Wallet names can be located within the `accounts` structure returned by the Get Wallets (`GET /accounts`) endpoint.
- Withdrawals are sent to the linked Kraken Spot wallet. This is an internal transfer within the Kraken ecosystem, not an on-chain withdrawal.
- Processing times may vary but are typically near-instant for internal transfers.
- Related endpoints: Wallet Transfer (`POST /transfer`), Sub Account Transfer (`POST /transfer/subaccount`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/withdrawal)
