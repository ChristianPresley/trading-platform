# User Trading

Authenticated methods for order management via WebSocket v1.

## Contents

1. [Add Order](01_Add-Order.md) -- Submit a new order with support for various order types, time-in-force, margin, and OTO orders.
   - Event: `addOrder`
2. [Amend Order](02_Amend-Order.md) -- Modify order parameters in-place while preserving identifiers and queue priority.
   - Event: `amendOrder`
3. [Cancel All](03_Cancel-All.md) -- Cancel all open orders including partially-filled orders.
   - Event: `cancelAll`
4. [Cancel All Orders After](04_Cancel-All-Orders-After.md) -- Dead Man's Switch that auto-cancels all orders after a countdown timer expires.
   - Event: `cancelAllOrdersAfter`
5. [Cancel Order](05_Cancel-Order.md) -- Cancel one or more open orders by transaction ID.
   - Event: `cancelOrder`
6. [Edit Order](06_Edit-Order.md) -- Modify live order parameters by cancelling and recreating with new values (prefer `amendOrder` instead).
   - Event: `editOrder`
