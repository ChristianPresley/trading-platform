# Order Mass Cancel Request

> Source: https://docs.kraken.com/api/docs/fix-api/omcr-fix

## Overview

Cancel all open orders including untriggered orders and orders resting in the book. The system responds with execution reports for each canceled order.

**FIX Message Type:** `q`

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: q |
| 11 | ClOrdID | Yes | string | Unique identifier of the order; supports ever-increasing positive numbers (max 18 chars) or timestamp-first v4 UUIDs | Example: `1623448294234000` or `1b4e28ba-2fa1-11d2-883f-0016d3cca427` |
| 60 | TransactTime | Yes | string | Time of order cancellation in UTC | Format: YYYYMMDD-HH:MM:SS.uuu |
| 530 | MassCancelRequestType | Yes | integer | Specifies scope of cancellation | `1`=Cancel orders by Symbol, `6`=Cancel all session orders, `7`=Cancel all orders by SenderCompID |
| 55 | Symbol | Conditional | string | The pair in format BASE/QUOTE; required when MassCancelRequestType=1 | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Example

```
8=FIX.4.4|9=115|35=q|34=6|49=MYCOMPID|52=20230707-13:59:36.000|56=KRAKEN-TRD|11=1688738376|55=BTC/USD|60=20230707-13:59:36.422|530=1|10=193|
```

## Notes

- Response confirmation occurs via execution reports with canceled status for each affected order.
