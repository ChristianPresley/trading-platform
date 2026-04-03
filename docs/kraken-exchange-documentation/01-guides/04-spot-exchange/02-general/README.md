# General

Cross-protocol trading concepts and reference material for the Kraken Spot Exchange.

## Contents

1. [Atomic Amends](01_Atomic-Amends.md) — In-place order modification that preserves identifiers, fill history, and queue priority, replacing the legacy cancel-new edit model.
2. [Client Order Identifiers](02_Client-Order-Identifiers.md) — Using cl_ord_id for client-side order tracking: UUID and free-text formats, uniqueness enforcement, and comparison with Kraken ID and userref.
3. [Errors](03_Errors.md) — Comprehensive reference of Spot Exchange error codes covering authentication, order validation, margin, rate limits, and service availability.
4. [Example Clients](04_Example-Clients.md) — Official and third-party API client libraries (Python, Go, C++, Julia) with code examples and usage disclaimers.
5. [Level 3 Market Data](05_Level-3-Market-Data.md) — Individual order visibility in the book: queue priority, resting time, fill probability analysis, and REST/WebSocket access via the level3 channel.
6. [Rate Limits](06_Rate-Limits.md) — Per-pair transaction rate counters with tier-based decay, open order limits, and penalty increments by operation type across REST, WebSocket, and FIX.
