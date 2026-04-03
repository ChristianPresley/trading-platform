# Spot Websockets Authentication

> Source: https://docs.kraken.com/api/docs/guides/spot-ws-auth

## Overview

The Kraken Spot WebSocket API requires authentication tokens for accessing protected endpoints.

## Authentication Token Retrieval

Clients must obtain an authentication token through the REST API's `GetWebSocketsToken` endpoint before establishing WebSocket connections.

## Token Usage

Once retrieved, the token is included in subscription messages using this format:

```json
{
  "event": "subscribe",
  "subscription": {
    "name": "ownTrades",
    "token": "WW91ciBhdXRoZW50aWNhdGlvbiB0b2tlbiBnb2VzIGhlcmUu"
  }
}
```

The token parameter works across all authenticated WebSocket endpoints throughout the connection session.

## Important Constraint

The websockets token should be used within 15 minutes of creation. This means tokens have a narrow validity window, requiring timely implementation after generation.
