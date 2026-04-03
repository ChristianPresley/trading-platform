# Get Order Events

Source: [https://docs.kraken.com/api/docs/futures-api/history/get-order-events](https://docs.kraken.com/api/docs/futures-api/history/get-order-events)

## Endpoint

```
GET /api/history/v2/orders
```

**Full URL:** `https://futures.kraken.com/api/history/v2/orders`

## Description

Lists order events for the authenticated account, including order placements, cancellations, fills, and other order lifecycle events. Returns paginated results with a `continuationToken` that can be used to request additional data.

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
| `elements` | array | Array of order event objects |
| `len` | integer | Number of elements returned |
| `serverTime` | string (date-time) | Server time in UTC |

### Element Object

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string (uuid) | Unique identifier of the event |
| `timestamp` | integer | Event timestamp in epoch milliseconds |
| `event` | object | The event data container |

### Event Types

Order events can be one of several types:

- **OrderPlaced** - A new order was placed
- **OrderCancelled** - An order was cancelled
- **OrderFilled** - An order was completely filled
- **OrderUpdated** - An order was modified

### Event > OrderPlaced Object

| Field | Type | Description |
|-------|------|-------------|
| `event.OrderPlaced.order` | object | The order details |
| `event.OrderPlaced.reason` | string | Reason for the event |
| `event.OrderPlaced.reducedQuantity` | string | Quantity that was reduced |

### Order Object

| Field | Type | Description |
|-------|------|-------------|
| `accountUid` | string (uuid) | Account unique identifier |
| `uid` | string (uuid) | Order unique identifier |
| `tradeable` | string | The contract symbol (e.g., `pi_xbtusd`) |
| `direction` | string | Order direction: `Buy` or `Sell` |
| `quantity` | string | Order quantity |
| `filled` | string | Filled quantity |
| `limitPrice` | string | Limit price of the order |
| `orderType` | string | Order type (e.g., `lmt`, `Post`, `IoC`) |
| `reduceOnly` | boolean | Whether the order is reduce-only |
| `timestamp` | integer | Order timestamp in epoch milliseconds |
| `lastUpdateTimestamp` | integer | Last update timestamp in epoch milliseconds |

## Example

**Request:**

```
GET https://futures.kraken.com/api/history/v2/orders?tradeable=PF_SOLUSD&since=1668989233&before=1668999999&sort=asc
```

**Response:**

```json
{
    "accountUid": "f7d5571c-6d10-4cf1-944a-048d25682ed0",
    "continuationToken": "simb178",
    "elements": [
        {
            "event": {
                "OrderPlaced": {
                    "order": {
                        "accountUid": "f7d5571c-6d10-4cf1-944a-048d25682ed0",
                        "direction": "Sell",
                        "filled": "12.011",
                        "lastUpdateTimestamp": 1605126171852,
                        "limitPrice": "28900.0",
                        "orderType": "string",
                        "quantity": "13.12",
                        "reduceOnly": false,
                        "timestamp": 1605126171852,
                        "tradeable": "pi_xbtusd",
                        "uid": "f7d5571c-6d10-4cf1-944a-048d25682ed0"
                    },
                    "reason": "string",
                    "reducedQuantity": "string"
                }
            },
            "timestamp": 1605126171852,
            "uid": "f7d5571c-6d10-4cf1-944a-048d25682ed0"
        }
    ],
    "len": 10,
    "serverTime": "2023-04-05T12:31:42.677Z"
}
```

## Notes

- The `continuationToken` from the response can be passed as `continuation_token` in subsequent requests to paginate through results.
- Timestamps in query parameters are epoch milliseconds.
- The `sort` parameter accepts `asc` (ascending) or `desc` (descending).
