# Spot Trading Limits

> Source: https://docs.kraken.com/api/docs/guides/spot-ratelimits

## Overview

Kraken's spot trading system enforces two primary constraint categories:

1. **Rate of transactions** - Controls trading frequency per pair
2. **Open order count** - Limits maximum concurrent orders per pair

These limits apply uniformly across REST, WebSocket, and FIX protocols.

## Transaction Rate Limits

### Rate Counter Mechanics

Each client maintains a per-pair rate counter beginning at zero. The counter increments when transactions occur and decreases through a time-based decay mechanism. When the counter exceeds the client's tier threshold, the system rejects further trades with an `EOrder:Rate limit exceeded` message.

### Counter Increments by Transaction Type

Different operations add varying amounts to the counter:

| Transaction | Fixed | <5s | <10s | <15s | <45s | <90s | <300s |
|---|---|---|---|---|---|---|---|
| Add Order | +1 | — | — | — | — | — | — |
| Amend Order | +1 | +3 | +2 | +1 | — | — | — |
| Edit Order | +1 | +6 | +5 | +4 | +2 | +1 | — |
| Cancel Order | — | +8 | +6 | +5 | +4 | +2 | +1 |
| Batch Add | +(n/2) | — | — | — | — | — | — |
| Batch Cancel | — | +(8×n) | +(6×n) | +(5×n) | +(4×n) | +(2×n) | +(1×n) |

**Note:** As per batch orders, `n` represents the number of orders in a batch.

### Decay Rates by Tier

The counter decreases each second based on client tier:

| Tier | Decay Rate |
|---|---|
| Starter | -1 per second |
| Intermediate | -2.34 per second |
| Pro | -3.75 per second |

### Rate Counter Thresholds

| Tier | Threshold |
|---|---|
| Starter | 60 |
| Intermediate | 125 |
| Pro | 180 |

## Open Order Limits

The maximum number of concurrent open orders per trading pair:

| Tier | Maximum |
|---|---|
| Starter | 60 |
| Intermediate | 80 |
| Pro | 225 |

Exceeding this limit generates an `EOrder:Orders limit exceeded` rejection message.
