# Get Trigger Events

Source: [https://docs.kraken.com/api/docs/futures-api/history/get-trigger-events](https://docs.kraken.com/api/docs/futures-api/history/get-trigger-events)

## Endpoint

```
GET /api/history/v2/triggers
```

**Full URL:** `https://futures.kraken.com/api/history/v2/triggers`

## Description

Lists trigger events for the authenticated account, including stop orders, take profit orders, and trailing stop triggers. Returns paginated results with a `continuationToken` that can be used to request additional data.

## Authentication

This endpoint requires authentication.

**Required Headers:**

| Header | Description |
|--------|-------------|
| `APIKey` | Your Kraken Futures API public key |
| `Authent` | Authentication signature (HMAC-SHA512) |
| `Nonce` | A unique, incrementing value for each request (optional) |

**Required Permission:** `General API - Read Only` (minimum)

## Request Parameters

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `before` | integer | No | Filter to only return results before a specific timestamp (epoch milliseconds) |
| `since` | integer | No | Filter by specifying a start point (epoch milliseconds) |
| `continuation_token` | string | No | Token returned from a previous request, used to continue requesting historical events |
| `sort` | string | No | Sort the results. Values: `asc`, `desc` |
| `tradeable` | string | No | Filter results by a specific contract/asset (e.g., `PF_SOLUSD`) |

## Response Fields

### 200 - Success

| Field | Type | Description |
|-------|------|-------------|
| `accountUid` | string (uuid) | The unique identifier of the account |
| `continuationToken` | string | Token to use for requesting the next page of results |
| `elements` | array | Array of trigger event objects |
| `len` | integer | Number of elements returned |
| `serverTime` | string (date-time) | Server time in UTC |

### Element Object

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string (uuid) | Unique identifier of the event |
| `timestamp` | integer | Event timestamp in epoch milliseconds |
| `event` | object | The event data container |

### Event Types

Trigger events can include:

- **OrderTriggerPlaced** - A trigger order was placed or activated

### Event > OrderTriggerPlaced Object

| Field | Type | Description |
|-------|------|-------------|
| `event.OrderTriggerPlaced.order` | object | The trigger order details |
| `event.OrderTriggerPlaced.reason` | string | Reason for the trigger event (e.g., `maxDeviation triggered`) |

### Trigger Order Object

| Field | Type | Description |
|-------|------|-------------|
| `accountId` | number | Account numeric identifier |
| `accountUid` | string (uuid) | Account unique identifier |
| `uid` | string (uuid) | Order unique identifier |
| `tradeable` | string | The contract symbol (e.g., `pi_xbtusd`) |
| `direction` | string | Order direction: `Buy` or `Sell` |
| `quantity` | string | Order quantity |
| `limitPrice` | string | Limit price of the order |
| `orderType` | string | Order type (e.g., `lmt`) |
| `reduceOnly` | boolean | Whether the order is reduce-only |
| `timestamp` | integer | Order timestamp in epoch milliseconds |
| `lastUpdateTimestamp` | integer | Last update timestamp in epoch milliseconds |
| `triggerOptions` | object | Trigger-specific configuration |

### Trigger Options Object

| Field | Type | Description |
|-------|------|-------------|
| `triggerPrice` | string | The price at which the trigger activates |
| `triggerSide` | string | The side of the trigger: `Buy` or `Sell` |
| `triggerSignal` | string | Signal used for trigger: `trade`, `mark`, or `index` |
| `trailingStopOptions` | object | Trailing stop specific options (if applicable) |

### Trailing Stop Options Object

| Field | Type | Description |
|-------|------|-------------|
| `maxDeviation` | string | Maximum deviation value |
| `unit` | string | Unit of deviation: `Percent` or `QuoteCurrency` |

## Example

**Request:**

```
GET https://futures.kraken.com/api/history/v2/triggers?tradeable=PF_SOLUSD&since=1668989233&before=1668999999&sort=asc
```

**Response:**

```json
{
    "accountUid": "f7d5571c-6d10-4cf1-944a-048d25682ed0",
    "continuationToken": "c3RyaW5n",
    "elements": [
        {
            "event": {
                "OrderTriggerPlaced": {
                    "order": {
                        "accountId": 0.0,
                        "accountUid": "f7d5571c-6d10-4cf1-944a-048d25682ed0",
                        "direction": "Buy",
                        "lastUpdateTimestamp": 1605126171852,
                        "limitPrice": "29000.0",
                        "orderType": "lmt",
                        "quantity": "1.0",
                        "reduceOnly": false,
                        "timestamp": 1605126171852,
                        "tradeable": "pi_xbtusd",
                        "triggerOptions": {
                            "trailingStopOptions": {
                                "maxDeviation": "0.1",
                                "unit": "Percent"
                            },
                            "triggerPrice": "29200.0",
                            "triggerSide": "Sell",
                            "triggerSignal": "trade"
                        },
                        "uid": "f7d5571c-6d10-4cf1-944a-048d25682ed0"
                    },
                    "reason": "maxDeviation triggered"
                }
            },
            "timestamp": 1605126171852,
            "uid": "f7d5571c-6d10-4cf1-944a-048d25682ed0"
        }
    ],
    "len": 10,
    "serverTime": "2022-03-31T20:38:53.677Z"
}
```

## Notes

- The `continuationToken` from the response can be passed as `continuation_token` in subsequent requests to paginate through results.
- Timestamps in query parameters are epoch milliseconds.
- The `sort` parameter accepts `asc` (ascending) or `desc` (descending).
- Trigger events cover stop orders, take profit orders, and trailing stop orders.
