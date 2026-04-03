# Ticker

> Source: https://docs.kraken.com/api/docs/futures-api/websocket/ticker

## Overview

The ticker feed returns ticker information about listed products. Only tradeable markets are available via individual WebSocket market data feeds. Delta messages are throttled such that they are published every 1 second.

## Connection

- **Endpoint:** `wss://futures.kraken.com/ws/v1`
- **Feed:** `ticker`

## Authentication

No authentication required. This is a public market data channel.

## Request/Subscription Format

```json
{
  "event": "subscribe",
  "feed": "ticker",
  "product_ids": ["PI_XBTUSD"]
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| event | string | Yes | `subscribe` or `unsubscribe` |
| feed | string | Yes | The requested subscription feed: `ticker` |
| product_ids | list of strings | Yes | Products for which user receives information |

## Subscription Confirmation

```json
{
  "event": "subscribed",
  "feed": "ticker",
  "product_ids": ["PI_XBTUSD"]
}
```

## Response/Update Format

Subscription data returns all fields even if only one field changed since the last payload.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| feed | string | Subscribed feed name |
| product_id | string | Subscribed product/instrument/symbol |
| time | positive integer | UTC server time in milliseconds |
| bid | positive float | Current best bid price |
| ask | positive float | Current best ask price |
| bid_size | positive float | Size of current best bid |
| ask_size | positive float | Size of current best ask |
| volume | positive float | Sum of all fills in last 24 hours |
| dtm | positive integer | Days until maturity |
| leverage | string | Product leverage |
| index | positive float | Real-time product index |
| last | positive float | Last fill price |
| change | float | 24-hour price change |
| suspended | boolean | Market suspension status |
| tag | string | `perpetual`, `month`, or `quarter` (other tags may be added) |
| pair | string | Currency pair of instrument |
| openInterest | float | Current open interest |
| markPrice | float | Market price of instrument |
| maturityTime | positive integer | UTC timestamp when contract stops trading (milliseconds) |
| post_only | boolean | Post-only market status |
| volumeQuote | positive float | Volume converted to non-base currency for multi-collateral futures |
| open | positive float | First traded price in last 24 hours |
| high | positive float | Highest traded price in last 24 hours |
| low | positive float | Lowest traded price in last 24 hours |

### Perpetuals-Only Fields

| Field | Type | Description |
|-------|------|-------------|
| funding_rate | float | Current funding rate (omitted if zero) |
| funding_rate_prediction | float | Estimated next funding rate (omitted if zero) |
| relative_funding_rate | float | Absolute funding rate relative to spot price (omitted if zero) |
| relative_funding_rate_prediction | float | Estimated next absolute funding rate (omitted if zero) |
| next_funding_rate_time | float | Milliseconds until next funding rate |

### Options Greeks Fields

| Field | Type | Description |
|-------|------|-------------|
| greeks | structure | Current Greeks for options |
| iv | float | Option implied volatility |
| delta | float | Option sensitivity to underlying price changes |
| theta | float | Option sensitivity to time passage |
| gamma | float | Delta sensitivity to underlying price changes |
| vega | float | Option sensitivity to volatility changes |
| rho | float | Option sensitivity to interest rate changes |

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
