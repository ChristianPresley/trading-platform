# Get Public Order Events

Source: [https://docs.kraken.com/api/docs/futures-api/history/get-public-order-events](https://docs.kraken.com/api/docs/futures-api/history/get-public-order-events)

## Endpoint

```
GET /api/history/v2/market/{tradeable}/orders
```

**Full URL:** `https://futures.kraken.com/api/history/v2/market/{tradeable}/orders`

## Description

Lists order events for a specific market, including order placements, cancellations, and fills. This is a public endpoint that returns order event data without requiring authentication. Returns paginated results with a `continuationToken` that can be used to request additional data.

## Authentication

This is a **public** endpoint. No authentication is required.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tradeable` | string | Yes | The contract symbol to query (e.g., `PI_XBTUSD`) |

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `before` | integer | No | Filter to only return results before a specific timestamp (epoch milliseconds) |
| `since` | integer | No | Filter by specifying a start point (epoch milliseconds) |
| `continuation_token` | string | No | Token returned from a previous request, used to continue requesting historical events |
| `sort` | string | No | Sort the results. Values: `asc`, `desc` |

## Response Fields

### 200 - Success

| Field | Type | Description |
|-------|------|-------------|
| `elements` | array | Array of public order event objects |
| `len` | integer | Number of elements returned |
| `continuationToken` | string | Token to use for requesting the next page of results |

### Element Object

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string (uuid) | Unique identifier of the event |
| `timestamp` | integer | Event timestamp in epoch milliseconds |
| `event` | object | The event data container |

### Event Types

Public order events can be one of several types:

- **OrderPlaced** - A new order was placed on the book
- **OrderCancelled** - An order was removed from the book
- **OrderFilled** - An order was completely filled
- **OrderUpdated** - An order was modified

### Event > OrderPlaced Object

| Field | Type | Description |
|-------|------|-------------|
| `event.OrderPlaced.order` | object | The order details |
| `event.OrderPlaced.reason` | string | Reason for the event (e.g., `new_user_order`) |
| `event.OrderPlaced.reducedQuantity` | string | Quantity that was reduced |

### Public Order Object

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string (uuid) | Order unique identifier |
| `tradeable` | string | The contract symbol (e.g., `PI_XBTUSD`) |
| `direction` | string | Order direction: `Buy` or `Sell` |
| `quantity` | string | Order quantity |
| `limitPrice` | string | Limit price of the order |
| `orderType` | string | Order type (e.g., `Post`, `IoC`, `lmt`) |
| `reduceOnly` | boolean | Whether the order is reduce-only |
| `timestamp` | integer | Order timestamp in epoch milliseconds |
| `lastUpdateTimestamp` | integer | Last update timestamp in epoch milliseconds |

## Example

**Request:**

```
GET https://futures.kraken.com/api/history/v2/market/PI_XBTUSD/orders
```

**Response:**

```json
{
    "elements": [
        {
            "uid": "430782d7-7b6d-472a-9e92-67047289d742",
            "timestamp": 1680875125649,
            "event": {
                "OrderPlaced": {
                    "order": {
                        "uid": "f9aaf471-95ba-4fde-ab68-251f12f96e47",
                        "tradeable": "PI_XBTUSD",
                        "direction": "Sell",
                        "quantity": "652",
                        "timestamp": 1680875125649,
                        "limitPrice": "27927.5",
                        "orderType": "Post",
                        "reduceOnly": false,
                        "lastUpdateTimestamp": 1680875125649
                    },
                    "reason": "new_user_order",
                    "reducedQuantity": ""
                }
            }
        }
    ],
    "len": 1000,
    "continuationToken": "MTY4MDg3NTExMzc2OS85MDY2NDA1ODIyNw=="
}
```

## Notes

- Unlike the private order events endpoint, this endpoint does not include `accountUid` or `serverTime` in the response.
- Public order events do not include account-specific identifiers in the order objects.
- The default number of results per page is 1000.
- The `continuationToken` from the response can be passed as `continuation_token` in subsequent requests to paginate through results.
