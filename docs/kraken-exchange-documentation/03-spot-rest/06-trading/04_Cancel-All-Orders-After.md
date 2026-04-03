# Cancel All Orders After X

> Source: https://docs.kraken.com/api/docs/rest-api/cancel-all-orders-after

## Endpoint
`POST /0/private/CancelAllOrdersAfter`

## Description
Provides a "Dead Man's Switch" mechanism to protect the client from network/system issues. The client sends a request with a timeout (in seconds), and all open orders will be cancelled if the timer expires without being reset. The client must keep sending requests to push back the timer, or send a timeout of `0` to disable the mechanism.

This is useful for ensuring orders are cancelled in the event of connectivity loss. The recommended usage pattern is to send requests every 15-30 seconds with a 60-second timeout.

## Authentication
Requires a valid API key with one of the following permissions:
- `Orders and trades - Create & modify orders`
- `Orders and trades - Cancel & close orders`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `timeout` | integer | Yes | Duration (in seconds) to set the timer. Set to `0` to disable the dead man's switch. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object (present on success). |
| `result.currentTime` | string | RFC3339 timestamp of the current server time. |
| `result.triggerTime` | string | RFC3339 timestamp when the timer will trigger and cancel all orders. `0` if the timer is disabled. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/CancelAllOrdersAfter" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&timeout=60"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "currentTime": "2021-03-24T17:41:56Z",
    "triggerTime": "2021-03-24T17:42:56Z"
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- This is a "Dead Man's Switch" mechanism. The timer must be continually refreshed; otherwise, all orders will be cancelled when it expires.
- Recommended usage: call every 15-30 seconds with a 60-second timeout.
- Setting `timeout` to `0` disables the dead man's switch.
- The timer should be disabled before scheduled trading engine maintenance windows to avoid unintentional cancellations.
- Each call resets the timer to the new timeout value from the current server time.
- This mechanism applies to all open orders across all trading pairs.
