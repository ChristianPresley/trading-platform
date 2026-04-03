# Get Withdrawal Methods

> Source: https://docs.kraken.com/api/docs/rest-api/get-withdrawal-methods

## Endpoint
`POST /0/private/WithdrawMethods`

## Description
Retrieve a list of withdrawal methods available for the user.

## Authentication
Requires a valid API key with one of the following permissions:
- `Funds permissions - Query`
- `Funds permissions - Withdraw`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | No | Filter by asset (e.g., `XBT`, `ETH`, `USD`). If omitted, methods for all assets are returned. |
| `aclass` | string | No | Asset class. Default: `currency`. |
| `network` | string | No | Filter by network (e.g., `Bitcoin`, `Ethereum`, `Polygon`). |

## Response Fields

The response `result` is an array of withdrawal method objects.

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | array of objects | Array of withdrawal method objects. |
| `result[].asset` | string | Asset name (e.g., `XXBT`, `ZUSD`). |
| `result[].method` | string | Withdrawal method name (e.g., `Bitcoin`, `Ether`, `Bank Frick (SEN)`). |
| `result[].network` | string | Network name (e.g., `Bitcoin`, `Ethereum`). |
| `result[].minimum` | string | Minimum withdrawal amount. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/WithdrawMethods" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&asset=XBT"
```

## Example Response

```json
{
  "error": [],
  "result": [
    {
      "asset": "XXBT",
      "method": "Bitcoin",
      "network": "Bitcoin",
      "minimum": "0.00050000"
    },
    {
      "asset": "XXBT",
      "method": "Bitcoin Lightning",
      "network": "Lightning",
      "minimum": "0.00010000"
    }
  ]
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EFunding:Unknown asset` | The specified asset is not recognized. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Different assets may have multiple withdrawal methods available (e.g., Bitcoin on-chain vs. Lightning).
- The `minimum` field indicates the smallest withdrawal amount accepted for each method.
- Withdrawal methods may vary based on account verification tier and geographic location.
