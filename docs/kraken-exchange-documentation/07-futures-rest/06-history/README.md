# History

Account and market history endpoints -- execution events, order events, trigger events, and public market data.

## Contents

1. [Account History](01_Account-History.md) -- Overview of private account history endpoints (executions, orders, triggers).
   - `GET /api/history/v2/executions`, `GET /api/history/v2/orders`, `GET /api/history/v2/triggers`
2. [Get Execution Events](02_Get-Execution-Events.md) -- List paginated trade executions for the authenticated account.
   - `GET /api/history/v2/executions`
3. [Get Order Events](03_Get-Order-Events.md) -- List paginated order lifecycle events for the authenticated account.
   - `GET /api/history/v2/orders`
4. [Get Public Execution Events](04_Get-Public-Execution-Events.md) -- List paginated public trade executions for a specific market.
   - `GET /api/history/v2/market/{tradeable}/executions`
5. [Get Public Order Events](05_Get-Public-Order-Events.md) -- List paginated public order events for a specific market.
   - `GET /api/history/v2/market/{tradeable}/orders`
6. [Get Public Price Events](06_Get-Public-Price-Events.md) -- List paginated mark price events for a specific market.
   - `GET /api/history/v2/market/{tradeable}/price`
7. [Get Trigger Events](07_Get-Trigger-Events.md) -- List paginated trigger events (stops, take profits, trailing stops) for the authenticated account.
   - `GET /api/history/v2/triggers`
8. [Market History](08_Market-History.md) -- Overview of public market history endpoints (executions, orders, prices).
   - `GET /api/history/v2/market/{tradeable}/...`
