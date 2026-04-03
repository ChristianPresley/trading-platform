# Market Data Incremental Refresh

> Source: https://docs.kraken.com/api/docs/fix-api/mdir-fix

## Overview

Market Data Incremental Refresh message for transmitting real-time updates to market data subscriptions. Follows the initial MarketDataSnapshotFullRefresh.

**FIX Message Type:** `X` (MarketDataIncrementalRefresh)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: X |
| 262 | MDReqID | Yes | string | Unique request identifier | -- |
| 55 | Symbol | Yes | string | Asset pair listed on exchange | -- |
| 268 | NoMDEntries | Yes | integer | Count of entries in repeating group | -- |
| 279 | MDUpdateAction | Yes | integer | First field in repeating group; action type | `0`=New (entry creation), `1`=Update (quantity change), `2`=Delete (entry removal) |
| 269 | MDEntryType | Yes | integer | Market data entry classification | `0`=Bid, `1`=Offer, `2`=Trade |
| 278 | MDEntryID | Yes | string | Unique identifier for market data entry | -- |
| 270 | MDEntryPx | Yes | float | Price of market data entry | -- |
| 271 | MDEntrySize | Yes | float | Volume represented by entry | -- |
| 273 | MDEntryTime | Yes | string | Time entry was inserted, amended, or deleted | -- |
| 5060 | MDEntryTimestamp | No | string | High-precision event time (Level 3 only); generation time when paired with 5273. ISO 8601 format with nanosecond precision (UTC) | -- |
| 5273 | MDEntryTimeQueue | No | string | Order book entry queue time (Level 3 only); determines ordering for same-price levels. ISO 8601 format with nanosecond precision (UTC) | -- |
| 40 | OrdType | Conditional | char | Taker order type (when MDEntryType=Trade) | `1`=Market, `2`=Limit |
| 2446 | AggressorSide | Conditional | char | Taker order side (when MDEntryType=Trade) | `1`=Buy, `2`=Sell |
| 5041 | ChecksumOrderBook | Conditional | string | Orderbook update verification checksum (when entry is Bid/Offer) | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Examples

### Spot L2 Example

```
8=FIX.4.4|9=213|35=X|34=100|56=MYCOMPIP|49=KRAKEN-MD|52=20230707-13:42:27.230|55=BTC/USD|262=1|268=2|279=2|269=1|278=O30300.7|270=30300.7|271=0.0|273=13:42:27.208|279=0|269=1|278=O31941.0|270=31941.0|271=0.0031746|273=20:40:00.455|10=112|
```

### Futures L2 Example

```
8=FIX.4.4|9=173|35=X|34=33402|49=KRAKEN-DRV-MD|52=20250303-14:13:24.905|56=MYCOMPID_DRV|55=PF_ETHUSD|262=1|268=1|279=0|269=0|278=B2372.7|270=2372.7|271=0.084|273=14:13:24.859|5041=3254665545|10=121|
```

### Futures L3 Example

```
8=FIX.4.4|9=198|35=X|34=7|49=KRAKEN-DRV-MD|52=20250304-15:25:09.913|56=MYCOMPID_DRV|55=PF_ETHUSD|262=1|268=1|279=2|269=1|278=00bf007e-0039-00dd-0071-00ae00d700c8|270=2044.8|271=2.874|273=15:25:09.844|5041=3889519115|10=012|
```

## Notes

- Multiple entries must be parsed sequentially within a single message.
- Level 3 subscriptions include additional precision timestamps (5060, 5273) for order queue tracking.
- Checksum validation is referenced in separate Spot FIX Checksums documentation.
- MDUpdateAction always appears first in the repeating group.
