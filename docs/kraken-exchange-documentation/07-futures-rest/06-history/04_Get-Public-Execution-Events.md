# Get Public Execution Events

Source: [https://docs.kraken.com/api/docs/futures-api/history/get-public-execution-events](https://docs.kraken.com/api/docs/futures-api/history/get-public-execution-events)

## Endpoint

```
GET /api/history/v2/market/{tradeable}/executions
```

**Full URL:** `https://futures.kraken.com/api/history/v2/market/{tradeable}/executions`

## Description

Lists trades/executions for a specific market. This is a public endpoint that returns execution data without requiring authentication. Returns paginated results with a `continuationToken` that can be used to request additional data.

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
| `elements` | array | Array of public execution event objects |
| `len` | integer | Number of elements returned |
| `continuationToken` | string | Token to use for requesting the next page of results |

### Element Object

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string (uuid) | Unique identifier of the event |
| `timestamp` | integer | Event timestamp in epoch milliseconds |
| `event` | object | The event data container |

### Event > Execution Object

| Field | Type | Description |
|-------|------|-------------|
| `event.Execution.execution.uid` | string (uuid) | Unique identifier of the execution |
| `event.Execution.execution.makerOrder` | object | The maker order details |
| `event.Execution.execution.takerOrder` | object | The taker order details |
| `event.Execution.execution.timestamp` | integer | Execution timestamp in epoch milliseconds |
| `event.Execution.execution.quantity` | string | Executed quantity |
| `event.Execution.execution.price` | string | Execution price |
| `event.Execution.execution.markPrice` | string | Mark price at time of execution |
| `event.Execution.execution.limitFilled` | boolean | Whether the limit order was fully filled |
| `event.Execution.execution.usdValue` | string | USD value of the execution |
| `event.Execution.takerReducedQuantity` | string | Quantity reduced for the taker |

### Public Order Object (makerOrder / takerOrder)

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string (uuid) | Order unique identifier |
| `tradeable` | string | The contract symbol (e.g., `PI_XBTUSD`) |
| `direction` | string | Order direction: `Buy` or `Sell` |
| `quantity` | string | Order quantity |
| `limitPrice` | string | Limit price of the order |
| `orderType` | string | Order type (e.g., `Post`, `IoC`) |
| `reduceOnly` | boolean | Whether the order is reduce-only |
| `timestamp` | integer | Order timestamp in epoch milliseconds |
| `lastUpdateTimestamp` | integer | Last update timestamp in epoch milliseconds |

## Example

**Request:**

```
GET https://futures.kraken.com/api/history/v2/market/PI_XBTUSD/executions
```

**Response:**

```json
{
    "elements": [
        {
            "uid": "9c74d4ba-a658-4208-891c-eee6e13bf910",
            "timestamp": 1680874894684,
            "event": {
                "Execution": {
                    "execution": {
                        "uid": "3df5cb59-d410-48f7-9c6f-ee9b849b9c91",
                        "makerOrder": {
                            "uid": "a0d28216-54f8-4af0-9adc-0d0d4738936d",
                            "tradeable": "PI_XBTUSD",
                            "direction": "Buy",
                            "quantity": "626",
                            "timestamp": 1680874894675,
                            "limitPrice": "27909.5",
                            "orderType": "Post",
                            "reduceOnly": false,
                            "lastUpdateTimestamp": 1680874894675
                        },
                        "takerOrder": {
                            "uid": "09246639-9130-42fb-8d90-4ed39913456f",
                            "tradeable": "PI_XBTUSD",
                            "direction": "Sell",
                            "quantity": "626",
                            "timestamp": 1680874894684,
                            "limitPrice": "27909.5000000000",
                            "orderType": "IoC",
                            "reduceOnly": false,
                            "lastUpdateTimestamp": 1680874894684
                        },
                        "timestamp": 1680874894684,
                        "quantity": "626",
                        "price": "27909.5",
                        "markPrice": "27915.01610466227",
                        "limitFilled": true,
                        "usdValue": "626.00"
                    },
                    "takerReducedQuantity": ""
                }
            }
        }
    ],
    "len": 1000,
    "continuationToken": "MTY4MDg2Nzg2ODkxOS85MDY0OTcwMTAxNA=="
}
```

## Notes

- Unlike the private execution events endpoint, this endpoint does not include `accountUid` or `serverTime` in the response.
- Public execution events do not include fee or position size data.
- The default number of results per page is 1000.
- The `continuationToken` from the response can be passed as `continuation_token` in subsequent requests to paginate through results.
