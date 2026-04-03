# Trading Session Status (Spot Only)

> Source: https://docs.kraken.com/api/docs/fix-api/tss-fix

## Overview

Response message providing trading session status information for spot markets only.

**FIX Message Type:** `h` (TradingSessionStatus)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: h |
| 335 | TradSesReqID | Yes | string | Unique request identifier | -- |
| 336 | TradingSessionID | Yes | string | Trading Session identifier | -- |
| 340 | TradSesStatus | No | integer | Market operational status | See below |
| 567 | TradSesStatusRejReason | No | integer | Rejection reason code | See below |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## TradSesStatus Values (Tag 340)

| Value | Status | Description |
|---|---|---|
| 0 | Unknown | -- |
| 1 | Maintenance | Offline, no orders/cancellations |
| 2 | Online | Normal operations |
| 101 | cancel_only | Cancellations allowed, no new orders |
| 102 | post_only | Limit orders with post_only option only |

## TradSesStatusRejReason Values (Tag 567)

| Value | Reason |
|---|---|
| 1 | UNKNOWNTRADINGSESSIONID |
| 100 | INVALIDREQUESTID |
| 101 | INVALIDSUBSTYPE |
| 102 | DUPLICATEREQUESTID |
| 103 | ALREADYSUBSCRIBED |

## Example

```
8=FIX.4.4|9=85|35=h|34=5|49=KRAKEN-MD|52=20230707-13:50:02.413|56=MYCOMPID|335=TSS0|336=SESSION|340=2|10=253|
```
