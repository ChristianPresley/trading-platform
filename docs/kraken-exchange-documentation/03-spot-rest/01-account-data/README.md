# Account Data

Spot exchange account data endpoints for balances, orders, trades, ledgers, and data exports.

## Contents

1. [Add Export](01_Add-Export.md) — Request an export of trades or ledgers.
   - `POST /0/private/AddExport`
2. [Export Status](02_Export-Status.md) — Get the status of requested data exports.
   - `POST /0/private/ExportStatus`
3. [Get Account Balance](03_Get-Account-Balance.md) — Retrieve all cash balances, net of pending withdrawals.
   - `POST /0/private/Balance`
4. [Get Api Key Info](04_Get-Api-Key-Info.md) — Retrieve information about the API key used for the request.
   - `POST /0/private/GetApiKeyInfo`
5. [Get Closed Orders](05_Get-Closed-Orders.md) — Retrieve information about orders that have been filled or cancelled.
   - `POST /0/private/ClosedOrders`
6. [Get Credit Lines](06_Get-Credit-Lines.md) — Retrieve all credit line details for VIP accounts.
   - `POST /0/private/CreditLines`
7. [Get Extended Balance](07_Get-Extended-Balance.md) — Retrieve extended account balances including credits and held amounts.
   - `POST /0/private/BalanceEx`
8. [Get Ledgers Info](08_Get-Ledgers-Info.md) — Retrieve information about specific ledger entries by ID.
   - `POST /0/private/QueryLedgers`
9. [Get Ledgers](09_Get-Ledgers.md) — Retrieve ledger entries, 50 results at a time, most recent by default.
   - `POST /0/private/Ledgers`
10. [Get Open Orders](10_Get-Open-Orders.md) — Retrieve information about currently open orders.
    - `POST /0/private/OpenOrders`
11. [Get Open Positions](11_Get-Open-Positions.md) — Get information about open margin positions.
    - `POST /0/private/OpenPositions`
12. [Get Order Amends](12_Get-Order-Amends.md) — Retrieve an audit trail of amend transactions on an order.
    - `POST /0/private/OrderAmends`
13. [Get Orders Info](13_Get-Orders-Info.md) — Retrieve information about specific orders.
    - `POST /0/private/QueryOrders`
14. [Get Trade Balance](14_Get-Trade-Balance.md) — Retrieve collateral balances, margin position valuations, equity, and margin level.
    - `POST /0/private/TradeBalance`
15. [Get Trade History](15_Get-Trade-History.md) — Retrieve trade/fill history, 50 results at a time.
    - `POST /0/private/TradesHistory`
16. [Get Trades Info](16_Get-Trades-Info.md) — Retrieve information about specific trades/fills.
    - `POST /0/private/QueryTrades`
17. [Get Trade Volume](17_Get-Trade-Volume.md) — Get 30-day USD trading volume and resulting fee schedule.
    - `POST /0/private/TradeVolume`
18. [Remove Export](18_Remove-Export.md) — Delete an exported trades/ledgers report.
    - `POST /0/private/RemoveExport`
19. [Retrieve Export](19_Retrieve-Export.md) — Retrieve a processed data export.
    - `POST /0/private/RetrieveExport`
