# WebSockets

Guides for the Kraken Spot WebSocket API: token authentication, book integrity, and Level 3 checksum verification.

## Contents

1. [Authentication](01_Authentication.md) — Token-based WebSocket authentication via the GetWebSocketsToken REST endpoint, with a 15-minute token validity window.
2. [Book Checksum V1](02_Book-Checksum-V1.md) — CRC32 checksum calculation for WebSocket v1 book updates: top-10 bid/ask formatting with decimal and leading-zero stripping.
3. [Book Checksum V2](03_Book-Checksum-V2.md) — CRC32 checksum verification for WebSocket v2 book channel: aggregate price-level maintenance, depth truncation, and decimal-precision handling.
4. [Introduction](04_Introduction.md) — WebSocket connection endpoints (v1/v2, primary/beta), v2 design improvements (FIX-like structure, normalized payloads), and channel overview.
5. [Level 3 Checksum V2](05_Level3-Checksum-V2.md) — CRC32 checksum generation for the WebSocket v2 level3 channel: per-order book maintenance, precision handling, and top-10 verification.
