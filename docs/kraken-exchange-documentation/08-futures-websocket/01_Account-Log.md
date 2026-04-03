# Account Log

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/account_log

## Overview

This subscription feed publishes account information. It tracks all account activity including trades, funding rate changes, and balance updates with detailed logging.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `account_log`

## Authentication

Required. Uses challenge-response authentication:

- `api_key` -- The user API key
- `original_challenge` -- The message received from a challenge request
- `signed_challenge` -- The challenge message signed with user API secret

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "account_log",
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `account_log` |
| api_key | string | Yes | User API key |
| original_challenge | string | Yes | Message received from challenge request |
| signed_challenge | string | Yes | Challenge signed with API secret |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "account_log",
  "api_key": "CMl2SeSn09Tz+2tWuzPiPUjaXEQRGq6qv5UaexXuQ3SnahDQU/gO3aT+",
  "original_challenge": "226aee50-88fc-4618-a42a-34f7709570b2",
  "signed_challenge": "RE0DVOc7vS6pzcEjGWd/WJRRBWb54RkyvV+AZQSRl4+rap8Rlk64diR+Z9DQILm7qxncswMmJyvP/2vgzqqh+g=="
}
```

## Response/Update Format

Initial snapshot uses feed `account_log_snapshot`, subsequent updates use feed `account_log`.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | Subscribed feed identifier (`account_log_snapshot` or `account_log`) |
| log / logs | array | List of account log entries |

### Log Entry Fields

| Field | Type | Description |
|-------|------|-------------|
| id | positive integer | Log entry identifier |
| date | ISO8601 datetime | Server timestamp of log creation |
| asset | string | Related asset identifier |
| info | string | Booking description (e.g., `futures trade`, `funding rate change`) |
| booking_uid | string | Unique booking identifier |
| margin_account | string | Associated account name |
| old_balance | float | Balance before action |
| new_balance | float | Balance after action |
| old_average_entry_price | positive float | Prior position entry price |
| new_average_entry_price | positive float | Updated position entry price |
| trade_price | positive float | Execution price |
| mark_price | positive float | Mark price at execution |
| realized_pnl | float | Realized profit/loss from position reduction |
| fee | float | Transaction fee paid |
| execution | string | Associated execution UID |
| collateral | string | Currency of entry |
| funding_rate | float | Absolute funding rate value |
| realized_funding | float | Funding realized from position changes |
| conversion_spread_percentage | float | Currency conversion spread percentage |
| liquidation_fee | float | Liquidation fee (not applicable for inverse futures) |

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
