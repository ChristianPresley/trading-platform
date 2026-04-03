# Get Deallocation Status

> Source: https://docs.kraken.com/api/docs/rest-api/get-deallocate-strategy-status

## Endpoint
`POST /0/private/Earn/DeallocateStatus`

## Description
Retrieve the status of the most recent deallocation request. This endpoint is used to poll for the result of an asynchronous deallocation submitted via `Earn/Deallocate`.

## Authentication
Requires a valid API key with one of the following permissions:
- `Earn Funds`
- `Query Funds`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `strategy_id` | string | Yes | The ID of the earn strategy to check deallocation status for. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Status result object. |
| `result.pending` | boolean | `true` if the deallocation is still being processed; `false` if it has completed (or no pending deallocation). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/Earn/DeallocateStatus" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&strategy_id=ESXUM7H-SJHQ6-KOQNNI"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "pending": false
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EEarn:Invalid strategy ID` | The specified strategy ID is not valid. |
| `EFunding:Insufficient funds` | The deallocation failed because there are insufficient allocated funds. |
| `EEarn:Below min` | The deallocation failed because the amount was below the minimum. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Operations are asynchronous; this endpoint checks the progress of a previously submitted deallocation request.
- Only one active allocation/deallocation per user and strategy is permitted at a time.
- A `pending` value of `true` means the deallocation is still being processed.
- A `pending` value of `false` means the deallocation has completed (or there is no pending deallocation).
- If the original deallocation request failed asynchronously, this endpoint will return the HTTP error that would have occurred during the original submission.
