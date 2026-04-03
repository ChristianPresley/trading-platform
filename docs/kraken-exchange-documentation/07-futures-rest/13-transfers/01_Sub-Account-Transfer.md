# Initiate Sub Account Transfer

## Endpoint

```
POST /transfer/subaccount
```

## Description

Allows transferring funds between the current account and a sub account, between two margin accounts with the same collateral currency, or between a margin account and your cash account. This provides fund management capabilities across the master/subaccount hierarchy.

## Authentication

Requires API key authentication with Futures trading and withdrawal permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `fromAccount` | string | Yes | Source account wallet name |
| `fromUser` | string | Yes | Source account UID (master or subaccount UID) |
| `toAccount` | string | Yes | Destination account wallet name |
| `toUser` | string | Yes | Destination account UID (master or subaccount UID) |
| `unit` | string | Yes | Currency unit to transfer (e.g., `XBT`, `USD`) |
| `amount` | number | Yes | Amount to transfer |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

```bash
curl -X POST "https://futures.kraken.com/derivatives/api/v3/transfer/subaccount" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "fromAccount=cash&fromUser=master-uid&toAccount=cash&toUser=subaccount-uid&unit=XBT&amount=1.0"
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
| 400 | Bad request - invalid parameters, insufficient balance, or incompatible accounts |
| 401 | Unauthorized - invalid or missing API credentials |
| 404 | Account or subaccount not found |
| 500 | Internal server error |

## Notes

- This endpoint is only available for master accounts with subaccount functionality enabled.
- Transfers between margin accounts require the same collateral currency on both sides.
- Transfers are processed immediately within the Kraken Futures platform.
- Use `GET /subaccounts` to retrieve the UIDs of available subaccounts.
- Related endpoints: Wallet Transfer (`POST /transfer`), Withdrawal (`POST /withdrawal`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/sub-account-transfer)
