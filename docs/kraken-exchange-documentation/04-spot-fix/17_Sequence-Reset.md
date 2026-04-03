# Sequence Reset

> Source: https://docs.kraken.com/api/docs/fix-api/sequence-reset-fix

## Overview

Administrative message for FIX protocol session management, allowing either gap fill operations (where sequence numbers are maintained) or complete sequence resets (where the MsgSeqNum field should be disregarded).

**FIX Message Type:** `4` (SequenceReset)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: 4 |
| 123 | GapFillFlag | Yes | boolean | Indicates whether the Sequence Reset message replaces administrative or application messages that will not be resent | `Y`=Gap Fill (MsgSeqNum valid), `N`=Sequence Reset (ignore MsgSeqNum) |
| 36 | NewSeqNo | Yes | integer | Specifies the new sequence number to apply | -- |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Notes

- When GapFillFlag=`Y`, the MsgSeqNum in the header is valid and represents the sequence number being replaced.
- When GapFillFlag=`N`, the MsgSeqNum field should be disregarded and the new sequence number from tag 36 takes effect.
