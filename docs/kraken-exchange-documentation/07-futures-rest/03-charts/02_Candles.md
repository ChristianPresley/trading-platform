# Market Candles

Source: [https://docs.kraken.com/api/docs/futures-api/charts/candles](https://docs.kraken.com/api/docs/futures-api/charts/candles)

## Endpoint

```
GET /api/charts/v1/{tick_type}/{symbol}/{resolution}
```

**Full URL:** `https://futures.kraken.com/api/charts/v1/{tick_type}/{symbol}/{resolution}`

## Description

Retrieves OHLC (Open, High, Low, Close) candle data for a specified tick type, market, and resolution. This is the primary endpoint for fetching historical price chart data for Kraken Futures contracts.

## Authentication

This is a **public** endpoint. No authentication is required.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tick_type` | string | Yes | The kind of price data. Values: `mark`, `spot`, `trade`. Available values can be retrieved from the [Tick Types](tick-types.md) endpoint. |
| `symbol` | string | Yes | The trading pair / contract symbol (e.g., `PI_XBTUSD`, `PF_SOLUSD`). Available values can be retrieved from the [Markets](symbols.md) endpoint. |
| `resolution` | string | Yes | The candle time interval. Values: `1m`, `5m`, `15m`, `30m`, `1h`, `4h`, `12h`, `1d`, `1w`. Available values can be retrieved from the [Resolutions](resolutions.md) endpoint. |

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `from` | integer | No | Start date filter in epoch seconds |
| `to` | integer | No | End date filter in epoch seconds (inclusive) |

## Response Fields

### 200 - Success

| Field | Type | Description |
|-------|------|-------------|
| `candles` | array | Array of OHLC candle objects |
| `more_candles` | boolean | Whether more candle data is available beyond the returned set |

### Candle Object

| Field | Type | Description |
|-------|------|-------------|
| `time` | integer | Candle timestamp in epoch milliseconds |
| `open` | string | Opening price for the candle period |
| `high` | string | Highest price during the candle period |
| `low` | string | Lowest price during the candle period |
| `close` | string | Closing price for the candle period |
| `volume` | string | Total volume during the candle period |

## Example

**Request:**

```
GET https://futures.kraken.com/api/charts/v1/trade/PI_XBTUSD/1h
```

**Response:**

```json
{
    "candles": [
        {
            "time": 1680624000000,
            "open": "28050.0",
            "high": "28150",
            "low": "27983.0",
            "close": "28126.0",
            "volume": "1089794.00000000"
        }
    ],
    "more_candles": true
}
```

**Request with time filter:**

```
GET https://futures.kraken.com/api/charts/v1/trade/PI_XBTUSD/1h?from=1680600000&to=1680700000
```

## Notes

- The `from` and `to` query parameters use **epoch seconds** (not milliseconds), while the `time` field in the response uses **epoch milliseconds**.
- When `more_candles` is `true`, additional candle data exists beyond the returned set. Adjust the `from`/`to` parameters to retrieve more data.
- Valid tick types are `mark` (mark price), `spot` (spot/index price), and `trade` (last trade price).
- Not all resolution values may be available for all tick type and symbol combinations. Use the [Resolutions](resolutions.md) endpoint to discover valid combinations.
