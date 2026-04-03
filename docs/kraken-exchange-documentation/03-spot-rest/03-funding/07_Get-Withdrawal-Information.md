# Get Withdrawal Information

> Source: https://docs.kraken.com/api/docs/rest-api/get-withdrawal-information

## Endpoint
`POST /0/private/WithdrawInfo`

## Description
Retrieve fee information about potential withdrawals for a particular asset, key, and amount.

## Authentication
Requires a valid API key with one of the following permissions:
- `Funds permissions - Query`
- `Funds permissions - Withdraw`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | Yes | Asset being withdrawn (e.g., `XBT`, `ETH`, `USD`). |
| `key` | string | Yes | Withdrawal key name (the label of the pre-configured withdrawal address). |
| `amount` | string | Yes | Amount to be withdrawn. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Withdrawal information object. |
| `result.method` | string | Name of the withdrawal method that will be used. |
| `result.limit` | string | Maximum amount available to withdraw. |
| `result.amount` | string | Net amount that will be sent after fees. |
| `result.fee` | string | Amount of fee that will be paid. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/WithdrawInfo" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&asset=XBT&key=My Bitcoin Wallet&amount=0.5"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "method": "Bitcoin",
    "limit": "5.00000000",
    "amount": "0.49975000",
    "fee": "0.00025000"
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EFunding:Unknown asset` | The specified asset is not recognized. |
| `EFunding:Unknown withdraw key` | The specified withdrawal key name is not found. |
| `EFunding:Insufficient funds` | The requested withdrawal amount exceeds available balance. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Use this endpoint to check withdrawal fees and limits before submitting a withdrawal request.
- The `key` parameter must match the exact name/label of a pre-configured withdrawal address.
- The `limit` field shows the maximum amount available for withdrawal, considering account balance and any withdrawal limits.
- The `amount` field in the response is the net amount after deducting the `fee`.
- This endpoint does not initiate a withdrawal; it only provides information. Use the `Withdraw` endpoint to actually withdraw funds.
