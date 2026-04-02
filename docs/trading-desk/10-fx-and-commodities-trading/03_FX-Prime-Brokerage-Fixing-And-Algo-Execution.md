## FX Prime Brokerage and Credit Intermediation

### FX Prime Brokerage (FXPB)

FX prime brokerage allows a client (typically a hedge fund) to trade with multiple dealers using the prime broker's credit.

**Mechanics:**
1. The client negotiates a prime brokerage agreement (PBA) with the prime broker (PB), typically a large bank.
2. The PB establishes "give-up" agreements with executing dealers (EDs).
3. The client trades with an ED. The trade is then "given up" to the PB, who steps in as the counterparty to both the client and the ED.
4. The ED faces the PB (strong credit) rather than the client (potentially weaker credit).
5. The client faces only the PB, simplifying credit management.

**Benefits for clients:**
- Access to multiple liquidity providers without establishing bilateral credit lines with each.
- Netting: all trades with the PB net down, reducing margin requirements and settlement flows.
- Operational efficiency: single margining, single confirmation, single settlement relationship.

**Benefits for executing dealers:**
- Face the PB's credit, not the client's.
- No need to conduct individual client credit assessments.

**PB economics:**
- PBs charge fees (per-million-traded or fixed monthly fees) and earn on the credit spread between PB funding rates and margin posted by clients.
- Capital-intensive: PBs must allocate balance sheet and regulatory capital to support the give-up positions.
- Concentration risk: a few large PBs dominate (JP Morgan, Deutsche Bank, Barclays, UBS, Citi, Goldman Sachs).
- Post-SNB event (January 2015): the SNB's removal of the EUR/CHF floor caused massive client losses, leading PBs to tighten credit terms and raise minimum requirements.

### Credit Intermediation

Beyond prime brokerage, the FX market has developed additional credit intermediation mechanisms:

- **CLS settlement**: eliminates settlement risk (Herstatt risk) through payment-vs-payment.
- **FX clearing**: LCH ForexClear clears FX NDFs and options. Not yet widely adopted for spot FX.
- **Platform-based netting**: ECNs and multi-dealer platforms net trades at the platform level, reducing gross settlement obligations.
- **Bilateral CSAs (Credit Support Annexes)**: collateral agreements requiring daily margin exchange, similar to derivatives CSAs.

---

## FX Fixing Rates

### WM/Reuters (now Refinitiv WM/R) Fix

The most widely used FX benchmark rate.

**Methodology:**
- Calculated at 4:00 PM London time (the "London fix").
- Based on actual transactions and quotes observed in a 5-minute window centered on 4:00 PM (3:57:30 to 4:02:30).
- Administered by Refinitiv, calculated by WM Company.
- Published for ~150 currency pairs.

**Importance:**
- Used by index providers (MSCI, FTSE Russell) for currency conversion in multi-currency indices.
- Passive (index-tracking) funds must transact at or near the fix rate to minimize tracking error.
- This creates predictable flow at the fix time, which can move markets.

**Fix-related trading:**
- Large fix-related flows (from index rebalances, month-end portfolio adjustments, hedging programs) concentrate into the 5-minute window.
- Dealers hedge fix orders in advance, creating pre-fix positioning.
- Manipulation scandal (2013-2015): multiple banks were fined for colluding to manipulate fix rates. Led to significant regulatory and market structure reforms.
- Post-reform: wider fixing window (expanded from 1 minute to 5 minutes in 2015), enhanced surveillance, stricter dealer conduct requirements.

### ECB Reference Rates

- Published daily at 2:15 PM CET (1:15 PM GMT) by the European Central Bank.
- Based on a daily concertation procedure between central banks at 2:15 PM CET.
- Used as a reference for EU regulatory and contractual purposes.
- Not based on actual transactions; considered less robust than WM/R for trading purposes.

### Tokyo Fix

- Published at 9:55 AM Tokyo time by the Mitsubishi UFJ Bank (formerly Bank of Tokyo-Mitsubishi UFJ).
- The benchmark rate for JPY-based FX transactions.
- Used by Japanese corporates and institutional investors for trade settlement.
- Significant flow concentration, especially in USD/JPY.
- Similar pre-fix positioning dynamics as the London fix.

### Other Fixes

- **Bank of Canada daily rate**: noon ET fix for USD/CAD.
- **Reserve Bank of India reference rate**: published around 12:30 PM IST.
- **PBOC daily midpoint**: the People's Bank of China publishes a daily USD/CNY midpoint at 9:15 AM Beijing time, around which the onshore rate is allowed to trade within a +/- 2% band.
- **SFEMC (Singapore Foreign Exchange Market Committee) rates**: used as NDF fixing sources for several Asian currencies.

---

## FX Algo Execution

### Overview

FX algorithms have grown rapidly in adoption, particularly among institutional investors seeking to reduce market impact and achieve transparent execution.

### Common FX Algo Strategies

**TWAP (Time-Weighted Average Price):**
- Slices the parent order into equal-sized child orders executed at regular intervals over a specified time period.
- Minimal market impact but does not adapt to market conditions.
- Benchmark: TWAP of the market over the algo duration.

**VWAP (Volume-Weighted Average Price):**
- Slices orders according to historical volume profiles (by time of day).
- More concentrated execution during high-volume periods (London/NY overlap).
- Benchmark: VWAP of the market over the algo duration.
- Less meaningful in FX than equities because FX volume data is less transparent (no consolidated tape).

**Implementation Shortfall (IS) / Arrival Price:**
- Trades aggressively at the start to capture the current price, then slows down.
- Balances market impact against timing risk.
- Benchmark: mid-price at algo start (arrival price).
- Urgency parameter controls the trade-off between aggressiveness and passiveness.

**Pegged / Passive:**
- Posts orders at or near the best bid/offer on ECNs.
- Captures spread by filling passively.
- Lowest market impact but highest execution time uncertainty.
- Risk: adverse selection (getting filled when the market is moving against you).

**Iceberg / Stealth:**
- Shows only a small portion of the total order on any single venue.
- Rotates across venues to avoid detection.
- Designed to minimize information leakage.

**Fixing-Targeted:**
- Executes over a window surrounding a fixing time (typically the WM/R 4 PM London fix).
- Aims to achieve a rate close to the published fix rate.
- Adjusts execution speed based on estimated fix flow direction and magnitude.

### FX Algo Analytics and TCA

- **Pre-trade**: estimated impact and duration based on order size, currency pair, time of day, and market conditions.
- **Real-time**: algo monitors execution quality vs. benchmark and adjusts pacing.
- **Post-trade TCA**: compare achieved rate against:
  - Arrival price (mid at algo start).
  - TWAP/VWAP of the market during execution.
  - Fix rate (if fix-targeted).
  - Risk-adjusted metrics (Sharpe-like measures of implementation cost vs. timing risk).
- **Venue analysis**: breakdown of fills by venue (ECN, SDP, dark pool) to assess liquidity sourcing quality.
- **Spread capture**: analysis of how much of the bid-ask spread the algo captured (relevant for passive strategies).
