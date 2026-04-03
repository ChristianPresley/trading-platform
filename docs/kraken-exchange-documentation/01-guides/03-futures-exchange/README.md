# Futures Exchange

Guides for connecting to and authenticating with the Kraken Futures API across REST and WebSocket protocols.

## Contents

1. [Introduction](01_Introduction.md) — Futures platform overview, REST/WebSocket/FIX capabilities, conventions for time/symbols/identifiers, and contract symbology.
2. [Rate Limits](02_Rate-Limits.md) — Per-endpoint cost tables for /derivatives and /history paths, budget mechanics (500 per 10 seconds), and apiLimitExceeded error handling.
3. [REST](03_Rest.md) — Futures REST authentication with APIKey/Authent/Nonce headers, HMAC-SHA512 signature computation, and recent auth changes.
4. [WebSockets](04_Websockets.md) — Signed challenge authentication for private feeds, SHA-256/HMAC-SHA512 signing, subscription management, and connection keep-alive via ping.
