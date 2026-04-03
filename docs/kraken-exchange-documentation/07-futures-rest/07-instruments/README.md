# Instruments

Instrument specification and status endpoints -- listed markets, indices, and volatility details.

## Contents

1. [Get Instruments](01_Get-Instruments.md) -- Return specifications for all currently listed markets and indices.
   - `GET /derivatives/api/v3/instruments`
2. [Get Trading Instruments](02_Get-Trading-Instruments.md) -- Return specifications for all currently accessible markets and indices (authenticated).
   - `GET /derivatives/api/v3/trading/instruments`
3. [Get Instrument Status List](03_Instruments-Status.md) -- Return price dislocation and volatility details for all markets.
   - `GET /derivatives/api/v3/instruments/status`
4. [Get Instrument Status](04_Instrument-Status.md) -- Return price dislocation and volatility details for a specific market.
   - `GET /derivatives/api/v3/instruments/{symbol}/status`
