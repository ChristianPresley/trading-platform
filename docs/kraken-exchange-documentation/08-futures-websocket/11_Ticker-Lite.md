# Ticker Lite

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/ticker_lite

## Overview

The ticker lite feed returns ticker information about listed products. Delta messages are throttled such that they are published every 1 second. This is a lighter-weight alternative to the full `ticker` feed with fewer fields.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `ticker_lite`

## Authentication

No authentication required. This is a public market data channel.

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "ticker_lite",
  "product_ids": ["PI_XBTUSD", "FI_ETHUSD_210625"]
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `ticker_lite` |
| product_ids | list of strings | Yes | Products for which user receives information |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "ticker_lite",
  "product_ids": ["PI_XBTUSD"]
}
```

## Response/Update Format

```json
{
  "feed": "ticker_lite",
  "product_id": "PI_XBTUSD",
  "bid": 34932,
  "ask": 34949.5,
  "change": 3.3705205220015966,
  "premium": 0.1,
  "volume": 264126741,
  "tag": "perpetual",
  "pair": "XBT:USD",
  "dtm": 0,
  "maturityTime": 0,
  "volumeQuote": 264126741
}
```

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | The subscribed feed |
| product_id | string | The subscribed product/instrument/symbol |
| bid | positive float | Current best bid price |
| ask | positive float | Current best ask price |
| change | float | 24-hour price change |
| premium | float | Product premium |
| volume | positive float | Sum of fill sizes in last 24 hours |
| tag | string | `week`, `month`, `quarter`, or `perpetual` |
| pair | string | Currency pair (e.g., `XBT:USD`) |
| dtm | integer | Days until maturity |
| maturityTime | positive integer | Maturity time in milliseconds |
| volumeQuote | positive float | Volume converted to non-base currency for multi-collateral futures |

### Options Greeks Fields (Optional)

| Field | Type | Description |
|-------|------|-------------|
| greeks | structure | Current Greeks for options |
| iv | float | Option implied volatility |
| delta | float | Option delta value |
| theta | float | Option theta value |
| gamma | float | Option gamma value |
| vega | float | Option vega value |
| rho | float | Option rho value |

## Error Response

```json
{
  "event": "error",
  "message": "Invalid product id"
}
```

### Error Messages

- `Invalid product id`
- `Invalid feed`
- `Json Error`
