# Get Deposit Addresses

> Source: https://docs.kraken.com/api/docs/rest-api/get-deposit-addresses

## Endpoint
`POST /0/private/DepositAddresses`

## Description
Retrieve (or generate a new) deposit addresses for a particular asset and method.

## Authentication
Requires a valid API key with the following permission:
- `Funds permissions - Query`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | Yes | Asset being deposited (e.g., `XBT`, `ETH`, `USD`). |
| `method` | string | Yes | Name of the deposit method (as returned by `DepositMethods`). |
| `new` | boolean | No | If `true`, generate a new deposit address. Default: `false`. |
| `amount` | string | No | Amount you wish to deposit (only required for certain methods). |

## Response Fields

The response `result` is an array of deposit address objects.

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | array of objects | Array of deposit address objects. |
| `result[].address` | string | Deposit address. |
| `result[].expiretm` | string | Expiration time for the address as a UNIX timestamp. `0` if no expiration. |
| `result[].new` | boolean | Whether the address has been used before. `true` if freshly generated. |
| `result[].tag` | string | Memo/tag for the deposit address (for assets that require one, e.g., XRP, XLM). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/DepositAddresses" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&asset=XBT&method=Bitcoin"
```

## Example Response

```json
{
  "error": [],
  "result": [
    {
      "address": "bc1qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "expiretm": "0",
      "new": true
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
| `EFunding:Invalid deposit method` | The specified deposit method is not valid for this asset. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Some assets require a tag/memo in addition to the address (e.g., XRP, XLM, ATOM). The `tag` field will be present in the response for such assets.
- Setting `new` to `true` will generate a fresh deposit address. Previously generated addresses remain valid.
- The `expiretm` field is typically `0` for most cryptocurrency addresses (no expiration).
- The `method` parameter must match one of the method names returned by the `DepositMethods` endpoint.
- Some deposit methods may require an `amount` parameter to generate the address.
