# Order Cancel Request

> Source: https://docs.kraken.com/api/docs/fix-api/ocr-fix

## Overview

Cancel a single GTD or GTC order. Successful cancellations return an execution report with OrdStatus set to `4` (Cancelled). Failed attempts generate a business-level rejection message.

**FIX Message Type:** `F`

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: F |
| 11 | ClOrdID | Yes | string | Unique identifier of the order; supports ever-increasing positive numbers (microsecond timestamps, max 18 chars) or timestamp-first v4 UUIDs with 10-microsecond granularity | Example: `1623448294234000` or `1b4e28ba-2fa1-11d2-883f-0016d3cca427` |
| 37 | OrderID | Conditional | string | OrderId needs to match the one received on the ExecutionReports | -- |
| 41 | OrigClordid | Conditional | string | Reference the last ClordId used. If both OrderId and OrigClordid are present then only the OrderID will be used | -- |
| 54 | Side | Yes | integer | Direction of the order | `1`=Buy, `2`=Sell |
| 55 | Symbol | Yes | string | Trading pair in BASE/QUOTE format | Example: BTC/USD |
| 60 | TransactTime | Yes | string | Time of order cancellation expressed in UTC | Format: YYYYMMDD-HH:MM:SS.uuu |
| trailer | -- | Yes | -- | FIX message trailer | -- |

**Condition:** One of ClOrdID (via OrigClordid) OR OrderID is required at least for the cancellation to be accepted.

## Example

```
8=FIX.4.4|9=137|35=F|34=5|49=MYCOMPID|52=20230707-13:59:00.000|56=KRAKEN-TRD|11=1688738340|37=OKWUQF-YPJM2-DTAJHH|54=1|55=BTC/USD|60=20230707-13:59:00.023|10=080|
```
