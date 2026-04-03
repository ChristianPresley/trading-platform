# Reject - Business Level

> Source: https://docs.kraken.com/api/docs/fix-api/reject-business_level-fix

## Overview

If Kraken needs to reject a message before it reaches the Trading engine and gets an orderId, the order or cancellation will be rejected using a Business level reject.

**FIX Message Type:** `j` (BusinessMessageReject)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: j |
| 45 | RefSeqNum | Yes | integer | Sequence number of the rejected message | -- |
| 372 | RefMsgType | Yes | char | The MsgType of the FIX message being referenced | -- |
| 379 | BusinessRejectRefID | Yes | string | Value of the CLORDID field on the rejected message | -- |
| 380 | BusinessRejectReason | Yes | integer | Code identifying rejection reason | See below |
| 58 | Text | No | string | Full description for rejection | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## BusinessRejectReason Values (Tag 380)

| Value | Reason |
|---|---|
| 0 | Others |
| 1 | Unknown ID |
| 2 | Unknown Instrument |
| 3 | Unsupported Message Type |
| 4 | Application not available |
| 5 | Conditionally Required Field Missing |
| 6 | Not Authorized |
| 101 | Unknown order |
| 104 | Order too old |

## Example

```
8=FIX.4.4|9=134|35=j|34=16|49=KRAKEN-TRD|52=20230707-14:05:37.805|56=MYCOMPID|45=0|58=1688738737 : EOrder:Insufficient funds|372=D|379=1688738737|380=0|10=149|
```
