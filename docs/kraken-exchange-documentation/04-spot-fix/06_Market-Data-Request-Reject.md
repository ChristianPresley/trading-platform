# Market Data Request Reject

> Source: https://docs.kraken.com/api/docs/fix-api/mdrr-fix

## Overview

This FIX message communicates rejection of a market data subscription request.

**FIX Message Type:** `Y` (MarketDataRequestReject)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: Y |
| 262 | MDReqID | Yes | string | Unique request identifier | -- |
| 281 | MDReqRejReason | Yes | integer | Reason for rejection | See below |
| 58 | Text | No | string | Rejection description details | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## MDReqRejReason Values (Tag 281)

| Value | Reason |
|---|---|
| 0 | Unknown Symbol |
| 1 | Duplicate MDReqID |
| 4 | Unsupported SubscriptionRequestType |
| 5 | Unsupported MarketDepth |
| 6 | Unsupported MDUpdateType |
| 8 | Unsupported MDEntryType |
| A | Unsupported Scope |
| B | Level3 not available |
| C | Trade not available on this request |

## Example

```
8=FIX.4.4|9=141|35=Y|34=3|49=KRAKEN-MD|52=20230707-13:47:50.963|56=MYCOMPIP|58=MarketData subscription failed due to unsupported symbol: TEST/TEST|262=1|281=0|10=142
```
