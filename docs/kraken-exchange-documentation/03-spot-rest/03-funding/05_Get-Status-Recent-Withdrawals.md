# Get Status of Recent Withdrawals

> Source: https://docs.kraken.com/api/docs/rest-api/get-status-recent-withdrawals

## Endpoint
`POST /0/private/WithdrawStatus`

## Description
Retrieve information about recent withdrawals. Results are sorted by recency. Use the `cursor` parameter to iterate through the list of withdrawals (page size equal to value of `limit`) from newest to oldest.

## Authentication
Requires a valid API key with one of the following permissions:
- `Funds permissions - Withdraw`
- `Data - Query ledger entries`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | No | Filter withdrawals by asset (e.g., `XBT`, `ETH`). If omitted, all assets are returned. |
| `method` | string | No | Filter withdrawals by withdrawal method name. |
| `start` | string | No | Start timestamp (UNIX timestamp or RFC3339) to filter results. |
| `end` | string | No | End timestamp (UNIX timestamp or RFC3339) to filter results. |
| `cursor` | string/boolean | No | Cursor for pagination. Use `true` for the first page, then use the `next_cursor` value from the response for subsequent pages. |
| `limit` | integer | No | Number of results per page. Default: 25. Maximum: 50. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | array of objects | Array of withdrawal status objects (when `cursor` is not used). |
| `result.withdrawal` | array of objects | Array of withdrawal status objects (when `cursor` is used). |
| `result.next_cursor` | string | Cursor value for the next page of results (when `cursor` is used). |
| `result[].method` | string | Name of the withdrawal method used. |
| `result[].aclass` | string | Asset class (e.g., `currency`). |
| `result[].asset` | string | Asset name (e.g., `XXBT`, `XETH`). |
| `result[].refid` | string | Reference ID for the withdrawal. |
| `result[].txid` | string | Transaction ID (blockchain hash for crypto withdrawals). |
| `result[].info` | string | Withdrawal address or transaction info. |
| `result[].amount` | string | Amount withdrawn. |
| `result[].fee` | string | Fee paid for the withdrawal. |
| `result[].time` | integer | UNIX timestamp of when the withdrawal was requested. |
| `result[].status` | string | Status of the withdrawal. See status values below. |
| `result[].status-prop` | string | Additional status properties (e.g., `cancel-pending`, `canceled`, `cancel-denied`, `return`, `onhold`). |
| `result[].key` | string | Withdrawal key name used. |

### Withdrawal Status Values

| Status | Description |
|--------|-------------|
| `Initial` | Withdrawal initiated but not yet processed. |
| `Pending` | Withdrawal is pending processing. |
| `Settled` | Withdrawal has been settled/completed. |
| `Success` | Withdrawal completed successfully. |
| `Failure` | Withdrawal failed. |
| `Cancel pending` | Cancellation has been requested and is pending. |
| `Canceled` | Withdrawal has been cancelled. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/WithdrawStatus" \
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
      "aclass": "currency",
      "asset": "XXBT",
      "refid": "AGBSO6T-UFMTTQ-I7KGS6",
      "txid": "6544b41b607d8b2512baf801755a3a87b6a9b0199b07dab46a64e67302f92765",
      "info": "bc1qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "amount": "0.49975000",
      "fee": "0.00025000",
      "time": 1617014586,
      "status": "Success",
      "status-prop": ""
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

- Results are sorted from newest to oldest.
- Use pagination with `cursor` and `limit` for large result sets.
- The `status-prop` field provides additional context (e.g., `cancel-pending` means a cancellation has been requested, `onhold` means the withdrawal is held for review).
- The `txid` field contains the blockchain transaction hash for cryptocurrency withdrawals.
- The `refid` is the Kraken internal reference ID, which can be used with the `WithdrawCancel` endpoint.
