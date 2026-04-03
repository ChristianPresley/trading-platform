# Prime WebSocket

WebSocket feeds for Kraken Prime institutional trading — real-time streaming data.

## Contents

1. [Balance](01_Balance.md) — Real-time account balance and available trading amounts for specified currencies.
   - Feed: `Balance`
2. [Currency Conversion](02_Currency-Conversion.md) — Stream of currency conversion rates for portfolio valuation and rate monitoring.
   - Feed: `CurrencyConversion`
3. [Order Updates](03_Order-Updates.md) — Continuous stream of order status changes and lifecycle events.
   - Feed: `Order`
4. [Ping](04_Ping.md) — Optional client-to-server ping for connectivity verification.
5. [Subscribe](05_Subscribe.md) — Primary mechanism for initiating data stream subscriptions across all channels.
