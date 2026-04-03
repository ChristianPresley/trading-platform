# Market Data Request

> Source: https://docs.kraken.com/api/docs/fix-api/mdr-fix

## Overview

The MarketDataRequest message enables clients to request market data streams for order books and/or trades. The FIX Server responds with MarketDataSnapshotFullRefresh if valid, or MarketDataRequestReject if invalid.

**FIX Message Type:** `V` (MarketDataRequest)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: V |
| 262 | MDReqID | Yes | string | Unique request identifier used to refer back to client and for unsubscribe | -- |
| 263 | SubscriptionRequestType | Yes | integer | Request type | `1`=Snapshot + Updates, `2`=Disable previous snapshot + Update |
| 264 | MarketDepth | Yes | integer | Market depth specification | `0`=Full depth (max 1000 for L2), `1`=Top of Book, `10`, `25`, `100`, `500`, `1000` |
| 265 | MDUpdateType | No | integer | Update refresh type | `1`=Incremental Refresh (only option supported) |
| 266 | AggregatedBook | No | boolean | Book aggregation level (defaults to `Y`) | `Y`=Level 2, `N`=Level 3 (Derivatives only) |
| 267 | NoMDEntryTypes | Yes | integer | Repeating group count of entry types | -- |
| 269 | MDEntryType | Yes | integer | Data type subscription (repeating) | `0`=Bid, `1`=Offer, `2`=Trade |
| 146 | NoRelatedSym | Yes | integer | Number of symbol pairs to subscribe | -- |
| 55 | Symbol | Yes | string | Asset pair on exchange | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Key Behaviors

- Subscriptions require unique MDReqID identifiers.
- Unsubscribe via MarketDataRequest with SubscriptionRequestType `2`.
- Responses include MarketDataSnapshotFullRefresh followed by MarketDataIncrementalRefresh messages.
- Level 3 available only for BID/OFFER MDEntryTypes; rejected if used with TRADE.
- Disconnections cancel subscriptions; reconnection requires resubscription.
- Tag 266 defaults to `Y` (Level 2).
