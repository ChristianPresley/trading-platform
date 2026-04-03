# Get Withdrawal Addresses

> Source: https://docs.kraken.com/api/docs/rest-api/get-withdrawal-addresses

## Endpoint
`POST /0/private/WithdrawAddresses`

## Description
Retrieve a list of withdrawal addresses available for the user.

## Authentication
Requires a valid API key with one of the following permissions:
- `Funds permissions - Query`
- `Funds permissions - Withdraw`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | No | Filter by asset (e.g., `XBT`, `ETH`). If omitted, addresses for all assets are returned. |
| `aclass` | string | No | Asset class. Default: `currency`. |
| `method` | string | No | Filter by withdrawal method name. |
| `key` | string | No | Filter by withdrawal key/address name (the label set by the user in the Kraken UI). |
| `verified` | boolean | No | If `true`, only return verified addresses. Default: `false`. |

## Response Fields

The response `result` is an array of withdrawal address objects.

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | array of objects | Array of withdrawal address objects. |
| `result[].address` | string | The withdrawal address. |
| `result[].asset` | string | Asset name (e.g., `XXBT`). |
| `result[].method` | string | Withdrawal method name. |
| `result[].key` | string | User-assigned label/name for the address. |
| `result[].memo` | string | Memo/tag associated with the address (if applicable). |
| `result[].verified` | boolean | Whether the address is verified. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/WithdrawAddresses" \
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
      "address": "bc1qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "asset": "XXBT",
      "method": "Bitcoin",
      "key": "My Bitcoin Wallet",
      "memo": "",
      "verified": true
    }
  ]
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Withdrawal addresses must be pre-configured in the Kraken account before they can be used for withdrawals.
- The `key` field is the user-assigned label for the withdrawal address, set via the Kraken web interface.
- The `verified` field indicates whether the address has been verified (some assets/amounts require address verification).
- For assets requiring a memo/tag (e.g., XRP, XLM), the `memo` field will contain the required tag.
