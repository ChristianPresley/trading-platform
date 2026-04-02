## Account Tiers and Verification

### Verification Levels

| Level | Requirements | Capabilities |
|-------|-------------|-------------|
| **Starter** | Email, name, DOB, country, phone | Crypto deposit/withdraw/trade only. Limited fiat. |
| **Intermediate** | Government photo ID, proof of residence, SSN (US) | Full fiat funding, higher limits, margin eligibility |
| **Pro** | Additional documentation, proof of income/wealth | Highest limits, OTC desk, dedicated account management |

US residents must be **Intermediate-verified minimum** to trade due to regulatory requirements.

### Limits by Tier

| Tier | Crypto Deposits | Crypto Withdrawals | Fiat |
|------|----------------|-------------------|------|
| Starter | Unlimited | Up to $100K/day | None |
| Intermediate | Unlimited | Up to $100K/day (increasable) | Full access |
| Pro | Unlimited | Custom | Custom |

### API Rate Limits by Tier

| Tier | Max Counter | Decay Rate |
|------|-------------|------------|
| Starter | 15 | 1 per 3 seconds |
| Intermediate | 20 | 1 per 2 seconds |
| Pro | 20 | 1 per second |

Kraken recommends **WebSocket v2** for real-time data and order management to avoid REST rate-limit issues.

---

## Fee Structure

### Spot Trading Fees (30-Day Volume Tiers)

| 30-Day Volume (USD) | Maker Fee | Taker Fee |
|---------------------|-----------|-----------|
| $0 – $50,000 | 0.16% | 0.26% |
| $50,001 – $100,000 | 0.14% | 0.24% |
| $100,001 – $250,000 | 0.12% | 0.22% |
| $250,001 – $500,000 | 0.10% | 0.20% |
| $500,001 – $1,000,000 | 0.08% | 0.18% |
| $1,000,001 – $5,000,000 | 0.06% | 0.16% |
| $5,000,001 – $10,000,000 | 0.04% | 0.14% |
| $10,000,001+ | **0.00%** | 0.10% |

### Fee Calculation Rules

- **Maker**: Order adds liquidity (sits on the book) — charged maker fee
- **Taker**: Order removes liquidity (matches immediately) — charged taker fee
- **Market orders**: Always taker
- **Limit orders**: Maker if they don't fill immediately; taker if they cross the spread
- **Post-only orders** (`oflags=post`): Guaranteed maker fee — rejected if would be taker
- Fees are calculated on the **quote currency** value of the trade

### Fee Discounts

| Mechanism | Details |
|-----------|---------|
| **Volume discounts** | Higher 30-day volume = lower fees (see table above) |
| **KFEE credits** | KFEE tokens offset fees automatically if held in account |
| **Stablecoin pairs** | Some stablecoin-to-stablecoin pairs have reduced fees |

Kraken does **not** have a native exchange token for fee reduction (unlike Binance's BNB).

### Margin Fees

| Fee Type | Amount |
|----------|--------|
| Position opening fee | ~0.02% |
| Rollover fee | ~0.02% per 4-hour period |
| Plus regular trading fee | Per tier above |

### Futures Fees

| Type | Fee |
|------|-----|
| Maker | 0.02% |
| Taker | 0.05% |

Volume-based discounts apply.

---

## Supported Assets and Pairs

| Category | Count |
|----------|-------|
| Cryptocurrencies | 200+ |
| Trading pairs | 600+ (spot) |

### Major Assets

BTC, ETH, SOL, ADA, DOT, XRP, DOGE, AVAX, MATIC, LINK, UNI, AAVE, COMP, MKR, SNX, CRV, ARB, OP, SHIB, PEPE, and many more.

### Fiat Currencies

| Currency | Pairs | Deposit Methods |
|----------|-------|----------------|
| **USD** | Most extensive | Fedwire, SWIFT, ACH |
| **EUR** | Extensive | SEPA, SWIFT |
| **GBP** | Major assets | BACS, SWIFT, FPS |
| **CAD** | Select assets | Wire transfer |
| **AUD** | Select assets | SWIFT, BPAY |
| **JPY** | Select assets | Wire transfer |
| **CHF** | Select assets | Wire transfer |

### Stablecoin Support

USDT, USDC, DAI pairs widely available. Stablecoin-to-stablecoin pairs exist (e.g., USDT/USDC).

### API Pair Naming

Kraken uses non-standard naming: `XXBTZUSD` for BTC/USD, `XETHZEUR` for ETH/EUR. The `X`/`Z` prefixes are legacy. Use the `AssetPairs` endpoint for the full mapping. WebSocket v2 uses cleaner names (`BTC/USD`).

---

## Order Types

### Basic Orders

| Type | Description |
|------|-------------|
| **Market** | Execute immediately at best available price. Always taker. Subject to slippage. |
| **Limit** | Execute at specified price or better. Can be maker or taker. |

### Stop Orders

| Type | Trigger | Execution |
|------|---------|-----------|
| **Stop-Loss** | Price reaches stop level | Market order |
| **Take-Profit** | Price reaches profit target | Market order |
| **Stop-Loss-Limit** | Price reaches stop level | Limit order (avoids slippage, risks non-fill) |
| **Take-Profit-Limit** | Price reaches profit target | Limit order |

### Advanced Orders

| Type | Description |
|------|-------------|
| **Trailing Stop** | Stop-loss that moves with the market. Specify offset as absolute (`+100`) or percentage (`10%`). Locks when market reverses. |
| **Trailing Stop-Limit** | Same as trailing stop, but places a limit order instead of market when triggered. |
| **Settle-Position** | Close/settle an open margin position. |
| **Iceberg** | Large order with only partial visibility on the book. Specify `displayvol` for visible quantity. As visible portion fills, more is revealed. Minimizes market impact. |

### Order Modifiers

| Modifier | Description |
|----------|-------------|
| **Post-Only** (`oflags=post`) | Guaranteed maker. Rejected if would cross spread. |
| **Reduce-Only** | Only reduces existing position — never opens new one. |
| **IOC** (Immediate or Cancel) | Fill what's available immediately, cancel remainder. |
| **GTD** (Good Till Date) | Expires at specified time. |
| **Conditional Close** | Attach a stop-loss or take-profit that activates when primary order fills. |
| **Deadline** | RFC3339 timestamp — reject if not processed by this time (latency-sensitive). |
| **Self-Trade Prevention** | `cancel-newest`, `cancel-oldest`, or `cancel-both`. |
