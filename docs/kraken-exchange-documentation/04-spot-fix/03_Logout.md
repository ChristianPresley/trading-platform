# Logout

> Source: https://docs.kraken.com/api/docs/fix-api/logout-fix

## Overview

The Logout message initiates or confirms the termination of a FIX session. Disconnection without logout message exchange is treated as abnormal. Session initiators must wait for a confirming logout response before closing. Abnormal disconnection triggers cancel-on-disconnect functionality.

**FIX Message Type:** `5` (Logout)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: 5 |
| 58 | Text | No | string | Reason for the logout. This will be used to explain why a logon failed | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Example

```
8=FIX.4.4|9=59|35=5|49=MYCOMPID|56=KRAKEN-MD|34=10|52=20230707-13:40:01.000|10=229|
```

## Notes

- Always wait for the confirming Logout response before closing the connection.
- Abnormal disconnection (without Logout exchange) triggers cancel-on-disconnect behavior for any open orders.
