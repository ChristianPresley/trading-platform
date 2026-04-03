# Spot Websockets Introduction

> Source: https://docs.kraken.com/api/docs/guides/spot-ws-intro

## Connection Details

Kraken provides websocket endpoints for spot trading across primary and beta environments:

| Environment | API | Public Data | Private Data |
|---|---|---|---|
| Primary | v2 | `wss://ws.kraken.com/v2` | `wss://ws-auth.kraken.com/v2` |
| Primary | v1 | `wss://ws.kraken.com` | `wss://ws-auth.kraken.com` |
| Beta | v2 | `wss://beta-ws.kraken.com/v2` | `wss://beta-ws-auth.kraken.com/v2` |
| Beta | v1 | `wss://beta-ws.kraken.com` | `wss://beta-ws-auth.kraken.com` |

The "primary" environment represents the production platform, while "beta" receives software updates ahead of the main release and may be necessary to access newly launched features.

## Websockets Versions

Two websocket versions are available for spot trading. Version 2 introduces design improvements over version 1, including cleaner structures and reduced ambiguities. While v1 remains supported, future enhancements will focus on v2.

## Websockets v2 Improvements

### Cleaner Document Structure

The redesigned v2 includes:

- "FIX-like design" aligned with financial industry standards
- Pair symbols in readable format (e.g., "BTC/USD")
- RFC3339 formatted timestamps like "2021-05-11T19:47:09.896860Z"
- Prices and quantities as number types for straightforward processing
- Normalized JSON payloads with consistent dictionary keys
- Enhanced human and machine readability

### Order Transactions and Requests

Requests support an optional client-specified integer identifier (`req_id`) for matching responses. Responses include standardized fields: `time_in`, `time_out`, `success`, `result`, and `error`.

### Channels

Additional event-driven streams available in v2:

- `level3`: Order book constituent data with granular detail
- `balance`: Client asset balances and ledger transactions

## Frequently Asked Questions

**Connection Timeout Issues**: Servers close inactive connections after approximately one minute. Send periodic requests like ping to maintain connectivity.

**XBT/USD Not Found**: The v2 API uses "BTC" instead of "XBT" for bitcoin. Access supported pairs through the instrument channel.

**EOrder:Reduce Only:Non-PC Error**: Indicates a Permitted Client certification issue, particularly relevant for Ontario-based traders.

## General Considerations

Key requirements for all connections include:

- Transport Layer Security (TLS) with Server Name Indication (SNI) is mandatory
- All messages use JSON encoding
- Timestamps lack uniqueness guarantees and shouldn't serve as transaction identifiers
- At least one private message subscription maintains authenticated connection stability
- Cloudflare rate limits restrict reconnection attempts to approximately 150 per 10-minute rolling window per IP address, with 10-minute bans for violations

### Reconnection Strategy

After random disconnects, reconnect immediately a few times. Following maintenance or extended outages, limit reconnection attempts to once every five seconds maximum.

### Supported Instruments

- **v1**: Use REST API AssetPairs endpoint; check the `wsname` field for supported pair names
- **v2**: Use websocket instrument endpoint; the `pairs` array displays supported symbols
