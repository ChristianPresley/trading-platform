# Request Wallet Transfer

> Source: https://docs.kraken.com/api/docs/rest-api/wallet-transfer

## Endpoint
`POST /0/private/WalletTransfer`

## Description
Transfer funds from a Kraken spot wallet to a Kraken Futures wallet. Note that a transfer from the Futures wallet to the spot wallet must be requested via the Futures API withdrawal-to-spot endpoint.

## Authentication
Requires a valid API key with the following permission:
- `Funds permissions - Query`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | Yes | Asset to transfer (e.g., `XBT`, `ETH`, `USD`). |
| `from` | string | Yes | Source wallet. Value: `Spot` (for transferring from spot wallet). |
| `to` | string | Yes | Destination wallet. Value: `Futures` (for transferring to futures wallet). |
| `amount` | string | Yes | Amount to transfer. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Transfer result object. |
| `result.refid` | string | Reference ID for the transfer. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/WalletTransfer" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&asset=XBT&from=Spot&to=Futures&amount=1.0"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "refid": "BOG5AE6-KMPKM-7YFVHJ"
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EFunding:Unknown asset` | The specified asset is not recognized. |
| `EFunding:Insufficient funds` | Insufficient balance for the transfer. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- This endpoint only supports transfers from the Spot wallet to the Futures wallet.
- To transfer from Futures back to Spot, use the Kraken Futures API's withdrawal-to-spot endpoint.
- The transfer is typically processed immediately (internal transfer).
- The `refid` can be used to track the transfer via the `WithdrawStatus` endpoint.
- Wallet transfers can be cancelled via `WithdrawCancel` without requiring `Funds permissions - Withdraw`.
