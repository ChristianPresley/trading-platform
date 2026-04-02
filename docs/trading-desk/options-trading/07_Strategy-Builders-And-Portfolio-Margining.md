## Options Strategy Builders

### Visual Strategy Builder

Professional platforms provide a graphical interface for constructing multi-leg strategies:

1. **Select underlying and expiration.**
2. **Click on the options chain** to add legs (calls/puts, buy/sell).
3. **The system automatically identifies the strategy type** (e.g., "iron condor" if you select four legs matching that pattern).
4. **Adjust quantities** — for ratio spreads, custom combinations.
5. **Set order type** — limit on the net debit/credit.
6. **Route as a complex order** to exchanges.

### Payoff Diagrams

The payoff diagram shows profit/loss at expiration as a function of the underlying price.

**Standard features:**
- **X-axis:** Underlying price at expiration.
- **Y-axis:** P&L in dollars.
- **Solid line:** Payoff at expiration.
- **Dashed line:** Payoff at a selected date before expiration (using the current IV surface).
- **Multiple curves:** Show payoff at various dates (T-30, T-15, T-7, T-1, expiration).
- **Break-even points:** Marked on the x-axis.
- **Max profit and max loss zones** shaded.
- **Current underlying price** indicated with a vertical line.

**Interactive features:**
- Drag to adjust strikes and see the payoff change in real-time.
- Toggle individual legs on/off to see their contribution.
- Adjust implied volatility to see the impact on the pre-expiration curves.
- Overlay the underlying's price distribution (based on implied volatility) on the payoff diagram.

### Break-Even Analysis

For each strategy, the system calculates:

- **Upper break-even** — underlying price at which the strategy transitions from profit to loss on the upside.
- **Lower break-even** — same on the downside.
- **Break-even at different dates** — accounting for remaining time value.
- **Break-even volatility** — the implied volatility level at which the position breaks even (for vega-sensitive strategies).

### Probability Analysis

Using the implied volatility and underlying price distribution:

- **Probability of Profit (POP)** — likelihood that the strategy yields any positive return at expiration. Based on the log-normal distribution implied by the current IV.
- **Probability of Max Profit** — likelihood of achieving the maximum possible profit (all short options expire worthless, all long options expire ITM).
- **Probability of touching** — likelihood that the underlying touches a specific price level at any time before expiration (higher than probability of finishing there).
- **Expected value** — probability-weighted average P&L. Integral of (P&L x probability density) over all underlying prices.
- **Expected value with slippage** — adjusts for bid-ask spread and execution quality.

### Scenario Analysis (What-If)

- **Vol scenarios:** Show P&L if IV increases/decreases by 5, 10, 15 percentage points.
- **Time scenarios:** Show P&L at various dates before expiration.
- **Combined scenarios:** A matrix of (underlying price change, IV change) with P&L in each cell. Also called a "risk matrix" or "scenario grid."
- **Monte Carlo scenario:** Simulate thousands of price paths and show the P&L distribution (histogram).

---

## Portfolio Margining for Options

### SPAN (Standard Portfolio Analysis of Risk)

Developed by the CME in 1988. Used globally for futures and options margining.

**How SPAN works:**

1. **Define risk arrays** — For each contract, calculate the theoretical gain or loss under 16 scenarios (combinations of underlying price moves and volatility changes).
   - Typical scan range: +/- 3 standard deviations of daily price move.
   - Volatility shifts: +/- 1 standard deviation of vol move (up/down).
   - The 16 scenarios: price up/down at 1/3, 2/3, 3/3 of the scan range, each with vol up and vol down, plus two extreme move scenarios (price up/down at 3x the scan range covering 35% of the loss).

2. **Identify the worst-case scenario** — The scenario producing the maximum loss is the scanning risk.

3. **Apply inter-month spread charges** — Additional margin for calendar risk (different expirations may not move in lockstep).

4. **Apply inter-commodity credits** — Offsets for correlated positions (e.g., crude oil vs heating oil).

5. **Apply short option minimum** — A floor to ensure short deep-OTM options carry some minimum margin.

6. **Sum net result** — SPAN margin = scanning risk + inter-month charge - inter-commodity credit, subject to short option minimum.

**SPAN margin rate** for a single futures contract is roughly equivalent to the expected 1-day price move at a 99% confidence level multiplied by the number of days for potential liquidation.

### TIMS (Theoretical Intermarket Margin System)

Used by the OCC for listed options. Predecessor to portfolio margining.

- Groups positions into classes (same underlying) and product groups (correlated underlyings).
- Uses theoretical pricing models to evaluate risk under multiple scenarios.
- Allows offsets between correlated products within a product group.

### OCC Risk-Based Margining (Portfolio Margin)

The OCC's portfolio margining system (also called "risk-based haircuts") for qualifying customer accounts.

**Eligibility:**
- Minimum account equity: $100,000 (FINRA requirement for portfolio margin).
- Must be approved by the broker for portfolio margining.
- Available for: equity options, index options, equity positions, ETF/ETN options.

**Methodology:**
- Evaluates the portfolio's theoretical gains and losses under 10 equidistant price moves:
  - Broad-based index: +/- 8% (SPX, NDX, RUT, DJX)
  - Non-broad-based index and ETF: +/- 15%
  - Individual equities: +/- 15%
- Each price move is evaluated at three volatility levels: current, +implied shift, -implied shift.
- The maximum loss across all scenarios is the margin requirement.
- Offsets are allowed across correlated positions.

### Portfolio Margin vs Reg-T Margin

| Feature | Reg-T Margin | Portfolio Margin |
|---|---|---|
| **Minimum equity** | $2,000 | $100,000 |
| **Methodology** | Strategy-based rules (fixed percentages) | Risk-based (scenario analysis) |
| **Short put margin** | 20% of underlying + premium - OTM amount | Max loss across +/- 15% scenarios |
| **Spread margin** | Max loss of the spread | Max loss across scenarios (often lower) |
| **Cross-position offsets** | Limited (within same underlying) | Broad (across correlated underlyings) |
| **Iron condor example (SPX)** | ~$45,000 per spread | ~$5,000-$10,000 per spread |
| **Typical capital efficiency** | Baseline | 3x to 6x more capital efficient |

**Example comparison:**

Short SPX 4200/4150 put spread (50-point wide):

- **Reg-T margin:** $50 x 100 = $5,000 per spread (max loss = margin requirement).
- **Portfolio margin:** Evaluated under +/- 8% scenarios. If SPX is at 4300, an 8% drop to 3956 would put the spread fully ITM, so margin is approximately the full $5,000. But if SPX is at 4500, an 8% drop to 4140 still leaves the spread near the edge, and the margin might be $3,000-$4,000 after volatility adjustment.

For complex portfolios with hedged positions, portfolio margin provides dramatically lower requirements due to the netting of risk across positions.

### Cross-Margining

Cross-margining allows offsets between positions held at different clearing organizations.

- **OCC-CME cross-margin program:** Offsets between listed equity options (OCC-cleared) and equity index futures (CME-cleared). A long SPX put position offsets against a long ES futures position.
- **Benefits:** Reduces total margin by recognizing hedges across product types.
- **Requirements:** Positions must be held in a cross-margin account at an approved clearing member.

### Margin Call Process

1. **Intraday monitoring:** Professional systems calculate margin in real-time. If equity falls below the maintenance requirement, a margin call is triggered.
2. **Margin call notification:** The broker notifies the account holder. Regulation T allows 2-3 business days to meet the call.
3. **Meeting the call:** Deposit cash, deposit marginable securities, or close positions to reduce the requirement.
4. **Forced liquidation:** If the call is not met, the broker can liquidate positions without notice. Brokers typically liquidate the most liquid positions first.

### Reg-T Margin Rules for Options (Key Rules)

- **Long options:** Must be paid for in full (100% of premium). No margin lending for long options.
- **Covered call:** No additional margin required (the shares serve as collateral).
- **Cash-secured put:** Must hold cash equal to the strike price x 100. Or, under margin, 20% of the underlying + premium - OTM amount (minimum 10% of strike + premium).
- **Naked call:** 20% of underlying + premium - OTM amount, minimum 10% of underlying + premium. Uncapped risk.
- **Vertical spread (credit):** Margin = width of spread - premium received. This is the max loss.
- **Vertical spread (debit):** Paid in full. No margin.
- **Iron condor:** Margin = max(put spread width, call spread width) - net premium. Only one side is margined because both sides cannot lose simultaneously.
- **Straddle/strangle (short):** Greater of the call side or put side requirement, plus the premium of the other side.

---

*This document serves as a reference for implementing options trading features in a professional trading desk application. All exchange rules, margin requirements, and regulatory references should be verified against current exchange and regulatory publications before implementation.*
