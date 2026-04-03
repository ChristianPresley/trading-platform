# Instrument List

> Source: https://docs.kraken.com/api/docs/fix-api/sl-fix

## Overview

This message provides the different parameters of each instrument that can be traded on Kraken as well as their status at the time of the request.

**FIX Message Type:** `y` (InstrumentList)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: y |
| 320 | InstrumentReqID | Yes | string | Unique request identifier | -- |
| 322 | InstrumentResponseID | Yes | string | Unique response identifier | -- |
| 560 | InstrumentRequestResult | Yes | integer | Result code indicating request validity | `0`=Valid request, `1`=Invalid or unsupported request, `2`=No Instruments found that match criteria, `4`=Instrument data temporarily unavailable |
| 393 | TotNoRelatedSym | No | integer | Total number of securities. Only seen when fragmentation occurs | -- |
| 893 | LastFragment | No | boolean | Indicates whether this message is the last in a sequence of messages when the Security List was delivered in multiple SecurityList messages | -- |
| 146 | NoRelatedSym | Yes | integer | Repeating group describing all the Symbols available on Kraken exchange | -- |
| 55 | Symbol | Yes | string | Asset Pair listed on Kraken exchange | -- |
| 562 | minTradeVol | Yes | float | Minimum order quantity increment on an asset pair | -- |
| 5010 | QtyPrecision | Yes | float | Specifies the quantity decimal precision of the asset pair and currency | -- |
| 5011 | QtyMin | Yes | float | Minimum order quantity allowed on asset pair | -- |
| 5012 | QtyMax | No | float | Maximum order quantity allowed on asset pair | -- |
| 5013 | MinimumCost | No | float | Minimum cost (price x qty) for new orders | -- |
| 2349 | PricePrecision | Yes | float | Specifies the price decimal precision of the asset pair | -- |
| 5022 | TickSize | Yes | float | Specifies the price increment allowed on the asset pair | -- |
| 5032 | AssetPairStatus | Yes | integer | Status indicator for the asset pair | See below |
| 58 | Text | No | string | Full description for rejection | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## AssetPairStatus Values (Tag 5032)

| Value | Status |
|---|---|
| 0 | Hidden |
| 1 | Online |
| 2 | Maintenance |
| 3 | CancelOnly |
| 4 | PostOnly |
| 5 | LimitOnly |
| 6 | Delisted |
| 7 | ReduceOnly |

## Notes

- Fields 55 through 5032 are part of the NoRelatedSym repeating group (tag 146).
- When the response is fragmented across multiple messages, use TotNoRelatedSym and LastFragment to track completeness.
