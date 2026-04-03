# Order Management

Futures order lifecycle endpoints -- placing, editing, cancelling, and querying orders.

## Contents

1. [Cancel All Orders After](01_Cancel-All-Orders-After.md) -- Set a dead man's switch to cancel all orders after a timeout (recommended: call every 15-20s with 60s timeout).
   - `POST /derivatives/api/v3/cancelallordersafter`
2. [Cancel All Orders](02_Cancel-All-Orders.md) -- Cancel all open orders, optionally filtered by contract or margin account.
   - `POST /derivatives/api/v3/cancelallorders`
3. [Cancel Order](03_Cancel-Order.md) -- Cancel a single open order for a futures contract.
   - `POST /derivatives/api/v3/cancelorder`
4. [Edit Order](04_Edit-Order.md) -- Edit an existing order's parameters for a listed futures contract.
   - `POST /derivatives/api/v3/editorder`
5. [Get Initial Margin](05_Get-Initial-Margin.md) -- Return initial margin requirements for given order parameters.
   - `GET /derivatives/api/v3/initialmargin`
6. [Get Max Order Size](06_Get-Max-Order-Size.md) -- Return the maximum order size for a symbol and order type (multi-collateral only).
   - `GET /derivatives/api/v3/initialmargin/maxordersize`
7. [Get Open Orders](07_Get-Open-Orders.md) -- Return all open orders across all futures contracts.
   - `GET /derivatives/api/v3/openorders`
8. [Get Order Status](08_Get-Order-Status.md) -- Return status of specified orders that are open or were filled/cancelled in the last 5 seconds.
   - `POST /derivatives/api/v3/orders/status`
9. [Send Batch Order](09_Send-Batch-Order.md) -- Send, edit, and cancel multiple orders in a single batch request.
   - `POST /derivatives/api/v3/batchorder`
10. [Send Order](10_Send-Order.md) -- Send a limit, stop, take profit, or IOC order for a listed futures contract.
    - `POST /derivatives/api/v3/sendorder`
