# REST

Guides for the Kraken Spot REST API: endpoint organization, authentication, earn products, and rate limiting.

## Contents

1. [Authentication](01_Authentication.md) — API-Key/API-Sign header construction with HMAC-SHA512 signing, nonce management, and optional 2FA for private Spot REST endpoints.
2. [Earn](02_Earn.md) — Yield-generating product API (replacing legacy /staking): strategies, allocations, deallocations, balance queries, and geo-restriction handling.
3. [Introduction](03_Introduction.md) — Spot REST API organization (market data, trading, funding, earn, subaccounts), request encoding options, and JSON response structure.
4. [Rate Limits](04_Rate-Limits.md) — Per-key call counter with tier-based maximums (15-20) and decay rates, separate matching engine limits, and throttle error codes.
