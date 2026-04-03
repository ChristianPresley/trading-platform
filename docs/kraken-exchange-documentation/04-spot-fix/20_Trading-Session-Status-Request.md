# Trading Session Status Request (Spot Only)

> Source: https://docs.kraken.com/api/docs/fix-api/tssr-fix

## Overview

Query market status with options for snapshot-only retrieval or continuous updates. Individual instrument statuses are available via the Instrument List Request. Applicable to Spot trading only.

**FIX Message Type:** `g` (TradingSessionStatusRequest)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: g |
| 335 | TradSesReqID | Yes | string | Unique request identifier | -- |
| 336 | TradingSessionID | Yes | string | Trading Session identifier | -- |
| 263 | SubscriptionRequestType | Yes | integer | Subscription preference | `0`=Snapshot only, `1`=Snapshot + Updates |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Example

```
8=FIX.4.4|9=85|35=g|34=6|49=MYCOMPIC|52=20230707-13:50:02.000|56=KRAKEN-MD|263=0|335=TSS0|336=SESSION|10=247|
```
