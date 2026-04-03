# Get Public Mark Price Events

Source: [https://docs.kraken.com/api/docs/futures-api/history/get-public-price-events](https://docs.kraken.com/api/docs/futures-api/history/get-public-price-events)

## Endpoint

```
GET /api/history/v2/market/{tradeable}/price
```

**Full URL:** `https://futures.kraken.com/api/history/v2/market/{tradeable}/price`

## Description

Lists mark price events for a specific market. This is a public endpoint that returns price change data without requiring authentication. Returns paginated results with a `continuationToken` that can be used to request additional data.

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
| `elements` | array | Array of mark price event objects |
| `len` | integer | Number of elements returned |
| `continuationToken` | string | Token to use for requesting the next page of results |

### Element Object

| Field | Type | Description |
|-------|------|-------------|
| `uid` | string | Unique identifier of the event (may be empty string for price events) |
| `timestamp` | integer | Event timestamp in epoch milliseconds |
| `event` | object | The event data container |

### Event > MarkPriceChanged Object

| Field | Type | Description |
|-------|------|-------------|
| `event.MarkPriceChanged.price` | string | The new mark price value |

## Example

**Request:**

```
GET https://futures.kraken.com/api/history/v2/market/PI_XBTUSD/price
```

**Response:**

```json
{
    "elements": [
        {
            "uid": "",
            "timestamp": 1680875273372,
            "event": {
                "MarkPriceChanged": {
                    "price": "27900.67795901584"
                }
            }
        },
        {
            "uid": "",
            "timestamp": 1680875272263,
            "event": {
                "MarkPriceChanged": {
                    "price": "27900.09023205142"
                }
            }
        }
    ],
    "len": 1000,
    "continuationToken": "MTY4MDg3NDEyNzg3OC85MDY2MjI3ODIzMA=="
}
```

## Notes

- The `uid` field is typically empty for mark price change events.
- Mark price events are generated frequently as the mark price is continuously recalculated.
- The default number of results per page is 1000.
- The `continuationToken` from the response can be passed as `continuation_token` in subsequent requests to paginate through results.
- Mark price is calculated from the order book and external index prices, providing a fair value estimate used for margin calculations and liquidations.
