## Cryptocurrency Derivatives

### Bitcoin Futures

#### CME Bitcoin Futures (BTC)

- **Launch:** December 2017.
- **Contract size:** 5 BTC.
- **Tick size:** $5 per BTC ($25 per contract).
- **Settlement:** Cash-settled to the CME CF Bitcoin Reference Rate (BRR) — a volume-weighted average from major spot exchanges (Coinbase, Kraken, Bitstamp, Gemini, LMAX Digital) calculated daily at 4:00 PM London time.
- **Trading hours:** Sun-Fri, 5:00 PM - 4:00 PM CT.
- **Margin:** Approximately 40-50% of notional (significantly higher than traditional futures due to volatility).
- **Position limits:** 2,000 front-month contracts.

#### CME Micro Bitcoin Futures (MBT)

- **Contract size:** 0.1 BTC.
- **Tick size:** $5 per BTC ($0.50 per contract).
- **Launched:** May 2021. Designed for retail and smaller institutional traders.

#### CME Ether Futures (ETH)

- **Contract size:** 50 ETH.
- **Tick size:** $0.25 per ETH ($12.50 per contract).
- **Settlement:** Cash-settled to the CME CF Ether-Dollar Reference Rate.

### Bitcoin Options (CME)

- Options on Bitcoin futures (not spot).
- **Contract size:** 5 BTC (one Bitcoin futures contract).
- **Exercise style:** European.
- **Expiration:** Monthly and weekly (Friday).
- **Pricing:** Standard Black-76 model adapted for high volatility.

### Perpetual Swaps (Crypto-Native Exchanges)

The most popular crypto derivative product, originating from BitMEX (2016) and now offered by Binance, Bybit, OKX, dYdX, and others.

**How perpetual swaps work:**
- No expiration date (unlike traditional futures).
- Tracks the spot price through a **funding rate mechanism**.
- Every 8 hours (on most exchanges), longs pay shorts or shorts pay longs based on the premium/discount to spot.

**Funding rate calculation:**
```
Funding Rate = Premium Index + clamp(Interest Rate - Premium Index, -0.05%, 0.05%)
```
Where:
- Interest Rate = (Quote Currency Rate - Base Currency Rate) / Funding Interval. Typically defaults to 0.01% per 8 hours (approximately 10.95% annualized).
- Premium Index = (Mark Price - Index Price) / Index Price.
- If the funding rate is positive, longs pay shorts (the perpetual is trading at a premium to spot).
- If negative, shorts pay longs.

**Leverage:** Up to 125x on some exchanges (though most professional traders use 1x-10x). Leverage is set per position.

**Liquidation engine:** If the position's unrealized loss exceeds the maintenance margin, the exchange's liquidation engine takes over and force-closes the position. Insurance funds (funded by excess liquidation proceeds) cover the counterparty when liquidations cannot be filled at a profitable price. Socialized loss (auto-deleveraging) is the last resort.

**Mark price vs last traded price:** Exchanges use a "mark price" (typically derived from a multi-exchange index) rather than the last traded price to prevent manipulation-driven liquidations.

### Key Differences: CME Crypto Futures vs Perpetual Swaps

| Feature | CME Futures | Perpetual Swaps |
|---|---|---|
| **Expiration** | Monthly/quarterly | None |
| **Settlement** | Cash (BRR reference rate) | No settlement; funding rate |
| **Regulation** | CFTC-regulated | Largely unregulated (offshore) |
| **Counterparty risk** | CCP-cleared (CME Clearing) | Exchange risk (not cleared) |
| **Leverage** | ~2x-2.5x (50% margin) | Up to 125x |
| **Participants** | Institutional, funds, prop firms | Retail, crypto-native funds |
| **Trading hours** | 23 hours/day, 5 days/week | 24/7/365 |
| **KYC/AML** | Full compliance required | Varies (some no-KYC exchanges) |

### Crypto Options Ecosystem

Beyond CME, the primary crypto options venue is **Deribit** (based in Panama):

- ~90% of crypto options volume globally (as of 2025).
- Bitcoin and Ether options.
- European-style, cash-settled to the Deribit BTC Index.
- Max leverage on options buying is 1x (options must be paid in full).
- Supports complex strategies (spreads, combos).
- Block trading for institutional size.
- Portfolio margining available.
