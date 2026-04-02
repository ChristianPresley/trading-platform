## Cross-Margining Between Asset Classes

### Concept

Cross-margining allows margin offsets between positions held at different clearing houses or across different asset classes within the same clearing house. The core principle is that hedged portfolios should require less margin than the sum of the parts.

### CME Cross-Margining Programs

#### CME-OCC Cross-Margin

Allows offsets between:
- CME equity index futures (ES, NQ, etc.)
- OCC-cleared equity index options (SPX, NDX options)
- OCC-cleared equity options and ETF positions

**Example:** A trader who is long SPX put options (cleared at OCC) and long ES futures (cleared at CME) has a partially hedged position. Under cross-margining, the combined requirement is lower than the sum of the individual requirements.

**Requirements:**
- Positions must be in a cross-margin account at an approved dual-member clearing firm.
- The firm must be a clearing member of both CME and OCC.
- Approved by CFTC (futures side) and SEC (securities side).

#### CME-LCH Cross-Margin

Allows offsets between:
- CME Treasury futures (ZN, ZB, etc.)
- LCH-cleared interest rate swaps

A trader with a duration-matched position in Treasury futures and interest rate swaps gets significant margin relief because these positions are highly correlated hedges.

### Eurex Prisma Cross-Margining

Eurex's PRISMA margin system provides cross-margining across:
- Equity index futures and options (FESX, FDAX)
- Fixed income futures and options (FGBL, FGBM, FGBS)
- OTC cleared interest rate swaps (via Eurex Clearing)
- Equity derivatives and repo

PRISMA uses a portfolio-based approach (historical simulation VaR with filtered scenarios) that naturally provides cross-asset margin offsets within a single account.

### Benefits and Considerations

**Benefits:**
- Significant capital savings (30-70% reduction for well-hedged portfolios).
- More accurate representation of true portfolio risk.
- Encourages hedging by not penalizing hedged positions with excessive margin.

**Considerations:**
- Operational complexity: Positions at multiple CCPs must be coordinated.
- Default management: If a member defaults, both CCPs must coordinate the close-out.
- Regulatory approval: Cross-margining between SEC-regulated products and CFTC-regulated products requires dual regulatory oversight.
- Not all brokers offer cross-margin accounts: Firms must be members of both CCPs.

---

## Futures Basis Trading and Arbitrage

### The Basis

The basis is the difference between the futures price and the spot (cash) price of the underlying:

```
Basis = Futures Price - Spot Price
```

For financial futures, the theoretical basis (fair value) is determined by the cost of carry:

```
Fair Value = Spot x (1 + r - d)^T
```

Or, in continuous compounding:

```
F = S x e^((r - q) x T)
```

Where r = risk-free rate, q = dividend yield (or convenience yield for commodities), T = time to expiration.

### Basis Convergence

The basis must converge to zero at expiration (for cash-settled contracts) or to the delivery cost (for physically-settled contracts). This convergence is the foundation of all basis trading.

- **Positive basis (contango):** Futures > Spot. Normal for financial futures (cost of carry is positive when r > q).
- **Negative basis (backwardation):** Futures < Spot. Common in commodity markets with high convenience yield (e.g., during supply shortages).

### Cash-and-Carry Arbitrage

If the futures price exceeds the theoretical fair value (the basis is "rich"):

1. **Buy spot** — Purchase the underlying in the cash market.
2. **Sell futures** — Short the futures contract.
3. **Finance** — Borrow cash to fund the spot purchase (at rate r).
4. **Hold to expiration** — Collect dividends/income from the spot position.
5. **Deliver or settle** — At expiration, the positions converge. The profit is the excess of the futures price over fair value.

**Example (S&P 500):**
- SPX at 4500, ES front-month at 4510.
- Fair value with 30 days to expiration, 5% rate, 1.5% dividend yield: 4500 x e^((0.05 - 0.015) x 30/365) = 4500 x 1.00288 = 4512.96.
- Basis = 4510 - 4500 = 10.00. Fair value basis = 12.96.
- Futures are cheap relative to fair value (negative mispricing of 2.96 points). No cash-and-carry arbitrage opportunity (the basis is actually thin).
- If instead ES were at 4520 (basis = 20.00, vs fair value 12.96), sell ES and buy the basket of S&P 500 stocks for a 7.04 point profit (minus transaction costs).

### Reverse Cash-and-Carry Arbitrage

If the futures price is below fair value (the basis is "cheap"):

1. **Sell/short spot** — Short the underlying.
2. **Buy futures** — Go long the futures.
3. **Invest short sale proceeds** — Earn interest on the cash.
4. **Close at expiration** — Converge, and the profit is the shortfall of the futures price below fair value.

In practice, reverse cash-and-carry is harder because shorting stocks has costs (borrow fees, hard-to-borrow constraints) that may exceed the arbitrage profit.

### Index Arbitrage (Program Trading)

The systematic exploitation of mispricing between index futures and the underlying basket of stocks.

**Implementation:**
1. Monitor the basis in real-time (actual basis vs fair value).
2. When the basis exceeds a threshold (typically a few points of S&P, accounting for transaction costs, market impact, and execution risk): trigger a "buy program" (sell futures, buy stocks) or "sell program" (buy futures, sell stocks).
3. Execute the stock basket via algorithmic execution (VWAP, arrival price, or portfolio trading algorithm) to minimize market impact.
4. Hold the position until expiration (or unwind if the basis reverts).

**Costs that determine the arbitrage threshold:**
- Exchange fees (futures and equity).
- Clearing fees.
- Market impact (buying/selling hundreds of stocks simultaneously).
- Dividend risk (uncertainty in dividend payments and ex-dates).
- Execution slippage.
- Financing cost differential.
- For reverse arb: stock borrowing cost.

**Participants:** Primarily quantitative prop trading firms (Jane Street, Citadel Securities, Jump Trading, Virtu) using automated systems with sub-second execution.

### Bond Basis Trading

For Treasury futures (ZN, ZB), basis trading involves the relationship between futures and the cheapest-to-deliver (CTD) bond.

```
Bond Basis = Cash Price - (Futures Price x Conversion Factor)
```

The basis reflects:
- **Carry:** Net income from holding the bond (coupon accrual minus financing cost).
- **Delivery option value:** The short's option to choose which bond to deliver, when to deliver, and the wildcard option (delivery after the futures market closes but before the delivery notice deadline).

**Basis trade:**
- **Long the basis** (buy bonds, sell futures): Profits if the basis widens or if carry exceeds the basis cost.
- **Short the basis** (sell bonds, buy futures): Profits if the basis narrows.

**Gross basis vs net basis:**
- Gross basis = Cash Price - Futures x CF.
- Net basis = Gross basis - Carry. The net basis represents the delivery option value.
- If net basis = 0, the bond is priced purely on carry and delivery is a certainty.

### ETF Arbitrage

The ETF creation/redemption mechanism creates a continuous arbitrage opportunity:

1. **Premium arbitrage:** If ETF price > NAV, APs buy the underlying basket, create ETF shares, sell on exchange.
2. **Discount arbitrage:** If ETF price < NAV, APs buy ETF shares, redeem for the underlying basket, sell the securities.

This keeps ETF prices within a tight band of NAV. The width of this band depends on:
- Transaction costs for the basket (number of holdings, liquidity).
- Creation/redemption fees (charged by the ETF issuer, typically $250-$1,500 per creation unit).
- Market hours overlap (international ETFs can have wider bands when the underlying market is closed).
- Hedging costs (for bond ETFs, the basket may contain illiquid bonds).

### Commodity Basis Trading

In commodities, the basis reflects physical market conditions:

```
Basis = Local Cash Price - Futures Price
```

**Factors affecting commodity basis:**
- **Transportation costs:** Grain in Iowa vs delivery point in Chicago.
- **Quality differentials:** Different grades of crude oil, different protein content of wheat.
- **Storage costs:** Carrying physical inventory.
- **Convenience yield:** The benefit of holding physical inventory (ability to meet unexpected demand).
- **Local supply/demand:** A refinery shutdown in a region can cause local basis to spike.

**Basis trading in practice:**
- An elevator operator (grain storage) buys grain from farmers at local cash price and sells futures to lock in the basis.
- The operator profits from the basis — the difference between what they pay locally and what they sell forward.
- The basis is their "margin" — if local supply is tight, they pay more (basis narrows or inverts), reducing their margin.

### Statistical Arbitrage with Futures

Beyond pure basis arbitrage, professional desks engage in statistical arbitrage strategies using futures:

- **Pairs trading:** Long one futures contract, short another, based on historical spread relationships (e.g., Brent vs WTI, gold vs silver, ES vs NQ).
- **Mean reversion:** Trade the basis or spread when it deviates significantly from its historical mean.
- **Cointegration-based strategies:** Identify futures pairs that are cointegrated (long-run equilibrium relationship) and trade deviations from the equilibrium.
- **Relative value:** Compare futures-implied interest rates across different maturities to identify mispricings in the yield curve.

### Regulatory Considerations

- **CFTC position limits:** Large traders must report positions exceeding reporting thresholds. Speculative position limits restrict the maximum number of contracts a non-commercial trader can hold.
- **Position accountability:** Above a threshold, the exchange can request information about the position and require reduction.
- **Large Trader Reporting (LTR):** CFTC Form 40 for identification; daily reporting by clearing firms of positions exceeding thresholds.
- **Anti-manipulation rules:** Commodity Exchange Act Section 9(a)(2) prohibits manipulation of commodity prices. Spoofing (placing and quickly canceling orders to create false liquidity) is a criminal offense under Dodd-Frank.
- **Cross-border considerations:** MiFID II in Europe imposes position limits on commodity derivatives and requires position reporting. EMIR requires reporting of all derivatives transactions to a trade repository.
