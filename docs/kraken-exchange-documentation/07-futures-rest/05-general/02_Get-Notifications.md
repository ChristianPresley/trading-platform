# Get Notifications

## Endpoint

```
GET /notifications
```

## Description

Returns the platform's notifications. This endpoint provides system-level notifications from the Kraken Futures platform, such as maintenance windows, new feature announcements, or important trading updates.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `notifications` | array | List of notification objects |
| `notifications[].type` | string | Type/category of the notification |
| `notifications[].priority` | string | Priority level of the notification |
| `notifications[].note` | string | The notification message content |
| `notifications[].effectiveTime` | string | ISO 8601 timestamp when the notification takes effect |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/notifications" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "notifications": [
    {
      "type": "general",
      "priority": "low",
      "note": "Scheduled maintenance window on 2024-02-01 from 00:00 to 02:00 UTC",
      "effectiveTime": "2024-02-01T00:00:00.000Z"
    }
  ]
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 401 | Unauthorized - invalid or missing API credentials |
| 500 | Internal server error |

## Notes

- Notifications are platform-wide and not specific to a particular trading pair or account.
- Poll this endpoint periodically to stay informed about platform changes that may affect trading operations.
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-notifications)
