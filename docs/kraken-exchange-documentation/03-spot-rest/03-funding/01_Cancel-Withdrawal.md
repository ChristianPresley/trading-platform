# Request Withdrawal Cancellation

> Source: https://docs.kraken.com/api/docs/rest-api/cancel-withdrawal

## Endpoint
`POST /0/private/WithdrawCancel`

## Description
Cancel a recently requested withdrawal, if it has not already been successfully processed.

## Authentication
Requires a valid API key with the following permission:
- `Funds permissions - Withdraw`

Exception: WalletTransfer withdrawals require no specific permissions to cancel.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | Yes | Asset being withdrawn (e.g., `XBT`, `ETH`, `USD`). |
| `refid` | string | Yes | Withdrawal reference ID (as returned by the `Withdraw` or `WithdrawStatus` endpoint). |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | boolean | `true` if the cancellation request was successfully submitted. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/WithdrawCancel" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&asset=XBT&refid=AGBSO6T-UFMTTQ-I7KGS6"
```

## Example Response

```json
{
  "error": [],
  "result": true
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EFunding:Unknown reference id` | The specified reference ID is not found. |
| `EFunding:Cancel pending` | A cancellation request is already pending for this withdrawal. |
| `EFunding:Withdraw limit exceeded` | Cannot cancel; withdrawal has already been processed. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Cancellation is only possible if the withdrawal has not already been fully processed and sent.
- Once a cryptocurrency withdrawal has been broadcast to the blockchain, it cannot be cancelled.
- The `refid` parameter must be the Kraken reference ID (not the blockchain transaction ID).
- A successful response indicates the cancellation request was submitted, not necessarily that it was completed. Check `WithdrawStatus` to confirm.
- WalletTransfer type withdrawals can be cancelled without the `Funds permissions - Withdraw` permission.
