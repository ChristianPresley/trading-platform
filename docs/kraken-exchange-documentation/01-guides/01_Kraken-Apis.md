# Kraken APIs

> Source: https://docs.kraken.com/api/docs/guides/global-intro

## Introduction

Kraken provides a comprehensive set of Application Programming Interfaces enabling users to execute trades, access market data, manage accounts, and embed crypto services into applications.

### Direct Trading APIs

**REST API**: HTTP-based request-response architecture suited for web applications.

**Websocket API**: Bidirectional communication over persistent connections, ideal for event-driven data without polling.

**FIX API**: "Financial Information eXchange" protocol favored by institutional traders for session-based key-value pair messaging.

### Embed API (B2B / B2B2C)

The Embed REST API enables partners to integrate crypto trading, portfolio management, and earn features under their own branding. Partners gain capabilities to create user accounts, execute quote-based trades, access portfolios, and receive webhook updates.

### API Selection

Each protocol offers distinct characteristics. Traders may select a single protocol or combine multiple approaches. Kraken's support article provides guidance on choosing between REST and WebSocket implementations.

## Product Coverage by API Type

| Feature | Spot REST | Spot WebSocket | Spot FIX | Futures REST | Futures WebSocket | Futures FIX |
|---------|-----------|----------------|----------|--------------|-------------------|------------|
| Market Data | Yes | Yes | Yes | Yes | Yes | Yes |
| Order Transactions | Yes | Yes | Yes | Yes | — | Yes |
| Account Data | Yes | Yes | — | Yes | Yes | — |
| Funding | Yes | — | — | Yes | — | — |
| Earn | Yes | — | — | — | — | — |
| Subaccounts | Yes | — | — | Yes | — | — |
| Charts | — | — | — | Yes | — | — |

## Futures and Spot Trading

Kraken operates separate spot and futures trading engines with distinct differences in protocols, onboarding, authentication, rate limits, and error handling.

## Infrastructure Options

**IP Whitelisting**: Traders connecting through Kraken's AWS infrastructure gain improved latency and performance.

**Colocation**: Partnership with Beeks Group offers hosted infrastructure near API endpoints. Dedicated URLs required.

### Colocation Endpoint URLs

- **Spot WebSocket**: `colo-london.vip-ws.kraken.com`, `colo-london.vip-ws-auth.kraken.com`
- **FIX API**: `colo-london.vip-fix.kraken.com`
- **Futures REST**: `colo-london.vip.futures.kraken.com`
- **Futures WebSocket**: `wss://colo-london.vip.futures.kraken.com/ws/v1`

## Legal Terms

API usage requires acceptance of "Kraken Terms & Conditions" and "Privacy Notice." Non-personal commercial use of public endpoint data requires prior written permission via marketdata@kraken.com.
