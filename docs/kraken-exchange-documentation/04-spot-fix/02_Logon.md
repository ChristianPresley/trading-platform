# Logon

> Source: https://docs.kraken.com/api/docs/fix-api/logon-fix

## Overview

The Logon message must be the first message sent by the Firm that needs to initiate a FIX session with exchange. It serves as the authentication mechanism for FIX session establishment.

**FIX Message Type:** `A` (Logon)

## Message Fields

| Tag | Field Name | Required | Type | Description | Valid Values |
|---|---|---|---|---|---|
| header | -- | Yes | -- | FIX message header | MsgType: A |
| 98 | EncryptMethod | Yes | integer | Encryption method indicator | `0` (None) |
| 108 | HeartBtInt | Yes | integer | Heartbeat interval in seconds | Recommended: `60` |
| 109 | ClientID | No | integer | Connection association identifier | -- |
| 141 | ResetSeqNumFlag | No | boolean | Reset sequence numbers flag | `true`, `false` |
| 553 | UserName | Conditional | string | API Key (Trading Logon only) | -- |
| 554 | Password | Conditional | string | Generated authentication password | -- |
| 8674 | CancelOrdersOnDisconnect | No | integer | Order cancellation behavior | `0`=cancel all, `1`=cancel none |
| 5025 | Nonce | Conditional | string | Milliseconds since epoch timestamp (Trading Logon only) | -- |
| 5030 | ForceResetClOrdID | No | boolean | Reset ClOrdID sequence on relogon | `Y`, `N` |
| 5051 | Rebased | Conditional | boolean | Token vs. equity specification (trading xstocks only) | `Y`, `N` |
| trailer | -- | Yes | -- | FIX message trailer | -- |

## Password Generation

The password requires a specific cryptographic computation:

```
base64(HMAC-512(API_secret, SHA256(Message-Input + Nonce)))
```

### Message-Input Composition

Fields separated by FIX SOH character (ASCII 01):

- `35=A`
- `34=MsgSeqNum`
- `49=SENDERCOMPID`
- `56=TARGETCOMPID`
- `553=API_KEY`

### Critical Notes

- API Secret must be base64 decoded before HMAC-512 operation.
- Nonce represents milliseconds since Unix Epoch.
- Server validates nonce is within 5 seconds of current server time.
- Nonce must be strictly increasing.

## Examples

### Market Data Logon

```
8=FIX.4.4|9=76|35=A|49=MYCOMPID|56=KRAKEN-MD|34=1|52=20230707-13:31:03.000|98=0|108=60|141=Y|10=011|
```

### Trading Logon

```
8=FIX.4.4|9=250|35=A|49=MYCOMPID|56=KRAKEN-TRD|34=1|52=20230707-13:21:15.000|98=0|108=60|141=N|553=<API_KEY>|554=<PASSWORD>|5025=1688736075072|10=215|
```

## Session Response Behavior

- **Successful logon:** Exchange responds with Logon message (credentials not echoed for Trading sessions).
- **Failed logon:** Kraken sends Logout message with reason or closes connection without logout.
