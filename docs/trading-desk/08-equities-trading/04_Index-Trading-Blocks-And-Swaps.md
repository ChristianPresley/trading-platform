## Equity Index Trading

### Index Futures

- Cash-settled futures contracts on equity indices (S&P 500, NASDAQ 100, Dow Jones, Russell 2000, Euro Stoxx 50, FTSE 100, Nikkei 225, Hang Seng, etc.).
- **Contract specifications**: multiplier (e.g., $50 per point for E-mini S&P 500), tick size ($0.25 = $12.50 per contract), quarterly expiration (March, June, September, December), daily settlement.
- **Micro contracts**: smaller notional (e.g., Micro E-mini S&P 500 = $5 per point) for finer position sizing.
- **Basis**: futures price minus spot index price. Reflects cost of carry (interest rate minus dividend yield) and supply/demand imbalances.
- **Roll**: traders roll positions from the expiring contract to the next quarter. Roll period typically begins 8 trading days before expiration. Roll spread is quoted and traded as a calendar spread.
- **Fair value**: theoretical futures price based on carry model. Deviations from fair value create arbitrage opportunities (see index arbitrage below).

### ETF Creation/Redemption and Index Arbitrage

**Creation/redemption mechanism:**
1. Authorized participant (AP) observes the ETF trading at a premium to NAV.
2. AP buys the underlying basket of securities and delivers them to the ETF issuer.
3. ETF issuer creates new ETF shares and delivers them to the AP.
4. AP sells ETF shares in the market, capturing the premium as profit.
5. Reverse process for discounts: AP buys ETF shares, redeems them for the underlying basket, sells the basket.

**Index arbitrage (cash-futures arbitrage):**
- When the futures basis exceeds fair value: buy the underlying basket, sell the futures contract.
- When the futures basis is below fair value: sell the underlying basket (or short), buy the futures contract.
- Execution speed is critical; high-frequency firms dominate this space.
- Transaction costs, borrowing costs (for short baskets), and execution risk limit arbitrage profitability.
- Program trading systems execute the basket leg rapidly across multiple exchanges.

**ETF-futures arbitrage:**
- Three-way relationship: index futures, index ETF, and underlying basket.
- Any persistent mispricing between pairs creates an arbitrage opportunity.

### Index Rebalancing

- Major indices (S&P 500, Russell, MSCI) rebalance periodically (quarterly or annually).
- Additions and deletions drive significant volume: stocks being added experience buying pressure; stocks being removed experience selling pressure.
- Announcement-to-effective date window creates a trading opportunity.
- Float adjustments, share count changes, and sector reclassifications also trigger rebalancing flows.
- Estimated tracking AUM for major indices runs into trillions of dollars, making rebalance trades among the largest predictable flows in the market.

---

## Block Trading and the Upstairs Market

### Definition and Thresholds

- A block trade is a large transaction negotiated privately between institutional counterparties, typically above a minimum size threshold (e.g., 10,000 shares or $200,000 in notional value, though practical thresholds are much higher).
- "Upstairs market" refers to the off-exchange negotiation process, contrasted with the "downstairs" exchange order book.

### Block Trading Workflow

1. **Indication of interest (IOI)**: the sell-side trader broadcasts IOIs to the buy-side indicating availability of a block (natural or facilitation). IOIs may be "natural" (representing a real client order) or "conditional."
2. **Price negotiation**: parties negotiate a price, typically referencing the last sale, VWAP, NBBO midpoint, or a fixed percentage discount/premium.
3. **Execution**: once agreed, the block is executed as a single trade, often printed to exchange tape or reported to FINRA TRF (Trade Reporting Facility).
4. **Risk transfer**: in a facilitation/principal trade, the dealer takes the other side of the client's order onto their own book and hedges the position.

### Venues and Protocols

- **Liquidnet**: buy-side-only dark pool for block crossing. Members see aggregated IOIs; no information leakage to sell-side.
- **POSIT (ITG/Virtu)**: crossing network for institutional blocks.
- **Broker-dealer block desks**: traders at bulge bracket firms facilitate blocks using their balance sheet.
- **Request for Block (RFB)**: electronic protocol where the buy-side requests a block bid/offer from multiple dealers simultaneously.

### Pricing Considerations

- **Volume-weighted risk**: larger blocks relative to ADV (average daily volume) require larger discounts.
- **Information content**: blocks that signal informed trading (e.g., from well-known fundamental managers) command larger discounts than those from index funds or rebalancing flows.
- **Market impact**: estimated using models like Almgren-Chriss or proprietary TCA (transaction cost analysis) frameworks.
- **Guaranteed VWAP**: dealer guarantees execution at the day's VWAP, absorbing the risk of achieving that benchmark.

---

## Equity Swaps and Synthetic Positions

### Total Return Swaps (TRS)

A total return swap transfers the economic exposure of a stock or basket without transferring ownership.

**Structure:**
- **Equity leg**: one party (the long side) receives the total return of the reference equity (price appreciation/depreciation + dividends).
- **Financing leg**: the long side pays a financing rate (typically SOFR/SONIA + spread) on the notional amount.
- **Settlement**: periodic (monthly, quarterly) or at maturity. Can be physical or cash settlement.

**Use cases:**
- **Leveraged exposure**: investor gains synthetic long exposure without funding the full purchase price.
- **Regulatory capital efficiency**: may require less capital than outright ownership depending on jurisdiction and entity type.
- **Short exposure**: the short side of the TRS is economically short the reference equity.
- **Tax and dividend optimization**: in some jurisdictions, swap-based exposure has different tax treatment for dividends (withholding tax reclaim, manufactured dividends).
- **Disclosure avoidance**: in certain jurisdictions, swap positions may not count toward ownership disclosure thresholds (though regulations are tightening, e.g., SEC Rule 13d amendments).

### Contract for Difference (CFD)

- Common in European and Asian markets; not available to US retail investors.
- Economically similar to a TRS but structured as a leveraged derivative product.
- Trader posts initial margin (e.g., 5-20% of notional) and pays/receives the daily P&L on the reference security.
- Financing cost embedded as an overnight funding charge.

### Portfolio Swaps

- A single swap referencing a basket of securities, rebalanced periodically.
- Used by hedge funds for leveraged long/short portfolios.
- The prime broker is the swap counterparty, managing the hedge portfolio.
- Margin terms, concentration limits, and eligible securities are defined in the ISDA/CSA documentation.

### Implementation Considerations

- **Valuation**: mark-to-market based on reference security price, accrued financing, and accrued dividends.
- **Corporate actions**: swap terms must specify handling of dividends, splits, mergers, spin-offs, and other corporate events.
- **Counterparty credit risk**: managed via collateral/margin agreements (CSA - Credit Support Annex).
- **Regulatory reporting**: swap positions must be reported to trade repositories (DTCC, REGIS-TR) under Dodd-Frank / EMIR.
