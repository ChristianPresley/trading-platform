# Get Status of Recent Deposits

> Source: https://docs.kraken.com/api/docs/rest-api/get-status-recent-deposits

## Endpoint
`POST /0/private/DepositStatus`

## Description
Retrieve information about recent deposits. Results are sorted by recency. Use the `cursor` parameter to iterate through the list of deposits (page size equal to value of `limit`) from newest to oldest.

## Authentication
Requires a valid API key with the following permission:
- `Funds permissions - Query`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | No | Filter deposits by asset (e.g., `XBT`, `ETH`). If omitted, all assets are returned. |
| `method` | string | No | Filter deposits by deposit method name. |
| `start` | string | No | Start timestamp (UNIX timestamp or RFC3339) to filter results. Only deposits after this time are returned. |
| `end` | string | No | End timestamp (UNIX timestamp or RFC3339) to filter results. Only deposits before this time are returned. |
| `cursor` | string/boolean | No | Cursor for pagination. Use `true` for the first page, then use the `next_cursor` value from the response for subsequent pages. |
| `limit` | integer | No | Number of results per page. Default: 25. Maximum: 50. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | array of objects | Array of deposit status objects (when `cursor` is not used). |
| `result.deposit` | array of objects | Array of deposit status objects (when `cursor` is used). |
| `result.next_cursor` | string | Cursor value for the next page of results (when `cursor` is used). |
| `result[].method` | string | Name of the deposit method. |
| `result[].aclass` | string | Asset class (e.g., `currency`). |
| `result[].asset` | string | Asset name (e.g., `XXBT`, `XETH`). |
| `result[].refid` | string | Reference ID for the deposit. |
| `result[].txid` | string | Transaction ID (blockchain hash for crypto deposits). |
| `result[].info` | string | Deposit address or transaction info. |
| `result[].amount` | string | Amount deposited. |
| `result[].fee` | string | Fee paid for the deposit. |
| `result[].time` | integer | UNIX timestamp of when the deposit was initiated. |
| `result[].status` | string | Status of the deposit. See status values below. |
| `result[].status-prop` | string | Additional status properties (e.g., `return` for returned deposits, `onhold`). |
| `result[].originators` | array of strings | Originator addresses (for certain deposit types). |

### Deposit Status Values

| Status | Description |
|--------|-------------|
| `Initial` | Deposit initiated but not yet confirmed. |
| `Pending` | Deposit is pending confirmation. |
| `Settled` | Deposit has been settled/completed. |
| `Success` | Deposit completed successfully. |
| `Failure` | Deposit failed. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/DepositStatus" \
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
      "refid": "QGBCOYA-XZGI4A-EPMQNL",
      "txid": "6544b41b607d8b2512baf801755a3a87b6a9b0199b07dab46a64e67302f92765",
      "info": "bc1qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
      "amount": "0.72485000",
      "fee": "0.0000000000",
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
- The `status-prop` field provides additional context about the deposit status (e.g., `return` indicates the deposit was returned, `onhold` indicates it is on hold pending review).
- The `txid` field contains the blockchain transaction hash for cryptocurrency deposits.
- Fiat deposits will have different `info` and `txid` formats compared to crypto deposits.
