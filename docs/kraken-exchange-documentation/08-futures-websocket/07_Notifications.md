# Notifications

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/notifications

## Overview

This subscription feed publishes notifications to the client, including market announcements, maintenance windows, new features, bug fixes, and settlement notices.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `notifications_auth`

## Authentication

Required. Uses challenge-response authentication:

- `api_key` -- The user API key
- `original_challenge` -- The challenge UUID received from a challenge request
- `signed_challenge` -- HMAC-signed challenge with API secret

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "notifications_auth",
  "api_key": "string",
  "original_challenge": "string",
  "signed_challenge": "string"
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | Must be `notifications_auth` |
| api_key | string | Yes | User API key credential |
| original_challenge | string | Yes | Challenge UUID from challenge request |
| signed_challenge | string | Yes | HMAC-signed challenge with API secret |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "notifications_auth",
  "api_key": "string",
  "original_challenge": "string",
  "signed_challenge": "string"
}
```

## Response/Update Format

```json
{
  "feed": "notifications_auth",
  "notifications": [
    {
      "id": 5,
      "type": "market",
      "priority": "low",
      "note": "string",
      "effective_time": 1520288300000,
      "expected_downtime_minutes": null
    }
  ]
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | Returns `notifications_auth` |
| notifications | array | List of notification objects |
| id | integer | Unique notification identifier |
| type | string | Category: `market`, `general`, `new_feature`, `bug_fix`, `maintenance`, `settlement` |
| priority | string | Severity: `low`, `medium`, `high` (high implies downtime for maintenance) |
| note | string | A short description about the specific notification |
| effective_time | positive integer | Unix timestamp (milliseconds) of notification activation |
| expected_downtime_minutes | integer | Duration of expected outage (null if no outage anticipated) |

## Notes

- High-priority maintenance notifications indicate scheduled downtime
- `expected_downtime_minutes` is omitted/null if no outage is anticipated

## Error Response

```json
{
  "event": "error",
  "message": "Invalid feed"
}
```

### Error Messages

- `Invalid feed`
- `Json Error`
