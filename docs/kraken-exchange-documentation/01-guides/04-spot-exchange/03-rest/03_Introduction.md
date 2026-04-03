# Spot REST Introduction

> Source: https://docs.kraken.com/api/docs/guides/spot-rest-intro

## API Organization

The Spot REST API is organised by function, covering a wide range of services including:

- Market Data
- Account Data
- Trading
- Funding
- Subaccounts
- Earn
- Websocket Authentication

## Request and Response Handling

### Request Format

The API accepts Json encoding (`Content-Type: application/json`) as well as form-encoded (`Content-Type: application/x-www-form-urlencoded`). Kraken recommends that clients include `User-Agent` headers in requests to help optimize interactions.

### Response Structure

Responses come in JSON format with either `result` and `error` keys for successful requests, or solely an `error` key for failures.

**Example Successful Response:**

```json
{
    "error": [],
    "result": {
        "status": "online",
        "timestamp": "2021-03-22T17:18:03Z"
    }
}
```

**Example Error Response:**

```json
{
    "error": [
        "EGeneral:Invalid arguments:ordertype"
    ]
}
```

### Error Message Format

Error messages follow the pattern: `<severity><category>: <description>` where:

- Severity uses `E` for errors or `W` for warnings
- Categories include General, Auth, API, Query, Order, Trade, Funding, or Service
- Descriptions explain the issue

Additional details are available through Kraken's support documentation on API error messages.
