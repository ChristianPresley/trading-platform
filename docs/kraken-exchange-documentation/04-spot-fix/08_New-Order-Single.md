# New Order Single

> Source: https://docs.kraken.com/api/docs/fix-api/nos-fix

## Overview

Submit a new order via FIX protocol to the Kraken exchange. Covers all supported order types, Time-In-Force options, and detailed field specifications.

**FIX Message Type:** `D` (NewOrderSingle)

## Supported Order Types

| Order Type | Description |
|---|---|
| market | Full quantity executes immediately at best available price |
| limit | Full quantity placed with limit price restriction |
| stop-loss | Market order triggered when reference price reaches stop price (unfavourable direction) |
| stop-loss-limit | Limit order triggered at stop price (unfavourable direction) |
| take-profit | Market order triggered when reference price reaches stop price (favourable direction) |
| take-profit-limit | Limit order triggered at stop price (favourable direction) |
| trailing-stop | Market order triggered when market reverts specified distance from peak |
| trailing-stop-limit | Limit order triggered when market reverts specified distance from peak |

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: D |
| 11 | ClOrdID | Yes | string | Unique order identifier; supports ever-increasing positive numbers (max 18 chars, Spot only) or timestamp-first v4 UUIDs (10 microsecond granularity max) | Example: `1623448294234000` or `1b4e28ba-2fa1-11d2-883f-0016d3cca427` |
| 40 | OrderType | Yes | char | Execution model of the order | `1`=market, `2`=limit, `3`=stop-loss, `4`=stop-loss-limit, `R`=take-profit, `T`=take-profit-limit, `U`=trailing-stop, `V`=trailing-stop-limit (Spot only) |
| 44 | Price | Conditional | float | Limit price denominated in quote currency; required when OrderType is Limit/Stop-Loss-Limit/Take-Profit-Limit/Trailing-stop-limit | -- |
| 38 | OrderQty | Yes | float | Order quantity in base asset terms | -- |
| 1138 | DisplayQty | No | float | Iceberg quantity (amount visible on book); limit orders only; minimum value is 1/15 of order_qty (Spot only) | -- |
| 54 | Side | Yes | integer | Order side | `1`=buy, `2`=sell |
| 55 | Symbol | Yes | string | Trading pair in BASE/QUOTE format | Example: BTC/USD, PF_ETHUSD |
| 59 | TimeInForce | Yes | string | Duration order remains active before expiration | `1`=GTC (Good Till Canceled), `3`=IOC (Immediate or Cancel), `4`=FOK (Fill or Kill), `6`=GTD (Good Till Date, Spot only) |
| 60 | TransactTime | Yes | string | Order creation time in UTC | Format: YYYYMMDD-HH:MM:SS.uuu |
| 126 | ExpireTime | Conditional | string | Order expiration time if not fully filled; required for GTD orders; maximum one month future (Spot only) | Format: YYYYMMDD-HH:MM:SS |
| 168 | EffectiveTime | No | string | Scheduled start time; order invisible/non-matching before this time (Spot only) | Format: YYYYMMDD-HH:MM:SS.uuu |
| 18 | ExecInst | No | char | Multiple instructions separated by space | `E`=Reduce-Only, `P`=Post-Only, `v`=viqc (order qty in quote currency, Spot only), `f`=cumulative fee in base (Spot only), `q`=cumulative fee in quote (Spot only), `s`=single fee (derivatives only) |
| 99 | StopPx | Conditional | float | Trigger price for stop/take-profit orders in quote currency; required when OrderType is Stop-Loss/Take-Profit/Stop-Loss-Limit/Trailing-stop/Trailing-stop-limit | -- |
| 388 | DiscretionInst | No | integer | Reference price for triggering orders | `1`=index price, `5`=last trade price (default: `5`) |
| 5001 | Leverage | No | string | Margin account funding for order (Spot only) | `0`=margin disabled (default), `1`=margin enabled |
| 7928 | SelfTradePrevention | No | integer | STP mode to prevent self-matching (Spot only) | `0`=cancel both, `1`=cancel newest/arriving (default), `2`=cancel oldest/resting |
| 78 | NoAllocs | No | integer | Number of subaccounts in order; always 1 for broker accounts | -- |
| 79 | AllocAccount | No | string | Subaccount ID for targeted order (broker accounts only; contact Account Manager) | -- |
| 62 | ValidUntilTime | No | string | Engine rejection deadline for time-sensitive orders; 2-60 seconds in future | Format: YYYYMMDD-HH:MM:SS.uuu |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Examples

### Spot Example

```
8=FIX.4.4|9=140|35=D|34=2|49=MYCOMPID|52=20230707-13:56:08.000|56=KRAKEN-TRD|11=1688738168|38=0.01|40=2|44=1000|54=1|55=BTC/USD|59=1|60=20230707-13:56:08.277|10=222|
```

### Futures Example

```
8=FIX.4.4|9=181|35=D|34=2|49=damien2_DRV|52=20250303-14:09:32.902|56=KRAKEN-DRV-TRD|11=9e58120f-182b-4dce-9609-8ca7cdd174f0|18=s|38=0.1|40=2|44=1000|54=1|55=PF_ETHUSD|59=1|60=20250303-14:09:32.896|10=148|
```

## Order Validation

Kraken performs multi-level validation:

1. **FIX Field Level:** Missing required fields trigger a session level reject.
2. **Business Rule Validation:** Rule violations produce a business level reject.
3. **Post-Acceptance:** Further validation failures result in an execution report with unsolicited cancel status.

## Notes

- ClOrdID supports two formats: timestamps up to 18 characters or timestamp-first v4 UUIDs with 10-microsecond granularity.
- DisplayQty (iceberg orders) available on limit orders only (Spot).
- GTD orders expire maximum one month in future.
- ValidUntilTime provides latency protection: 2-60 seconds future requirement.
- STP prevents inadvertent self-trading across order types.
