# User Trading

Authenticated methods for order management via WebSocket v2.

## Contents

1. [Add Order](01_Add-Order.md) -- Submit a single order with support for various order types, TIF, conditional close, iceberg, and margin.
   - Method: `add_order`
2. [Amend Order](02_Amend-Order.md) -- Modify order parameters in-place while preserving identifiers and queue priority.
   - Method: `amend_order`
3. [Batch Add](03_Batch-Add.md) -- Submit 2-15 orders for a single pair in one request with atomic pre-validation.
   - Method: `batch_add`
4. [Batch Cancel](04_Batch-Cancel.md) -- Cancel 2-50 orders in a single request by a range of identifiers.
   - Method: `batch_cancel`
5. [Cancel All](05_Cancel-All.md) -- Cancel all open orders including untriggered and resting orders.
   - Method: `cancel_all`
6. [Cancel on Disconnect](06_Cancel-On-Disconnect.md) -- Dead Man's Switch that auto-cancels all orders if a countdown timer expires.
   - Method: `cancel_all_orders_after`
7. [Cancel Order](07_Cancel-Order.md) -- Cancel one or more open orders by client or Kraken identifiers.
   - Method: `cancel_order`
8. [Edit Order](08_Edit-Order.md) -- Modify live order by cancelling and recreating with new parameters (prefer `amend_order` instead).
   - Method: `edit_order`
