# Get Deposit Methods

> Source: https://docs.kraken.com/api/docs/rest-api/get-deposit-methods

## Endpoint
`POST /0/private/DepositMethods`

## Description
Retrieve methods available for depositing a particular asset.

## Authentication
Requires a valid API key with one of the following permissions:
- `Funds permissions - Query`
- `Funds permissions - Deposit`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | Yes | Asset being deposited (e.g., `XBT`, `ETH`, `USD`). |

## Response Fields

The response `result` is an array of deposit method objects.

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | array of objects | Array of deposit method objects. |
| `result[].method` | string | Name of deposit method (e.g., `Bitcoin`, `Ether (Hex)`, `Bank Frick (SEN)`). |
| `result[].limit` | string/boolean | Maximum net amount that can be deposited right now, or `false` if no limit. |
| `result[].fee` | string | Amount of fees that will be paid. |
| `result[].gen-address` | boolean | Whether the method has an address setup fee. `true` if a new address needs to be generated. |
| `result[].minimum` | string | Minimum deposit amount for this method. |
| `result[].address-setup-fee` | string | Fee for generating a new deposit address (if applicable). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/DepositMethods" \
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
      "method": "Bitcoin",
      "limit": false,
      "fee": "0.0000000000",
      "gen-address": true,
      "minimum": "0.00010000"
    },
    {
      "method": "Bitcoin Lightning",
      "limit": "0.10000000",
      "fee": "0.0000000000",
      "gen-address": true,
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

- The `limit` field shows the maximum amount that can be deposited right now, considering any account limits. `false` means there is no limit.
- Different assets may have different deposit methods available (e.g., Bitcoin has on-chain and Lightning options).
- The `minimum` field indicates the smallest deposit amount accepted for each method.
- The `gen-address` field indicates whether the method requires generating a deposit address before use.
