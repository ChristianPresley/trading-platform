# Spot FIX

FIX protocol messages for the Kraken spot exchange — session management, order entry, and market data.

## Contents

1. [Execution Report](01_Execution-Report.md) — Order response message for fills, status changes, and cancellations.
   - FIX MsgType: `8`
2. [Logon](02_Logon.md) — Session authentication and initialization with the exchange.
   - FIX MsgType: `A`
3. [Logout](03_Logout.md) — Initiates or confirms termination of a FIX session.
   - FIX MsgType: `5`
4. [Market Data Incremental Refresh](04_Market-Data-Incremental-Refresh.md) — Real-time updates to market data subscriptions following the initial snapshot.
   - FIX MsgType: `X`
5. [Market Data Request](05_Market-Data-Request.md) — Subscribe to market data streams for order books and/or trades.
   - FIX MsgType: `V`
6. [Market Data Request Reject](06_Market-Data-Request-Reject.md) — Rejection of a market data subscription request.
   - FIX MsgType: `Y`
7. [Market Data Snapshot Full Refresh](07_Market-Data-Snapshot-Full-Refresh.md) — Initial full market data snapshot sent in response to a subscription request.
   - FIX MsgType: `W`
8. [New Order Single](08_New-Order-Single.md) — Submit a new order covering all supported order types and time-in-force options.
   - FIX MsgType: `D`
9. [Order Cancel Replace Request](09_Order-Cancel-Replace-Request.md) — Amend a working order by changing quantities and prices (spot only).
   - FIX MsgType: `G`
10. [Order Cancel Request](10_Order-Cancel-Request.md) — Cancel a single GTC or GTD order.
    - FIX MsgType: `F`
11. [Order Mass Cancel Request](11_Order-Mass-Cancel-Request.md) — Cancel all open orders including untriggered and resting orders.
    - FIX MsgType: `q`
12. [Order Status Request](12_Order-Status-Request.md) — Query current status of an existing order (spot only).
    - FIX MsgType: `H`
13. [Reject - Business Level](13_Reject-Business-Level.md) — Rejection of a message before it reaches the trading engine.
    - FIX MsgType: `j`
14. [Reject - Session Level](14_Reject-Session-Level.md) — Rejection of garbled, unparseable, or integrity-failed messages.
    - FIX MsgType: `3`
15. [Security List](15_Security-List.md) — Instrument parameters and trading status for available pairs on the exchange.
    - FIX MsgType: `y`
16. [Security List Request](16_Security-List-Request.md) — Request a list of securities matching specified criteria.
    - FIX MsgType: `x`
17. [Sequence Reset](17_Sequence-Reset.md) — Administrative message for gap fill operations or complete sequence number resets.
    - FIX MsgType: `4`
18. [Session](18_Session.md) — Standard FIX 4.4 header and trailer fields required on every message.
19. [Trading Session Status](19_Trading-Session-Status.md) — Response providing current trading session status (spot only).
    - FIX MsgType: `h`
20. [Trading Session Status Request](20_Trading-Session-Status-Request.md) — Query market status with snapshot or continuous update options (spot only).
    - FIX MsgType: `g`
