# Header & Trailer (Session)

> Source: https://docs.kraken.com/api/docs/fix-api/session-fix

## Overview

A standard header must be present at the start of every message in both directions. All messages require SenderCompID and TargetCompID values, which are provided during onboarding. Based on FIX 4.4 specification.

## Standard Header Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| 8 | BeginString | Yes | string | Protocol identifier | `FIX.4.4` |
| 9 | BodyLength | Yes | integer | Character count from after BodyLength field through checksum delimiter | -- |
| 35 | MsgType | Yes | char | Identifies message category | Varies by message |
| 34 | MsgSeqNum | Yes | integer | Sequential message counter | -- |
| 52 | SendingTime | Yes | string | UTC transmission timestamp | Format: YYYYMMDD-HH:MM:SS.uuu |
| 49 | SenderCompID | Yes | string | Originating party identifier | Provided by Kraken |
| 56 | TargetCompID | Yes | string | Receiving party identifier | Provided by Kraken |
| 122 | OrigSendingTime | Conditional | string | Original transmission time for retransmissions | Format: YYYYMMDD-HH:MM:SS.uuu |
| 43 | PossDupFlag | No | boolean | Retransmission indicator | `true`, `false` |

## Standard Trailer

| Tag | Field Name | Required | Type | Description |
|---|---|---|---|---|
| 10 | Checksum | Yes | string | Final message field; cryptographic validation |

## Notes

- OrigSendingTime (tag 122) is required for retransmission of messages and defaults to SendingTime when unavailable.
- SenderCompID and TargetCompID are assigned during Kraken onboarding.
