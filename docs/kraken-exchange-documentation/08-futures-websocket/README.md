# Futures Websocket

WebSocket feeds for Kraken Futures -- real-time order book, trades, positions, and account updates.

## Contents

1. [Account Log](01_Account-Log.md) -- Tracks all account activity including trades, funding rate changes, and balance updates.
   - Feed: `account_log`
2. [Balances](02_Balances.md) -- Balance information for holding, single collateral, and multi-collateral wallets with snapshot and delta updates.
   - Feed: `balances`
3. [Book](03_Book.md) -- Order book snapshots and incremental delta updates for futures products.
   - Feed: `book`
4. [Challenge](04_Challenge.md) -- Returns a challenge for the authentication handshake, to be signed with the API secret.
   - Event: `challenge`
5. [Fills](05_Fills.md) -- Trade fill information with snapshot of recent fills and real-time updates.
   - Feed: `fills`
6. [Heartbeat](06_Heartbeat.md) -- Periodic heartbeat messages for monitoring connection health.
   - Feed: `heartbeat`
7. [Notifications](07_Notifications.md) -- Market announcements, maintenance windows, settlement notices, and other platform notifications.
   - Feed: `notifications_auth`
8. [Open Orders](08_Open-Orders.md) -- Snapshot and real-time delta updates of all user open orders.
   - Feed: `open_orders`
9. [Open Orders Verbose](09_Open-Orders-Verbose.md) -- Extended open orders feed with additional detail on failed post-only orders.
   - Feed: `open_orders_verbose`
10. [Open Positions](10_Open-Position.md) -- Full snapshot and real-time updates of user open positions.
    - Feed: `open_positions`
11. [Ticker Lite](11_Ticker-Lite.md) -- Lightweight ticker with fewer fields, throttled to 1-second updates.
    - Feed: `ticker_lite`
12. [Ticker](12_Ticker.md) -- Full ticker information for listed products, throttled to 1-second updates.
    - Feed: `ticker`
13. [Trade](13_Trade.md) -- Executed trade information with snapshot of recent trades and real-time updates.
    - Feed: `trade`
