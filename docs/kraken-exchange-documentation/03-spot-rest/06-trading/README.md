# Trading

Endpoints for placing, modifying, and cancelling orders on the Kraken spot exchange, plus WebSocket token generation.

## Contents

1. [Add Order Batch](01_Add-Order-Batch.md) — Submit a batch of 2-15 orders for the same trading pair.
   - `POST /0/private/AddOrderBatch`
2. [Add Order](02_Add-Order.md) — Place a new order on the Kraken spot exchange.
   - `POST /0/private/AddOrder`
3. [Amend Order](03_Amend-Order.md) — Modify an open order in-place, preserving queue priority.
   - `POST /0/private/AmendOrder`
4. [Cancel All Orders After](04_Cancel-All-Orders-After.md) — Dead Man's Switch: cancel all orders after a timeout if not reset.
   - `POST /0/private/CancelAllOrdersAfter`
5. [Cancel All Orders](05_Cancel-All-Orders.md) — Cancel all open orders.
   - `POST /0/private/CancelAll`
6. [Cancel Order Batch](06_Cancel-Order-Batch.md) — Cancel multiple open orders by txid, userref, or cl_ord_id (max 50).
   - `POST /0/private/CancelOrderBatch`
7. [Cancel Order](07_Cancel-Order.md) — Cancel a particular open order by txid, userref, or cl_ord_id.
   - `POST /0/private/CancelOrder`
8. [Edit Order](08_Edit-Order.md) — Edit a live order by cancelling and creating a new one (prefer AmendOrder).
   - `POST /0/private/EditOrder`
9. [Get Websockets Token](09_Get-Websockets-Token.md) — Get an authentication token for the Kraken WebSockets API.
   - `POST /0/private/GetWebSocketsToken`
