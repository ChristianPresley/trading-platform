# Withdraw Funds

> Source: https://docs.kraken.com/api/docs/rest-api/withdraw-funds

## Endpoint
`POST /0/private/Withdraw`

## Description
Make a withdrawal request.

## Authentication
Requires a valid API key with the following permission:
- `Funds permissions - Withdraw`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | Yes | Asset being withdrawn (e.g., `XBT`, `ETH`, `USD`). |
| `key` | string | Yes | Withdrawal key name (the label of the pre-configured withdrawal address, as set in the Kraken UI). |
| `amount` | string | Yes | Amount to be withdrawn. |
| `address` | string | No | Cryptocurrency address to withdraw to (can be used instead of `key` for crypto withdrawals). |
| `max_fee` | string | No | Maximum fee willing to pay. If the actual fee exceeds this, the withdrawal will not proceed. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Withdrawal result object. |
| `result.refid` | string | Reference ID for the withdrawal request. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/Withdraw" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&asset=XBT&key=My Bitcoin Wallet&amount=0.5"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "refid": "AGBSO6T-UFMTTQ-I7KGS6"
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
| `EFunding:Insufficient funds` | Insufficient balance for the withdrawal. |
| `EFunding:Too small` | Withdrawal amount is below the minimum. |
| `EFunding:Limit exceeded` | Withdrawal limit exceeded. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Withdrawal addresses must be pre-configured in the Kraken account settings before use with the `key` parameter.
- The `refid` in the response can be used to track the withdrawal status via the `WithdrawStatus` endpoint.
- Withdrawals are subject to processing times which vary by asset and method.
- Some withdrawals may require additional confirmation (e.g., email confirmation) depending on account security settings.
- The `max_fee` parameter allows you to set a fee ceiling; if the network fee exceeds this amount, the withdrawal will be rejected rather than overpaying.
- Fiat withdrawals may have additional processing delays and requirements.
