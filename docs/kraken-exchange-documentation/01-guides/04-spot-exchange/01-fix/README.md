# FIX

Guides for Kraken's FIX 4.4 protocol: session setup, authentication, and order book integrity verification.

## Contents

1. [Authentication](01_Authentication.md) — Two-layer FIX authentication: SenderCompID (Tag 49) logon plus HMAC-SHA512 password generation for private trading endpoints.
2. [Checksums](02_Checksums.md) — CRC32 order book checksum calculation from Market Data Incremental Refresh messages, using price/quantity precision from InstrumentListRequest.
3. [Introduction](03_Introduction.md) — FIX protocol overview: supported message types, co-located low-latency access, guaranteed delivery, UAT sandbox, and onboarding requirements.
