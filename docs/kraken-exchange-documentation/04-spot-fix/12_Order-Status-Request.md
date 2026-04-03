# Order Status Request (Spot Only)

> Source: https://docs.kraken.com/api/docs/fix-api/osr-fix

## Overview

Obtain information about current order status on Kraken exchange. The response is an execution report with ExecType = `I`, where Tag 39 indicates the current order status. Applicable to Spot trading only.

**FIX Message Type:** `H`

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: H |
| 11 | ClOrdID | Yes | string | Unique identifier of the order; supports ever-increasing positive numbers (max 18 characters, e.g., microsecond timestamps) or timestamp-first v4 UUIDs with 10 microsecond max granularity | -- |
| 37 | OrderID | Yes | string | OrderId needs to match the one received on the ExecutionReports | -- |
| 55 | Symbol | Yes | string | Pair in the format BASE/QUOTE | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Example

```
8=FIX.4.4|9=137|35=H|34=5|49=MYCOMPID|52=20230707-13:59:00.000|56=KRAKEN-TRD|11=1688738340|37=OKWUQF-YPJM2-DTAJHH|54=1|55=BTC/USD|60=20230707-13:59:00.023|10=080|
```

## Notes

- Response message type: Execution Report with ExecType = `I`.
- Tag 39 (OrdStatus) in the response indicates the current order status.
