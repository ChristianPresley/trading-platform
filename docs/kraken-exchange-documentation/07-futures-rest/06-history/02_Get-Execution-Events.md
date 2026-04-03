# Get Execution Events

Source: [https://docs.kraken.com/api/docs/futures-api/history/get-execution-events](https://docs.kraken.com/api/docs/futures-api/history/get-execution-events)

## Endpoint

```
GET /api/history/v2/executions
```

**Full URL:** `https://futures.kraken.com/api/history/v2/executions`

## Description

Lists executions/trades for the authenticated account. Returns paginated results with a `continuationToken` that can be used to request additional data. Each element contains detailed execution information including maker/taker order details, prices, quantities, fees, and position sizes.

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
| `elements` | array | Array of execution event objects |
| `len` | integer | Number of elements returned |
| `serverTime` | string (date-time) | Server time in UTC |

### Element Object

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string (uuid) | Unique identifier of the event |
| `timestamp` | integer | Event timestamp in epoch milliseconds |
| `event` | object | The event data container |

### Event > Execution Object

| Field | Type | Description |
|-------|------|-------------|
| `event.execution.execution.uid` | string (uuid) | Unique identifier of the execution |
| `event.execution.execution.makerOrder` | object | The maker order details |
| `event.execution.execution.takerOrder` | object | The taker order details |
| `event.execution.execution.oldTakerOrder` | object | The previous state of the taker order |
| `event.execution.execution.makerOrderData` | object | Additional maker order data (fee, position size) |
| `event.execution.execution.takerOrderData` | object | Additional taker order data (fee, position size) |
| `event.execution.execution.timestamp` | integer | Execution timestamp in epoch milliseconds |
| `event.execution.execution.quantity` | string | Executed quantity |
| `event.execution.execution.price` | string | Execution price |
| `event.execution.execution.markPrice` | string | Mark price at time of execution |
| `event.execution.execution.limitFilled` | boolean | Whether the limit order was fully filled |
| `event.execution.execution.usdValue` | string | USD value of the execution |

### Order Object (makerOrder / takerOrder)

| Field | Type | Description |
|-------|------|-------------|
| `accountUid` | string (uuid) | Account unique identifier |
| `uid` | string (uuid) | Order unique identifier |
| `tradeable` | string | The contract symbol (e.g., `pi_xbtusd`) |
| `direction` | string | Order direction: `Buy` or `Sell` |
| `quantity` | string | Order quantity |
| `filled` | string | Filled quantity |
| `limitPrice` | string | Limit price of the order |
| `orderType` | string | Order type (e.g., `lmt`, `IoC`, `Post`) |
| `reduceOnly` | boolean | Whether the order is reduce-only |
| `timestamp` | integer | Order timestamp in epoch milliseconds |
| `lastUpdateTimestamp` | integer | Last update timestamp in epoch milliseconds |

### Order Data Object (makerOrderData / takerOrderData)

| Field | Type | Description |
|-------|------|-------------|
| `fee` | string | Fee charged for the execution |
| `positionSize` | string | Resulting position size after execution |

## Example

**Request:**

```
GET https://futures.kraken.com/api/history/v2/executions?tradeable=PF_SOLUSD&since=1668989233&before=1668999999&sort=asc
```

**Response:**

```json
{
    "accountUid": "f7d5571c-6d10-4cf1-944a-048d25682ed0",
    "continuationToken": "alp81a",
    "elements": [
        {
            "event": {
                "execution": {
                    "execution": {
                        "limitFilled": false,
                        "makerOrder": {
                            "accountUid": "f7d5571c-6d10-4cf1-944a-048d25682ed0",
                            "direction": "Buy",
                            "filled": "2332.12239",
                            "lastUpdateTimestamp": 1605126171852,
                            "limitPrice": "1234.56789",
                            "orderType": "lmt",
                            "quantity": "1234.56789",
                            "reduceOnly": false,
                            "timestamp": 1605126171852,
                            "tradeable": "pi_xbtusd",
                            "uid": "f7d5571c-6d10-4cf1-944a-048d25682ed0"
                        },
                        "makerOrderData": {
                            "fee": "12.56789",
                            "positionSize": "2332.12239"
                        },
                        "markPrice": "27001.56",
                        "price": "2701.8163",
                        "quantity": "0.156121",
                        "takerOrder": {
                            "accountUid": "f7d5571c-6d10-4cf1-944a-048d25682ed0",
                            "direction": "Buy",
                            "filled": "0.156121",
                            "lastUpdateTimestamp": 1605126171852,
                            "limitPrice": "2702.91",
                            "orderType": "lmt",
                            "quantity": "0.156121",
                            "reduceOnly": false,
                            "timestamp": 1605126171852,
                            "tradeable": "pi_xbtusd",
                            "uid": "f7d5571c-6d10-4cf1-944a-048d25682ed0"
                        },
                        "takerOrderData": {
                            "fee": "12.83671",
                            "positionSize": "27012.91"
                        },
                        "timestamp": 1605126171852,
                        "uid": "f7d5571c-6d10-4cf1-944a-048d25682ed0",
                        "usdValue": "2301.56789"
                    }
                }
            },
            "timestamp": 1605126171852,
            "uid": "f7d5571c-6d10-4cf1-944a-048d25682ed0"
        }
    ],
    "len": 0,
    "serverTime": "2023-04-06T21:11:31.677Z"
}
```

## Notes

- If you experience timeout errors, consider increasing your HTTP client timeout value.
- The `continuationToken` from the response can be passed as `continuation_token` in subsequent requests to paginate through results.
- Timestamps in query parameters are epoch milliseconds.
- The `sort` parameter accepts `asc` (ascending) or `desc` (descending).
