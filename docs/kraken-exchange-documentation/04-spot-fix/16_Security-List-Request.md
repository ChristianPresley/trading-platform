# Instrument List Request

> Source: https://docs.kraken.com/api/docs/fix-api/slr-fix

## Overview

Retrieve a list of securities from the exchange that match the criteria provided on the request. Kraken recommends clients send this message on new connections or reconnections, as instrument status may change during disconnection periods.

**FIX Message Type:** `x` (InstrumentListRequest)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: x |
| 320 | InstrumentReqID | Yes | string | Unique request identifier | -- |
| 263 | SubscriptionRequestType | No | integer | Subscription type | `0`=Snapshot, `1`=Snapshot + Updates, `2`=Disable previous snapshot + Update request |
| 559 | InstrumentListRequestType | Yes | integer | Request scope | `0`=Single asset pair, `1`=SecurityType, `4`=All Securities |
| 167 | SecurityType | Conditional | string | Asset class filter; required when InstrumentListRequestType=1 | `CASH`=Spot, `FUT`=Futures, `OPT`=Options, `TS`=Tokenized stocks |
| 55 | Symbol | Conditional | string | Asset pair identifier (BASE/QUOTE format); required when InstrumentListRequestType=0 | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Notes

- Symbol is required when requesting a single asset pair (InstrumentListRequestType=0).
- SecurityType is required when filtering by asset class (InstrumentListRequestType=1).
- Use SubscriptionRequestType=1 to receive ongoing updates when instrument status changes.
