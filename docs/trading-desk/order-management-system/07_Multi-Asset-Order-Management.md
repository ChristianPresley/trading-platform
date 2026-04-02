## 8. Multi-Asset Order Management

### 8.1 Equities

Standard equity order fields:

| Field | FIX Tag | Notes |
|-------|---------|-------|
| Symbol | 55 | Ticker symbol |
| SecurityIDSource | 22 | `1` (CUSIP), `2` (SEDOL), `4` (ISIN), `8` (Exchange Symbol) |
| SecurityID | 48 | Identifier value |
| SecurityExchange | 207 | Primary listing exchange MIC |
| Currency | 15 | Trading currency |

Equity-specific considerations:
- Lot sizes (round lot = 100 shares in US; varies internationally)
- Tick size tables (pilot programs, price tiers)
- Short sale rules and locate management
- Reg NMS order protection
- LULD (Limit Up/Limit Down) price bands
- Trading halts (MWCB, regulatory, news pending)
- Corporate actions impact on open orders

### 8.2 Fixed Income

Fixed income orders differ significantly from equities:

| Field | FIX Tag | Notes |
|-------|---------|-------|
| SecurityType | 167 | `GOVT`, `CORP`, `MUNI`, `MBS`, `ABS`, etc. |
| MaturityDate | 541 | Bond maturity |
| CouponRate | 223 | Annual coupon rate |
| Price | 44 | Can be price (dirty or clean), yield, or spread |
| YieldType | 235 | `AFTERTAX`, `ANNUAL`, `MATURITY`, `WORST`, `SPREAD` |
| Yield | 236 | Yield value if ordering by yield |
| OrderQty | 38 | Face value (notional), not number of bonds |

Fixed income-specific considerations:
- OTC market: most bonds trade off-exchange via RFQ (Request for Quote) or voice
- RFQ workflow:
  1. Send RFQ to N dealers (FIX MsgType `AH`)
  2. Receive quotes (FIX MsgType `S`)
  3. Accept best quote (converts to executable order)
- Price types: clean price, dirty price, yield, spread to benchmark, discount margin
- Quantity is in face/par value (e.g., $1,000,000 face), not units
- Accrued interest calculations
- Settlement conventions (T+1 for US Treasuries, T+2 for corporates)
- Minimum denomination and increment sizes

### 8.3 Foreign Exchange (FX)

FX orders use distinct conventions:

| Field | FIX Tag | Notes |
|-------|---------|-------|
| Symbol | 55 | Currency pair (e.g., `EUR/USD`) |
| Currency | 15 | Deal currency |
| SettlCurrency | 120 | Settlement currency |
| FutSettDate | 64 | Value date |
| OrderQty | 38 | Amount in deal currency |
| OrdType | 40 | `D` (Previously Quoted) for RFQ fills |

FX-specific considerations:
- Spot, forward, swap, NDF (non-deliverable forward) order types
- Dealing in "amount currency" vs. "counter currency"
- Streaming price model: FX prices are typically streamed from liquidity providers, not posted on a central book
- Last-look: LPs may have a last-look window to reject trades after execution
- Value date management (T+2 for spot, broken dates for forwards)
- Netting and aggregation for settlement
- Multi-dealer competition (request streaming prices from multiple LPs)

### 8.4 Listed Derivatives (Futures and Options)

| Field | FIX Tag | Notes |
|-------|---------|-------|
| SecurityType | 167 | `FUT`, `OPT`, `FOP` (Future Option) |
| MaturityMonthYear | 200 | Contract expiry (e.g., `202403`) |
| StrikePrice | 202 | For options |
| PutOrCall | 201 | `0` (Put), `1` (Call) |
| CFICode | 461 | ISO 10962 classification |
| UnderlyingSymbol | 311 | Underlying instrument |
| ContractMultiplier | 231 | Contract size (e.g., 100 for equity options) |

Derivatives-specific considerations:
- Margin requirements (initial and maintenance margin)
- Contract specifications: multiplier, tick size, expiry rules
- Exercise and assignment workflows
- Spread/combo orders (calendar spreads, straddles, strangles, butterflies)
- Position limits (exchange-imposed, regulatory)
- Options pricing: Greeks (delta, gamma, vega, theta) for risk checks
- Auto-exercise rules at expiration
- Series creation: new strikes/expiries listed dynamically

### 8.5 Commodities

Additional considerations beyond standard derivatives:
- Physical delivery vs. cash settlement
- Warehouse receipts and delivery notices
- Position limits specific to physical commodities (CFTC limits)
- Intercommodity spreads
- Seasonal patterns affecting order management
- Energy-specific protocols (e.g., ICE, CME Globex)

### 8.6 Multi-Asset OMS Architecture

A multi-asset OMS must normalize across asset classes:

```
                    +-------------------+
                    | Unified Order API |
                    +--------+----------+
                             |
          +------------------+------------------+
          |         |         |        |        |
     +----v---+ +---v---+ +--v--+ +---v---+ +--v---+
     |Equities| |Fixed  | | FX  | |Derivs | |Crypto|
     |Handler | |Income | |Hndlr| |Handler| |Hndlr |
     +----+---+ |Handler| +--+--+ +---+---+ +--+---+
          |     +---+---+    |        |        |
          v         v        v        v        v
      [Venue    [RFQ     [LP      [Exchange [Exchange
       Gateway]  Engine]  Stream]  Gateway]  Gateway]
```

Each asset class handler manages:
- Asset-specific validation rules
- Asset-specific order types and TIF options
- Price format normalization (decimals, fractions, 32nds, ticks)
- Quantity normalization (shares, face value, contracts, lots)
- Settlement convention differences
