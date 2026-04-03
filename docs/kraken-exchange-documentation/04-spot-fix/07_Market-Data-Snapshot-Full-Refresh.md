# Market Data Snapshot Full Refresh

> Source: https://docs.kraken.com/api/docs/fix-api/mdsfr-fix

## Overview

FIX message used for transmitting market data snapshots across spot and derivatives markets. Sent as the initial response to a MarketDataRequest subscription.

**FIX Message Type:** `W` (MarketDataSnapshotFullRefresh)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: W |
| 262 | MDReqID | Yes | string | Unique request identifier | -- |
| 55 | Symbol | Yes | string | Asset Pair listed on the exchange | -- |
| 268 | NoMDEntries | Yes | integer | Number of entries following | -- |
| 269 | MDEntryType | Yes | integer | Market side indicator | `0`=Bid, `1`=Offer |
| 278 | MDEntryID | Yes | string | Unique identifier for this market data entry | -- |
| 270 | MDEntryPx | Yes | float | Price of the market data entry | -- |
| 271 | MDEntrySize | Yes | float | Volume represented by the market data entry | -- |
| 273 | MDEntryTime | Yes | string | Time of market data entry | -- |
| 5060 | MDEntryTimestamp | No | string | High-precision event time for this market data update. Level 3 only. Nanosecond precision, ISO 8601 UTC format | -- |
| 5273 | MDEntryTimeQueue | No | string | Queue entry time: when the order entered the book at this price level. Level 3 only | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## MDEntryType Values

| Value | Type |
|---|---|
| 0 | Bid |
| 1 | Offer |

Trade entries will only be transmitted via Market Data Incremental Refresh messages.

## Examples

### Spot L2 Example

```
8=FIX.4.4|9=208|35=W|34=21|49=KRAKEN-MD|52=20230707-13:49:11.245|56=MYCOMPID|55=BTC/USD|262=3|268=2|269=1|278=O30300.0|270=30300.0|271=8.44867022|273=13:49:07.307|269=0|278=B30299.9|270=30299.9|271=0.67373926|273=13:49:10.179|10=254|
```

## Notes

- Fields 269 through 5273 are part of the NoMDEntries repeating group (tag 268).
- Level 3 data includes additional precision timestamps (tags 5060 and 5273) for order queue tracking.
- Futures L3 examples include MDEntryID as UUIDs with timestamps and queue times.
