# Currency Conversion (WebSocket)

## Endpoint

```
wss://wss.prime.kraken.com/ws/v1
```

## Channel

```
CurrencyConversion
```

## Description

Provides a stream of currency conversion rates for specified currencies against a quote currency. Useful for portfolio valuation and real-time currency rate monitoring.

## Subscribe Request

### Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | Request ID echoed in response |
| `type` | string | Yes | Must be `subscribe` |
| `streams` | array | Yes | Configuration array |
| `streams[].name` | string | Yes | Must be `CurrencyConversion` |
| `streams[].EquivalentCurrency` | string | Yes | Quote currency basis (e.g., `USD`) |
| `streams[].Currencies` | array | No | Currency list to receive rates for. Defaults to all available currencies if omitted. |
| `streams[].Throttle` | string | No | Update interval. Minimum: `10s` |
| `streams[].Tolerance` | string | No | Rate change threshold before sending an update. Minimum: `0.0001` (1 basis point) |

### Example Request

```json
{
  "reqid": 4,
  "type": "subscribe",
  "streams": [
    {
      "name": "CurrencyConversion",
      "EquivalentCurrency": "USD",
      "Currencies": ["BTC", "ETH", "BCH-USD"],
      "Throttle": "15s",
      "Tolerance": "0.0002"
    }
  ]
}
```

## Response Message

### Top-Level Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `reqid` | number | Yes | Relates response to original request |
| `type` | string | Yes | Message type (`CurrencyConversion`) |
| `ts` | string | Yes | ISO-8601 UTC timestamp |
| `initial` | boolean | No | Indicates initial data transmission |
| `seqNum` | number | Yes | Sequence number per request |
| `action` | string | No | `Update` or `Remove` |
| `data` | array | Yes | Array of conversion rate data |

### Conversion Rate Data Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `Timestamp` | string | Yes | Message publication timestamp |
| `EquivalentCurrency` | string | Yes | Quote currency symbol (e.g., `USD`) |
| `Currency` | string | Yes | Base currency symbol (e.g., `BTC`, `ETH`) |
| `Rate` | string | Yes | Conversion rate value |
| `Status` | string | Yes | Rate status (e.g., `Online`) |
| `ConversionPath` | string | Yes | Conversion calculation path (e.g., `(ETH-USD)`) |

### Example Response

```json
{
  "reqid": 4,
  "type": "CurrencyConversion",
  "ts": "2021-09-14T22:16:18.604996Z",
  "initial": true,
  "seqNum": 1,
  "data": [
    {
      "Timestamp": "2021-09-14T22:16:18.604674Z",
      "EquivalentCurrency": "USD",
      "Currency": "ETH",
      "Rate": "3368.16",
      "Status": "Online",
      "ConversionPath": "(ETH-USD)"
    }
  ]
}
```

## Throttle and Tolerance

The `Throttle` and `Tolerance` parameters allow you to control the frequency and sensitivity of updates:

| Parameter | Minimum | Description |
|-----------|---------|-------------|
| `Throttle` | `10s` | Minimum time between updates. Prevents excessive message volume. |
| `Tolerance` | `0.0001` (1 bps) | Minimum rate change before triggering an update. Filters out noise. |

## Notes

- The `ConversionPath` field shows how the rate is derived (e.g., direct pair or through intermediate pairs).
- Timestamp format is ISO-8601 UTC: `2019-02-13T05:17:32.000000Z`.
- If `Currencies` is omitted, conversion rates for all available currencies will be streamed.
- The `EquivalentCurrency` field is required and defines the denomination for all rates.

## Source

- [Kraken API Documentation - Currency Conversion (WebSocket)](https://docs.kraken.com/api/docs/prime-api/websocket/currency-conversion)
