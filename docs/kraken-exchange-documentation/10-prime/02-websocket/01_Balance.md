# Balance (WebSocket)

## Endpoint

```
wss://wss.prime.kraken.com/ws/v1
```

## Channel

```
Balance
```

## Description

Provides real-time account balance information through a subscription stream. Returns current balances and available trading amounts for specified currencies, with optional equivalent currency conversion.

## Authentication

Authentication is required to access this stream.

## Subscribe Request

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | Request ID - will be echoed back in the response structure |
| `type` | string | Yes | Must be `subscribe` |
| `streams` | array | Yes | Contains Balance stream configuration |
| `streams[].name` | string | Yes | Must be `Balance` |
| `streams[].Currencies` | array | No | Optional list of currencies to filter the balance. If omitted, all currencies are returned. |
| `streams[].EquivalentCurrency` | string | No | If provided, will provide converted equivalent amounts in the specified currency |

### Example Request

```json
{
  "reqid": 11,
  "type": "subscribe",
  "streams": [
    {
      "name": "Balance",
      "EquivalentCurrency": "USD"
    }
  ]
}
```

## Response Message

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | Relates response to original request |
| `type` | string | Yes | Message type identifier |
| `ts` | string | Yes | ISO-8601 UTC timestamp |
| `initial` | boolean | No | Set if this is initial data |
| `seqNum` | number | Yes | Sequence number per request |
| `action` | string | No | `Update` or `Remove` |
| `data` | array | Yes | Array of balance records |

### Balance Data Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `Currency` | string | Yes | Currency identifier (e.g., `USD`, `BTC`) |
| `Amount` | string | Yes | Current balance amount in the specified currency |
| `AvailableAmount` | string | Yes | Amount available for trading right now |
| `Equivalent` | object | No | Converted balance (only present if `EquivalentCurrency` was requested) |
| `Equivalent.Currency` | string | No | Equivalent currency code |
| `Equivalent.Amount` | string | No | Converted balance amount |
| `Equivalent.AvailableAmount` | string | No | Converted available amount |

### Example Response

```json
{
  "reqid": 11,
  "type": "Balance",
  "ts": "2021-09-14T22:16:18.604996Z",
  "initial": true,
  "seqNum": 1,
  "action": "Update",
  "data": [
    {
      "Currency": "USD",
      "Amount": "100000.00",
      "AvailableAmount": "95000.00",
      "Equivalent": {
        "Currency": "USD",
        "Amount": "100000.00",
        "AvailableAmount": "95000.00"
      }
    },
    {
      "Currency": "BTC",
      "Amount": "5.00000000",
      "AvailableAmount": "4.50000000",
      "Equivalent": {
        "Currency": "USD",
        "Amount": "234086.39",
        "AvailableAmount": "210677.75"
      }
    }
  ]
}
```

## Notes

- The stream provides both current balance (`Amount`) and available trading amounts (`AvailableAmount`).
- Optional currency filtering allows subscribing to specific currencies only via the `Currencies` array.
- The `EquivalentCurrency` feature converts all balances to a common denomination for portfolio valuation.
- Negative balances are possible (e.g., for margin positions).

## Source

- [Kraken API Documentation - Balance (WebSocket)](https://docs.kraken.com/api/docs/prime-api/websocket/balance)
