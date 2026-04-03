# Challenge

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/challenge

## Overview

This request returns a challenge to be used in the handshake for user authentication. The challenge must be signed with the user's API secret and then included in subscription requests for authenticated feeds (such as `open_orders`, `fills`, `open_positions`, `balances`, `account_log`, and `notifications_auth`).

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Event:** `challenge`

## Authentication

The challenge mechanism is part of the initial authentication handshake. Users must:

1. Submit an API key with the challenge request
2. Receive a challenge message (UUID) from the server
3. Sign the returned message with their API secret
4. Use the original and signed challenge in subsequent authenticated subscriptions

## Request Format

```json
{
  "event": "challenge",
  "api_key": "CMl2SeSn09Tz+2tWuzPfdaJdsahq6qv5UaexXuQ3SnahDQU/gO3aT+"
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | The request event type: `challenge` |
| api_key | string | Yes | The user API key |

## Response Format

```json
{
  "event": "challenge",
  "message": "226aee50-88fc-4618-a42a-34f7709570b2"
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| event | string | Always `challenge` |
| message | string | The challenge message (UUID) that the user must sign for authentication |

## Authentication Flow

1. Connect to `wss://futures.kraken.com/ws/v1`
2. Send a `challenge` request with your `api_key`
3. Receive the challenge `message` (UUID)
4. Sign the message using your API secret (HMAC-SHA512)
5. Include `api_key`, `original_challenge`, and `signed_challenge` in authenticated feed subscriptions

## Error Response

```json
{
  "event": "error",
  "message": "Json Error"
}
```

### Error Messages

- `Json Error`
