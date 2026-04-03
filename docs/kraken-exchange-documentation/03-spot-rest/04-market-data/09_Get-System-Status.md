# Get System Status

> Source: https://docs.kraken.com/api/docs/rest-api/get-system-status

## Endpoint

`GET https://api.kraken.com/0/public/SystemStatus`

## Description

Get the current system status or trading mode.

## Authentication

None required. This is a public endpoint.

## Request Parameters

None.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | string[] | Array of error messages. Empty on success. |
| `result` | object | Result object containing system status data |
| `result.status` | string | Current system status. See possible values below. |
| `result.timestamp` | string | Current timestamp (RFC3339) |

### System Status Values

| Value | Description |
|-------|-------------|
| `online` | Kraken is operating normally. All order types may be submitted and trades can occur. |
| `maintenance` | The exchange is offline. No new orders or cancellations may be submitted. |
| `cancel_only` | Resting (open) orders can be cancelled but no new orders may be submitted. No trades will occur. |
| `post_only` | Only post-only limit orders can be submitted. Existing orders may still be cancelled. No trades will occur. |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/public/SystemStatus' \
  -H 'Accept: application/json'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "status": "online",
    "timestamp": "2023-07-06T18:51:00Z"
  }
}
```

## Notes

- This endpoint can be used to check if the exchange is operational before submitting orders.
- This is a public endpoint and does not require authentication.
- During maintenance windows, the status will change from `online` to `maintenance`.
- Transitions through `cancel_only` and `post_only` may occur during planned maintenance events.
