# User Data

Authenticated channels for streaming user account and execution data in real time.

## Contents

1. [Balances](01_Balances.md) -- Streams asset balances and ledger transactions with snapshot and delta updates.
   - Channel: `balances`
2. [Executions](02_Executions.md) -- Order status and trade execution events, combining v1's `openOrders` and `ownTrades` into a single channel.
   - Channel: `executions`
