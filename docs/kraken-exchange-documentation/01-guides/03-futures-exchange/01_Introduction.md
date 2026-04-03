# Futures Introduction

> Source: https://docs.kraken.com/api/docs/guides/futures-introduction

## Futures Platform

The Kraken Futures platform offers APIs through HTTP (REST), Websockets (WS), and FIX protocols. The REST API enables secure account access for:

- Requesting current or historical price information
- Checking account balance and PnL
- Viewing margin parameters and liquidation thresholds
- Placing or canceling orders individually or in batch
- Viewing open orders, positions, or trade history
- Requesting digital asset withdrawals

The WebSocket API provides real-time data channels, eliminating the need for periodic requests on frequently changing information.

## Conventions and Definitions

### Server Time

The server time is in Coordinated Universal Time (UTC).

### Unique Identifiers

Unique identifiers follow the Universally Unique Identifier standard. Example: `c18f0c17-9971-40e6-8e5b-10df05d422f0`

### Dates and Times

The API requires dates and time arguments in the ISO8601 datetime format and returns all dates and times in the same format. Format: `<yyyy>-<mm>-<dd>T<HH>:<MM>:<SS>.<sss>Z`

### Symbols

The system uses ticker symbols for cash accounts, margin accounts, futures contracts, and indices:

| Symbol | Description |
|--------|-------------|
| `xbt` | Bitcoin |
| `fi_xbtusd` | Bitcoin-Dollar Futures Margin Account |
| `fi_xbtusd_180615` | Bitcoin-Dollar Futures, maturing 15 June 2018 |
| `in_xbtusd` | Bitcoin-Dollar Real-Time Index |
| `rr_xbtusd` | Bitcoin-Dollar Reference Rate |

## Generate API Keys

To generate API keys:

1. Sign in to your futures account
2. Click your name in the upper-right corner
3. Select "Settings" from the drop-down menu
4. Select the "Create Key" tab in the API panel
5. Choose access levels:
   - **General API:** No Access, Read Only, or Full Access
   - **Withdrawal API:** No Access or Full Access
6. Press "Create Key"
7. Record your Public and Private keys in a safe location

**Important:** The private key is shown only once! You cannot go back and view it again later. API keys should never be shared.

### Limits

Up to 50 keys can be created with distinct nonces.

## API Testing Environment

A demo environment is available at `https://demo-futures.kraken.com/` for testing without production credentials. Sign up to receive auto-generated email and password credentials.

The WebSocket and REST API code on this environment is identical to the live production code in terms of the feeds/endpoints and the response structure.

The primary difference is the base URL: use `demo-futures.kraken.com` instead of `futures.kraken.com`.

### Example

WebSocket demo subscription: `wss://demo-futures.kraken.com/ws/v1`

REST API demo endpoint: `https://demo-futures.kraken.com/derivatives/api/v3/tickers`

## API URLs

REST API endpoints:

- `https://futures.kraken.com/derivatives/api/v3/`
- `https://futures.kraken.com/api/history/v2/`
- `https://futures.kraken.com/api/charts/v1/`

WebSocket connection: `wss://futures.kraken.com/ws/v1`

## Sample Implementations

Sample code is available at `https://github.com/cryptofacilities` in Java, Python, C#, and Visual Basic .NET.
