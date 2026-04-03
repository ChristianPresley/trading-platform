# Reject - Session Level

> Source: https://docs.kraken.com/api/docs/fix-api/reject-session_level-fix

## Overview

Kraken will disregard garbled, unparseable messages or those failing a data integrity check using session-level rejection.

**FIX Message Type:** `3` (Reject)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: 3 |
| 45 | RefSeqNum | Yes | integer | Sequence number of the rejected message | -- |
| 371 | RefTagID | Conditional | char | Tag number causing rejection; only when rejected due to specific tag | -- |
| 372 | RefMsgType | Yes | char | MsgType (tag 35) of referenced FIX message | -- |
| 373 | SessionRejectReason | Yes | integer | Reason code per standard FIX 4.4 specification | Refer to FIX specification |
| 58 | Text | No | string | Full description for rejection | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Example

```
8=FIX.4.4|9=104|35=3|34=14|49=KRAKEN-TRD|52=20230707-14:04:24.689|56=MYCOMPID|45=12|58=Missing Mandatory Field: Side (54)|10=159
```

This example demonstrates rejection due to "Missing Mandatory Field: Side (54)" with RefSeqNum of 12.
