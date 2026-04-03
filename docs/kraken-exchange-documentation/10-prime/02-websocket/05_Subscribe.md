# Subscribe (WebSocket)

## Endpoint

```
wss://wss.prime.kraken.com/ws/v1
```

## Description

Initiate data streams by sending subscription requests to receive real-time updates across various data types. This is the primary mechanism for subscribing to all WebSocket channels.

## Request Message

### Required Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | Request identifier that will be echoed back in the response structure. Cannot equal 0. |
| `type` | string | Yes | Must be `subscribe` |
| `streams` | array | Yes | Collection of stream subscriptions to activate |

### Optional Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `tag` | string | No | User-generated identifier for attaching to stream data |
| `ts` | string | No | ISO-8601 UTC timestamp. Format: `2019-02-13T05:17:32.000000Z` |

### Stream Object Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Subscription identifier (e.g., `Security`, `MarketDataSnapshot`, `Balance`, `Order`) |
| Additional parameters | varies | Varies | Additional parameters vary by subscription type (e.g., `Symbol`, filters) |

### Example Request

```json
{
  "reqid": 1,
  "type": "subscribe",
  "streams": [
    {
      "name": "MarketDataSnapshot",
      "Symbol": "BTC-USD"
    }
  ],
  "ts": "2019-02-13T05:17:32.000000Z"
}
```

## Response Message

### Required Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | Links response to originating request |
| `seqNum` | number | Yes | Message sequence per request. Starts at 1, increments sequentially. For debug purposes only; client is not required to do any sequencing. |
| `type` | string | Yes | Message classification |
| `data` | array | Yes | Response payload structured per subscription type |
| `ts` | string | Yes | ISO-8601 UTC timestamp |

### Optional Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `tag` | string | No | Echoed from request if provided |
| `initial` | boolean | No | Indicates initial data transmission |
| `action` | string | No | `Update` or `Remove` directive |
| `total_count` | number | No | Record total for stream |
| `next` | string | No | Pagination tag for subsequent pages |

### Example Response

```json
{
  "reqid": 1,
  "seqNum": 1,
  "type": "MarketDataSnapshot",
  "action": "Update",
  "data": [
    {
      "Symbol": "BTC-USD",
      "Status": "Online",
      "Bids": [
        {
          "Price": "46817.27965000",
          "Size": "1.00000000"
        }
      ],
      "Offers": [
        {
          "Price": "46868.59755873",
          "Size": "1.00000000"
        }
      ]
    }
  ],
  "ts": "2019-02-13T05:17:32.000000Z"
}
```

## Action Directives

| Action | Description |
|--------|-------------|
| `Update` | Entity should be added or updated in the client's local state |
| `Remove` | Entity should be removed from the client's local state |

## Notes

- `seqNum` is for debug purposes only; the client is not required to do any sequencing.
- Multiple `initial` flags may appear for different message types in single requests.
- Action directives determine whether entities should be added/updated or removed.
- The `next` field enables pagination for large data sets.
- Different stream types accept different additional parameters in the `streams` array.

## Available Streams

| Stream Name | Description |
|-------------|-------------|
| `MarketDataSnapshot` | Real-time market data (bids/offers) |
| `Balance` | Account balance updates |
| `Order` | Order status updates |
| `CurrencyConversion` | Currency conversion rates |

## Source

- [Kraken API Documentation - Subscribe (WebSocket)](https://docs.kraken.com/api/docs/prime-api/websocket/subscribe)
