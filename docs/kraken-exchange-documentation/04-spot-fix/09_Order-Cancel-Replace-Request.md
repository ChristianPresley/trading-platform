# Order Cancel Replace Request (Spot Only)

> Source: https://docs.kraken.com/api/docs/fix-api/ocrr-fix

## Overview

The Order Cancel-Replace Request message enables clients to amend working orders by changing replaceable fields (quantities and prices). Successful replacement results in an execution report with updated order status. Applicable for Spot trading only.

**FIX Message Type:** `G`

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: G |
| 11 | ClOrdID | Yes | string | Unique order identifier; max 18 characters. Format: ever-increasing positive numbers (e.g., microsecond timestamps) or timestamp-first v4 UUIDs | -- |
| 37 | OrderID | Yes | string | OrderID being amended; must match ExecutionReports value | -- |
| 41 | OrigClordid | Yes | string | Reference to the last ClordId used | -- |
| 54 | Side | Yes | integer | Order direction | `1`=Buy, `2`=Sell |
| 55 | Symbol | Yes | string | Trading pair in BASE/QUOTE format | -- |
| 60 | TransactTime | Yes | string | Order cancellation time in UTC | Format: YYYYMMDD-HH:MM:SS.uuu |
| 38 | OrderQty | Yes | float | Order size | -- |
| 1138 | DisplayQty | No | float | Maximum qty displayed for iceberg orders; minimum: 1/15 of order qty | -- |
| 40 | OrderType | Yes | char | Execution model | `1`=Market, `2`=Limit, `3`=Stop-loss, `4`=Stop-loss-limit, `R`=Take-profit, `T`=Take-profit-limit, `U`=Trailing-stop, `V`=Trailing-stop-limit |
| 59 | TimeInForce | Yes | string | Order expiration specification | `1`=GTC, `3`=IOC, `4`=FOK, `6`=GTD |
| 44 | Price | Conditional | float | Limit price in quote currency. Required when OrderType = Limit/Stop-Loss-Limit/Take-Profit-Limit/Trailing-stop-limit | -- |
| 99 | StopPx | Conditional | float | Trigger price in quote currency. Required when OrderType = Stop-Loss/Take-Profit/Stop-Loss-Limit/Trailing-stop/Trailing-stop-limit | -- |
| 18 | ExecInst | No | char | Post-Only safeguard option | `P`=Post-Only |
| 62 | ValidUntilTime | No | string | Engine rejection deadline; 2-60 seconds future | Format: YYYYMMDD-HH:MM:SS.uuu |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Example

```
8=FIX.4.4|9=181|35=G|34=3|49=damien_dlt|52=20240625-08:57:05.000|56=KRAKEN-TRD|11=1719305825|37=OTHB2F-BNGUH-2CMLPT|38=0.2|40=2|41=1719305784|44=71000|54=1|55=BTC/USD|59=1|60=20240625-08:57:05.113|10=249|
```

## Notes

- Post-Only orders cancel if they would take liquidity upon arrival.
- Iceberg orders require DisplayQty specification (minimum threshold: 1/15 of total order quantity).
