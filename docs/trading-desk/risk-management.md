# Risk Management

Comprehensive reference for risk management as implemented in professional trading desk applications. Covers market risk, credit risk, liquidity risk, operational risk, pre-trade controls, real-time Greeks, risk limits, stress testing, regulatory requirements, and risk attribution.

---

## Table of Contents

1. [Market Risk](#1-market-risk)
2. [Credit Risk](#2-credit-risk)
3. [Liquidity Risk](#3-liquidity-risk)
4. [Operational Risk](#4-operational-risk)
5. [Pre-Trade Risk Controls](#5-pre-trade-risk-controls)
6. [Real-Time Risk Calculations](#6-real-time-risk-calculations)
7. [Risk Limits and Breaches](#7-risk-limits-and-breaches)
8. [Stress Testing and Scenario Analysis](#8-stress-testing-and-scenario-analysis)
9. [Regulatory Risk Requirements](#9-regulatory-risk-requirements)
10. [Risk Attribution and Decomposition](#10-risk-attribution-and-decomposition)

---

## 1. Market Risk

Market risk is the risk of losses due to adverse movements in market prices, rates, and volatilities.

### Value at Risk (VaR)

VaR answers: "What is the maximum loss over a given time horizon at a given confidence level, under normal market conditions?"

```
VaR(alpha, T) = the loss level such that P(Loss > VaR) = 1 - alpha
```

Typical parameters:
- **Confidence level**: 95% or 99%
- **Time horizon**: 1 day (trading), 10 days (regulatory)
- **Observation window**: 250 trading days (1 year) to 500+ days

#### Historical VaR

Uses actual historical returns to construct the P&L distribution.

**Method:**

1. Collect N days of historical returns for all risk factors.
2. For each historical day i (i = 1 to N), apply the historical changes in risk factors to the current portfolio.
3. Compute the hypothetical portfolio P&L for each day.
4. Sort the P&L values from worst to best.
5. VaR at confidence level alpha = the P&L at the (1-alpha) * N-th percentile.

```
Example: 250 days of history, 99% confidence
  Sort 250 P&L scenarios from worst to best
  99% VaR = 2nd worst loss (since 250 * 0.01 = 2.5, round to 2nd)

  Sorted P&Ls: [-$8.2M, -$6.1M, -$5.8M, ..., +$7.3M]
  99% 1-day VaR = $6.1M (2nd worst)
```

**Advantages**: No distributional assumptions; captures fat tails and correlations naturally.
**Disadvantages**: Limited to historical events; window length is a trade-off (longer = more data but less relevant; shorter = more relevant but more noise).

#### Parametric (Variance-Covariance) VaR

Assumes returns are normally (or near-normally) distributed.

```
VaR = z_alpha * sigma_portfolio * sqrt(T)
```

Where:
- `z_alpha` = standard normal quantile (1.645 for 95%, 2.326 for 99%)
- `sigma_portfolio` = portfolio standard deviation
- `T` = time horizon in days

For a portfolio of N assets:

```
sigma_portfolio = sqrt(w' * Sigma * w)
```

Where:
- `w` = vector of portfolio weights (notional exposures)
- `Sigma` = N x N covariance matrix of asset returns

**Advantages**: Computationally efficient; easy to decompose into component and marginal VaR.
**Disadvantages**: Assumes normality (underestimates tail risk); poor for non-linear instruments (options).

**Scaling VaR across time horizons** (square-root-of-time rule):
```
VaR(T days) = VaR(1 day) * sqrt(T)
```

This assumes i.i.d. returns (independent and identically distributed). The assumption is reasonable for short horizons but breaks down for longer periods due to serial correlation and mean reversion.

#### Monte Carlo VaR

Simulates thousands of possible future scenarios using stochastic processes.

**Method:**

1. Define stochastic processes for all risk factors (e.g., geometric Brownian motion for equities, Hull-White for rates).
2. Calibrate model parameters to historical data or market-implied values.
3. Generate N random scenarios (typically 10,000-100,000).
4. Revalue the entire portfolio under each scenario.
5. Construct the P&L distribution from the simulated values.
6. VaR = the loss at the (1-alpha) percentile of the simulated distribution.

```
For each simulation i (i = 1 to N):
  For each risk factor j:
    S_j(t+dt) = S_j(t) * exp((mu_j - 0.5*sigma_j^2)*dt + sigma_j*sqrt(dt)*Z_ij)
    where Z_ij ~ N(0,1), correlated across risk factors using Cholesky decomposition
  
  PnL_i = Portfolio_Value(new risk factors) - Portfolio_Value(current risk factors)

VaR = percentile(PnL_1, ..., PnL_N, 1-alpha)
```

**Advantages**: Handles non-linear instruments (options, structured products); can model non-normal distributions, jumps, stochastic volatility.
**Disadvantages**: Computationally expensive; model risk from assumed stochastic processes; convergence requires many simulations.

### Expected Shortfall (CVaR)

Expected Shortfall (also called Conditional VaR or CVaR) measures the average loss in the tail beyond VaR:

```
ES_alpha = E[Loss | Loss > VaR_alpha]
```

ES is the average of all losses that exceed the VaR threshold. It provides information about the severity of tail losses, not just the threshold.

```
Example: 99% ES with 250 scenarios
  99% VaR = 2nd worst loss = $6.1M
  99% ES = average of the 2 worst losses = ($8.2M + $6.1M) / 2 = $7.15M
```

ES is **coherent** (satisfies subadditivity), unlike VaR:
```
ES(A + B) <= ES(A) + ES(B)   [always true for ES]
VaR(A + B) <= VaR(A) + VaR(B) [NOT always true for VaR]
```

Basel III's Fundamental Review of the Trading Book (FRTB) replaced VaR with ES as the primary market risk measure.

### Stress Testing

Stress testing evaluates portfolio impact under extreme but plausible scenarios. Unlike VaR (which measures "normal" market conditions), stress tests measure losses in crisis scenarios.

**Types of stress tests:**

| Type | Description |
|---|---|
| **Historical** | Replay actual crisis scenarios |
| **Hypothetical** | Construct plausible future scenarios |
| **Reverse** | Determine what scenarios would cause a given loss level |
| **Sensitivity** | Shift one or more risk factors by fixed amounts |

Standard historical stress scenarios:

| Scenario | Period | Key Characteristics |
|---|---|---|
| Black Monday | Oct 1987 | US equities -22% in one day |
| LTCM / Russian Crisis | Aug-Sep 1998 | Spread widening, flight to quality |
| Dot-Com Crash | 2000-2002 | Tech stocks -78% (NASDAQ peak to trough) |
| 9/11 | Sep 2001 | Markets closed 4 days, reopened down 7% |
| Global Financial Crisis | 2007-2009 | Credit crisis, equities -57%, massive vol spike |
| European Sovereign Crisis | 2010-2012 | Peripheral spreads blow out |
| COVID-19 | Mar 2020 | Equities -34%, VIX > 80, rates collapse |
| 2022 Rate Shock | 2022 | Fastest rate hike cycle in 40 years, bonds -13% |

### Scenario Analysis

Scenario analysis applies specific, defined changes to market variables:

```
Scenario: "Rates +100bps, Equities -10%, Vol +5 pts, USD +5%"

Apply simultaneously:
  Rate curves: parallel shift up 100bps
  Equity indices: all down 10%
  Implied volatility surfaces: flat shift up 5 vol points
  FX: USD appreciates 5% against all currencies

Revalue entire portfolio under stressed parameters
Portfolio P&L under scenario = Stressed Value - Current Value
```

---

## 2. Credit Risk

Credit risk is the risk of loss due to a counterparty's failure to meet its contractual obligations.

### Counterparty Exposure

**Current Exposure (CE):**
```
CE = max(0, MTM)    [for a single trade]
CE = max(0, sum(MTM_i))    [for trades under a netting agreement]
```

Current exposure is the amount that would be lost today if the counterparty defaulted, assuming no recovery.

**Potential Future Exposure (PFE):**

PFE is the maximum expected credit exposure at a future date at a given confidence level:

```
PFE(t, alpha) = percentile(Exposure(t), alpha)    [typically alpha = 97.5%]
```

PFE is computed using Monte Carlo simulation:

1. Simulate future market scenarios at multiple time horizons (1d, 1w, 1m, 3m, 6m, 1y, ..., maturity).
2. Revalue all trades with the counterparty under each scenario at each time point.
3. Apply netting and collateral agreements.
4. PFE at time t = 97.5th percentile of simulated exposure at time t.

**Expected Positive Exposure (EPE):**
```
EPE = (1/T) * integral(0 to T) of E[max(0, V(t))] dt
```

EPE is the time-averaged expected exposure, used in CVA calculations and Basel regulatory capital.

**Peak Exposure:**
```
PeakExposure = max over all t of PFE(t)
```

### Credit Limits

| Limit Type | Description |
|---|---|
| **Gross credit limit** | Maximum gross exposure to a counterparty |
| **Net credit limit** | Maximum net exposure (after netting and collateral) |
| **Tenor limit** | Maximum exposure by maturity bucket |
| **Product limit** | Limits by product type (IRS, CDS, FX, etc.) |
| **Settlement limit** | Maximum settlement exposure on any single day |
| **Country limit** | Maximum aggregate exposure to counterparties in a country |
| **Sector limit** | Maximum aggregate exposure to a sector (e.g., financials) |

Credit limit utilization:
```
Utilization = CurrentExposure / CreditLimit
```

For pre-trade checks, the system must estimate the incremental exposure of a proposed trade:
```
ProposedUtilization = (CurrentExposure + IncrementalExposure_ProposedTrade) / CreditLimit
```

### CVA and DVA

**Credit Valuation Adjustment (CVA)** is the market price of counterparty credit risk:

```
CVA = (1 - R) * integral(0 to T) of DiscountFactor(t) * EPE(t) * dPD(t)
```

Where:
- `R` = recovery rate (typically 40% for senior unsecured)
- `EPE(t)` = expected positive exposure at time t
- `dPD(t)` = marginal default probability at time t (derived from CDS spreads)

Simplified discrete formula:
```
CVA = (1 - R) * sum(i=1 to N) [ DF(t_i) * EPE(t_i) * (PD(t_i) - PD(t_{i-1})) ]
```

**Debit Valuation Adjustment (DVA)** is the symmetric adjustment for the firm's own credit risk:

```
DVA = (1 - R_own) * integral(0 to T) of DF(t) * ENE(t) * dPD_own(t)
```

Where `ENE(t)` = Expected Negative Exposure (the counterparty's credit exposure to us).

**Bilateral CVA:**
```
FairValue = RiskFreeValue - CVA + DVA
```

DVA is controversial because it creates a profit when a firm's own credit quality deteriorates.

### Netting Agreements

Under an ISDA Master Agreement with a netting provision, in the event of default all transactions are terminated and netted to a single payment:

```
Without netting: Exposure = sum of max(0, MTM_i) for all trades
With netting:    Exposure = max(0, sum(MTM_i)) for all trades

Netting benefit = Exposure_Gross - Exposure_Net
```

Example:
```
Counterparty: Bank XYZ
  Trade 1 (IRS): MTM = +$5M (they owe us)
  Trade 2 (FX Forward): MTM = -$3M (we owe them)
  Trade 3 (CDS): MTM = +$2M (they owe us)

Gross exposure = max(0,$5M) + max(0,-$3M) + max(0,$2M) = $5M + $0 + $2M = $7M
Net exposure (with netting) = max(0, $5M - $3M + $2M) = max(0, $4M) = $4M
Netting benefit = $7M - $4M = $3M (43% reduction)
```

### Collateral (CSA)

ISDA Credit Support Annexes (CSAs) specify collateral exchange terms:

| CSA Term | Description |
|---|---|
| **Threshold** | Exposure level below which no collateral is required (e.g., $10M) |
| **Minimum Transfer Amount (MTA)** | Minimum collateral call size (e.g., $500K) |
| **Independent Amount (IA)** | Fixed collateral required regardless of exposure |
| **Eligible Collateral** | Cash (USD, EUR, GBP), government bonds, sometimes corporate bonds or equities |
| **Haircuts** | Discount applied to non-cash collateral (e.g., 2% for 10Y govies, 5% for equities) |
| **Frequency** | Daily (standard), weekly (legacy agreements) |
| **Dispute resolution** | Process for resolving valuation disagreements |

Collateralized exposure:
```
CollateralizedExposure = max(0, NetExposure - CollateralHeld + Threshold)
```

---

## 3. Liquidity Risk

Liquidity risk is the risk that a position cannot be liquidated quickly enough at a reasonable price.

### Bid-Ask Spread Risk

The bid-ask spread represents an immediate transaction cost and varies with market conditions:

```
SpreadCost = 0.5 * BidAskSpread * PositionSize
```

For a portfolio:
```
LiquidationCost = sum_i [ 0.5 * Spread_i * abs(Position_i) ]
```

Spreads widen dramatically during market stress:

| Instrument | Normal Spread | Stressed Spread |
|---|---|---|
| Large-cap US equity | 1-2 bps | 10-50 bps |
| US Treasury 10Y | 0.5-1 bp | 5-15 bps |
| Investment grade corporate bond | 5-15 bps | 50-200 bps |
| High yield bond | 25-100 bps | 200-1000 bps |
| EM sovereign bond | 10-30 bps | 100-500 bps |
| Small-cap equity | 10-50 bps | 100-500 bps |

### Market Depth Analysis

Market depth measures how much can be traded at or near the current price without significantly moving the market.

**Market impact model (square-root model):**
```
MarketImpact = sigma * sqrt(Q / V) * k
```

Where:
- `sigma` = daily volatility
- `Q` = quantity to trade
- `V` = average daily volume (ADV)
- `k` = market impact coefficient (calibrated, typically 0.5-1.5)

**Participation rate constraint:**
```
MaxParticipation = 20-25% of ADV per day (typical soft limit)
```

For a position of size Q at price P:
```
DaysToLiquidate = Q / (MaxParticipation * ADV)
LiquidationCost = MarketImpact + SpreadCost + OpportunityCost
```

### Liquidation Horizon

The liquidation horizon is the time required to fully unwind a position without undue market impact:

```
LiquidationHorizon(days) = PositionSize / (ParticipationRate * ADV)
```

Example:
```
Position: 500,000 shares of mid-cap stock
ADV: 200,000 shares
Max participation: 25%
Liquidation horizon: 500,000 / (0.25 * 200,000) = 10 days
```

Liquidity-adjusted VaR incorporates the liquidation horizon:

```
LVaR = VaR(1 day) * sqrt(LiquidationHorizon) + LiquidationCost
```

### Concentration Risk (Liquidity Dimension)

Concentration risk arises when a position is large relative to the market:

| Metric | Formula | Threshold |
|---|---|---|
| % of ADV | `Position / ADV` | >25% is concentrated |
| % of shares outstanding | `Position / SharesOutstanding` | >1% triggers disclosure (13F) |
| % of float | `Position / FreeFloat` | >5% is highly concentrated |
| Days to liquidate | `Position / (ParticipationRate * ADV)` | >5 days is illiquid |
| % of open interest | `Contracts / OpenInterest` (derivatives) | >10% is concentrated |

### Liquidity Stress Metrics

| Metric | Description |
|---|---|
| **Liquidity Coverage Ratio (LCR)** | High-quality liquid assets / 30-day net cash outflows >= 100% |
| **Net Stable Funding Ratio (NSFR)** | Available stable funding / Required stable funding >= 100% |
| **Cash Burn Rate** | Days of operations fundable from available cash |
| **Redemption Gate** | Max redemption per period (hedge funds) |
| **Funding Liquidity** | Ability to roll short-term funding (repo, CP, credit lines) |

---

## 4. Operational Risk

Operational risk is the risk of loss from inadequate or failed internal processes, people, systems, or external events.

### Trade Errors

| Error Type | Description | Prevention |
|---|---|---|
| **Wrong side** | Buy instead of sell, or vice versa | Confirmation dialogs, color-coded buy/sell |
| **Wrong size** | Incorrect quantity or notional | Order size reasonability checks |
| **Wrong instrument** | Trading the wrong ticker/ISIN | Instrument validation, search disambiguation |
| **Wrong account** | Booked to incorrect account | Default account rules, account validation |
| **Wrong price** | Limit price error (e.g., decimal point) | Price reasonability checks vs. market |
| **Duplicate order** | Same order submitted twice | Duplicate detection (idempotency keys) |

### Fat Finger Prevention

Fat finger controls are automated checks that reject clearly erroneous orders:

```
Order Validation Rules:
  1. Price within X% of market price (e.g., 5% for equities, 1% for FX)
  2. Quantity below maximum order size for instrument
  3. Notional below trader's single-order limit
  4. No duplicates within time window (e.g., same instrument/side/size within 5 seconds)
  5. Order does not exceed position limit when filled
  6. Order does not exceed buying power / margin availability
```

Price reasonability check:
```
ReferencePrice = LastTradePrice or MidQuote
MaxAllowedPrice = ReferencePrice * (1 + PriceTolerancePct)
MinAllowedPrice = ReferencePrice * (1 - PriceTolerancePct)

If OrderPrice > MaxAllowedPrice OR OrderPrice < MinAllowedPrice:
    REJECT order with "Price outside tolerance band"
```

### System Failures and Kill Switches

**Kill switch** is an emergency mechanism to halt all trading activity instantly:

| Kill Switch Level | Scope | Trigger |
|---|---|---|
| **Trader-level** | Cancel all orders for one trader | Trader request, limit breach |
| **Desk-level** | Cancel all orders for entire desk | Desk-level risk breach |
| **Firm-level** | Cancel all orders across the firm | System malfunction, market crisis |
| **Strategy-level** | Halt a specific algo/strategy | Strategy behaving abnormally |
| **Venue-level** | Stop routing to a specific venue | Venue connectivity issues |

Kill switch implementation:
```
1. Cancel-on-Disconnect (COD): Exchange automatically cancels all open orders if connection drops
2. Heartbeat monitoring: If algo fails to send heartbeat within N seconds, kill all orders
3. P&L circuit breaker: If strategy loses more than threshold, kill all orders and flatten
4. Message rate breaker: If order rate exceeds threshold, throttle or halt
5. Position breaker: If position exceeds limit, kill risk-increasing orders
```

**SEC Rule 15c3-5** (Market Access Rule) requires broker-dealers to implement:
- Pre-trade risk controls.
- Real-time monitoring.
- Kill switch capability.
- Annual CEO certification of controls.

### Operational Risk Metrics

| Metric | Description |
|---|---|
| **Trade break rate** | % of trades with booking errors |
| **Settlement fail rate** | % of trades failing to settle on time |
| **System uptime** | Availability of critical trading systems |
| **RTO / RPO** | Recovery Time Objective / Recovery Point Objective |
| **Error loss amount** | Dollar loss from operational errors (trailing 12 months) |
| **Near miss count** | Incidents caught before causing loss |

---

## 5. Pre-Trade Risk Controls

Pre-trade risk controls are synchronous checks evaluated before an order is sent to market. They must execute in microseconds to avoid adding unacceptable latency.

### Control Framework

```
[Trader Submits Order]
       |
       v
[1. Order Validation]        -- Format, required fields, instrument validity
       |
       v
[2. Price Reasonability]     -- Order price vs. reference price
       |
       v
[3. Size Limits]             -- Max order size, max notional per order
       |
       v
[4. Position Limits]         -- Would fill cause position limit breach?
       |
       v
[5. Credit/Margin Check]     -- Sufficient margin/buying power?
       |
       v
[6. Concentration Check]     -- Would fill cause concentration issue?
       |
       v
[7. Message Rate Throttle]   -- Within allowed order rate?
       |
       v
[8. Duplicate Check]         -- Not a duplicate of recent order?
       |
       v
[PASS: Route to Market]   or   [FAIL: Reject with reason code]
```

### Order Size Limits

| Limit | Description | Example |
|---|---|---|
| **Max shares per order** | Per-instrument quantity cap | 100,000 shares for large-cap, 10,000 for small-cap |
| **Max notional per order** | Dollar value cap per order | $5M per order |
| **Max notional per day** | Cumulative daily notional cap | $100M per day per trader |
| **Max % ADV per order** | Order as fraction of average daily volume | 5% of ADV per order |
| **Max orders per second** | Message rate limit | 100 orders/second per session |

### Price Reasonability Checks

```
Equity:
  Reject if OrderPrice deviates > 5% from NBBO midpoint
  Reject if OrderPrice deviates > 10% from last trade

Fixed Income:
  Reject if yield deviation > 25bps from benchmark

FX:
  Reject if rate deviates > 0.5% from ECN mid-rate

Options:
  Reject if price deviates > 50% from theoretical value
  Additional check: reject if implied vol > 200% or < 1%
```

### Position Limit Checks

Pre-trade position checks project the effect of filling the order:

```
ProjectedPosition = CurrentPosition + OrderQuantity (for buys)
ProjectedPosition = CurrentPosition - OrderQuantity (for sells/shorts)

ProjectedNotional = abs(ProjectedPosition) * ReferencePrice * Multiplier

If ProjectedPosition > MaxPositionLimit: REJECT
If ProjectedNotional > MaxNotionalLimit: REJECT
```

For aggregated limits (desk-level, firm-level), the check must query the central position server:

```
DeskProjectedExposure = DeskCurrentExposure + IncrementalExposure(Order)
If DeskProjectedExposure > DeskLimit: REJECT
```

### Notional Limits

| Level | Limit Type | Typical Value |
|---|---|---|
| Per order | Single order notional | $1M - $50M |
| Per trader per day | Cumulative daily notional | $50M - $500M |
| Per desk per day | Cumulative desk daily | $500M - $5B |
| Per instrument per day | Daily trading in one name | $10M - $100M |

### Message Rate Throttling

Exchanges and regulators impose message rate limits to prevent order flooding:

```
OrdersPerSecond check:
  Count orders in sliding window (1 second)
  If count > MaxRate: THROTTLE (queue or reject)

Common limits:
  Equity exchange: 50-300 messages/second per port
  Options exchange: 100-500 messages/second per port
  Futures exchange: 50-200 messages/second per port

Internal limits may be tighter:
  Per-trader: 10-50 orders/second
  Per-strategy: 20-100 orders/second
  Per-desk: 100-500 orders/second
```

Order-to-trade ratio monitoring:
```
OTR = OrderCount / TradeCount
Regulatory concern if OTR > 100:1 (varies by jurisdiction)
```

---

## 6. Real-Time Risk Calculations

### Options Greeks

The Greeks measure the sensitivity of an option's price to various factors. Professional systems compute these in real-time for every option position.

#### Delta

Rate of change of option price with respect to underlying price:

```
Delta = dV / dS

Call delta: 0 to +1 (typically expressed as 0 to 100)
Put delta:  -1 to 0 (typically expressed as -100 to 0)

Black-Scholes:
  Call Delta = N(d1)
  Put Delta = N(d1) - 1

Where:
  d1 = [ln(S/K) + (r - q + sigma^2/2) * T] / (sigma * sqrt(T))
  N() = cumulative standard normal distribution
  S = spot price
  K = strike price
  r = risk-free rate
  q = dividend yield
  sigma = implied volatility
  T = time to expiration (in years)
```

**Portfolio delta** (delta-equivalent exposure):
```
PortfolioDelta = sum_i (Delta_i * Quantity_i * Multiplier_i * SpotPrice_i)
```

This expresses the option portfolio as an equivalent position in the underlying.

#### Gamma

Rate of change of delta with respect to underlying price (second derivative):

```
Gamma = d^2V / dS^2 = dDelta / dS

Black-Scholes:
  Gamma = N'(d1) / (S * sigma * sqrt(T))

Where N'(x) = (1/sqrt(2*pi)) * exp(-x^2/2)  [standard normal PDF]
```

Gamma is highest for at-the-money options near expiration. Dollar gamma:
```
DollarGamma = 0.5 * Gamma * (SpotPrice)^2 * Quantity * Multiplier / 100
```

This represents the P&L from a 1% move in the underlying (approximately).

**Gamma P&L** for a delta-hedged portfolio:
```
GammaPnL = 0.5 * Gamma * (dS)^2 * Quantity * Multiplier
```

#### Vega

Sensitivity of option price to implied volatility:

```
Vega = dV / d(sigma)

Black-Scholes:
  Vega = S * N'(d1) * sqrt(T) * exp(-q*T)
```

Convention: Vega is quoted per 1 percentage point change in volatility.

```
Example: Vega = $0.15 means a 1% increase in IV increases option price by $0.15

Portfolio Vega = sum_i (Vega_i * Quantity_i * Multiplier_i)
```

For volatility surface risk, desks track vega by tenor and strike:

```
Vega Matrix:
              ATM    25D Put   25D Call   10D Put   10D Call
  1 Month    $50K    $20K      $25K       $8K       $10K
  3 Month    $80K    $35K      $40K       $15K      $18K
  6 Month    $120K   $50K      $55K       $22K      $25K
  1 Year     $200K   $85K      $90K       $40K      $45K
```

#### Theta

Rate of change of option price with respect to time (time decay):

```
Theta = dV / dT

Black-Scholes (call):
  Theta = -(S * N'(d1) * sigma * exp(-q*T)) / (2 * sqrt(T))
          - r * K * exp(-r*T) * N(d2)
          + q * S * exp(-q*T) * N(d1)
```

Convention: Theta is quoted as the daily loss (negative value). Theta is highest for at-the-money options near expiration.

```
Portfolio Theta = sum_i (Theta_i * Quantity_i * Multiplier_i)

Example: Portfolio Theta = -$45,000 means the portfolio loses $45K per day from time decay
```

#### Rho

Sensitivity of option price to interest rates:

```
Rho = dV / dr

Black-Scholes:
  Call Rho = K * T * exp(-r*T) * N(d2)
  Put Rho = -K * T * exp(-r*T) * N(-d2)
```

Rho is generally less significant for short-dated options but matters for long-dated options and LEAPS.

### Fixed Income Risk Measures

#### DV01 / PV01

**DV01 (Dollar Value of a Basis Point)**: The change in bond price for a 1 basis point (0.01%) parallel shift in the yield curve.

```
DV01 = -(dP / dy) * 0.0001

Approximation:
DV01 = (P(y - 0.5bp) - P(y + 0.5bp)) / 2
```

**PV01 (Present Value of a Basis Point)**: Essentially the same concept; sometimes used to denote the DV01 of a swap (the change in PV for a 1bp shift in the swap rate).

```
For a bond:
  DV01 = ModifiedDuration * Price * 0.0001

Example:
  Bond price: $100
  Modified duration: 7.5 years
  DV01 = 7.5 * 100 * 0.0001 = $0.075 per $100 face value
  For $10M face: DV01 = $7,500 per basis point
```

#### Key Rate DV01s

Rather than assuming a parallel shift, key rate DV01s measure sensitivity to shifts at specific tenor points:

```
KeyRateDV01(tenor) = change in portfolio value for 1bp shift at that tenor only

Standard tenor points: 3M, 6M, 1Y, 2Y, 3Y, 5Y, 7Y, 10Y, 15Y, 20Y, 30Y

Example (portfolio of bonds and swaps):
  Tenor    KeyRate DV01
  2Y       -$2,500
  5Y       +$8,200
  10Y      -$15,800
  30Y      +$5,100
  Total    -$5,000 (=parallel DV01)
```

#### Spread Duration / CS01

**CS01 (Credit Spread 01)**: The change in value for a 1bp widening of credit spreads.

```
CS01 = -(dP / dSpread) * 0.0001

For a corporate bond:
  CS01 = SpreadDuration * Price * 0.0001 * FaceValue
```

#### Convexity

The second derivative of price with respect to yield:

```
Convexity = (1/P) * d^2P / dy^2

Price change including convexity:
  dP/P = -ModifiedDuration * dy + 0.5 * Convexity * (dy)^2
```

Convexity matters for large rate moves. Positive convexity (plain bonds) means the price increase from a rate drop exceeds the price decrease from an equal rate rise.

### Beta Exposure

Beta measures systematic risk relative to a market benchmark:

```
PortfolioBeta = sum_i (Weight_i * Beta_i)

Beta-adjusted exposure = sum_i (Notional_i * Beta_i)
```

Example:
```
Position       Notional    Beta    Beta-Adj Exposure
AAPL Long      $5M         1.15    $5.75M
XOM Long       $3M         0.85    $2.55M
SPY Short      -$4M        1.00    -$4.00M
                                   --------
Beta-Adj Net Exposure:              $4.30M
Portfolio Beta:                     0.72
```

### Real-Time Calculation Architecture

```
[Market Data Feed]
       |
  [Tick Plant / Normalized Feed]
       |
  +---------+---------+---------+
  |         |         |         |
[Equity  [Rates   [Vol      [FX
 Pricer]  Engine]  Surface]  Engine]
  |         |         |         |
  +----+----+----+----+
       |
  [Risk Aggregation Engine]
       |
  +----+----+----+----+
  |         |         |
[Greeks  [VaR     [Stress
 Server]  Engine]  Engine]
       |
  [Risk Dashboard / Alerts]
```

Latency targets:
- Greeks update: < 100ms after market tick
- Position P&L: < 50ms after trade or tick
- Portfolio VaR: 1-5 minute refresh cycle (full recomputation)
- Stress scenarios: 1-15 minute refresh cycle

---

## 7. Risk Limits and Breaches

### Limit Types

| Limit Type | Description | Enforcement |
|---|---|---|
| **Hard limit** | Absolute maximum; cannot be exceeded | Automated rejection of risk-increasing orders |
| **Soft limit** | Warning threshold; temporary exceedance allowed | Alert to risk manager; must be resolved promptly |
| **Regulatory limit** | Externally mandated by regulators | Hard enforcement; breach is a compliance violation |
| **Board limit** | Set by the board of directors | Hard enforcement; breach requires board notification |
| **Desk limit** | Allocated to a trading desk | Hard or soft, depending on desk/firm policy |
| **Trader limit** | Allocated to an individual trader | Typically hard for junior traders, soft for senior |

### Limit Hierarchy

```
Board / Enterprise Level
├── VaR Limit: $50M (99%, 1-day)
├── Stress Loss Limit: $200M
├── Gross Notional: $10B
│
├── Division Level (e.g., Markets)
│   ├── VaR Limit: $30M
│   ├── Stress Loss Limit: $120M
│   │
│   ├── Desk Level (e.g., Equity Derivatives)
│   │   ├── VaR Limit: $10M
│   │   ├── Delta Limit: +/- $500M
│   │   ├── Gamma Limit: +/- $5M per 1%
│   │   ├── Vega Limit: +/- $3M per 1 vol pt
│   │   ├── Theta Limit: -$200K per day
│   │   │
│   │   ├── Trader Level (e.g., J. Smith)
│   │   │   ├── VaR Limit: $2M
│   │   │   ├── Max Single Name: $50M notional
│   │   │   ├── Max Gross: $200M
│   │   │   └── Max Loss (stop loss): $500K per day
│   │   │
│   │   └── Strategy Level (e.g., Vol Arb)
│   │       ├── VaR Limit: $3M
│   │       └── Vega Limit: +/- $1M
```

### Limit Monitoring

Real-time limit utilization is computed as:

```
Utilization = CurrentMetric / LimitValue * 100%
```

| Utilization | Status | Action |
|---|---|---|
| 0-75% | Green | Normal operations |
| 75-90% | Amber | Warning: notify trader and risk manager |
| 90-100% | Red | Critical: requires risk reduction plan or approval to continue |
| >100% | Breach | Immediate escalation; only risk-reducing trades allowed |

### Breach Escalation

```
Breach Detection (automated)
       |
       v
Immediate Notification
  - Trader (pop-up alert, email, Bloomberg message)
  - Desk head
  - Risk manager
       |
       v
Classification
  - Technical breach (timing, stale data) vs. genuine breach
  - Active breach (still over) vs. passive breach (market moved)
       |
       v
If Active Breach:
  - Only risk-reducing trades permitted
  - Trader must propose reduction plan
  - Risk manager must approve timeline
       |
       v
Escalation Timeline:
  T+0: Risk manager notified, remediation plan required
  T+1: If not resolved, escalate to desk head
  T+2: If not resolved, escalate to CRO
  T+5: If not resolved, escalate to board risk committee
```

### Active vs. Passive Breaches

| Breach Type | Cause | Treatment |
|---|---|---|
| **Active** | Trader deliberately exceeds limit | Serious; disciplinary action possible |
| **Passive** | Market movement causes limit exceedance (e.g., vol spike increases VaR) | Less severe; reasonable time to remediate |
| **Technical** | System error, stale data, or model recalibration | Investigate and correct; not a true breach |

### Limit Utilization Dashboard

```
+------------------------------------------------------------------------+
| RISK LIMIT DASHBOARD - Equity Derivatives Desk    2024-03-15 14:30 UTC |
+------------------------------------------------------------------------+
| LIMIT                  | VALUE      | LIMIT      | UTIL%  | STATUS    |
|------------------------|------------|------------|--------|-----------|
| 99% 1d VaR             | $8.7M      | $10.0M     | 87%    | AMBER     |
| 97.5% 1d ES            | $12.1M     | $15.0M     | 81%    | AMBER     |
| Portfolio Delta         | +$320M     | +/-$500M   | 64%    | GREEN     |
| Portfolio Gamma (1%)    | -$2.8M     | +/-$5.0M   | 56%    | GREEN     |
| Portfolio Vega (1vol)   | +$2.4M     | +/-$3.0M   | 80%    | AMBER     |
| Portfolio Theta (daily) | -$185K     | -$200K     | 93%    | RED       |
| Max Single Name Delta   | $48M (TSLA)| $50M       | 96%    | RED       |
| Gross Notional          | $1.8B      | $2.5B      | 72%    | GREEN     |
| Daily P&L               | -$380K     | -$500K SL  | 76%    | AMBER     |
+------------------------------------------------------------------------+
| ACTIVE BREACHES: 0     | WARNINGS: 4                                  |
+------------------------------------------------------------------------+
```

### Stop-Loss Limits

Stop-loss limits trigger mandatory position reduction when cumulative losses exceed a threshold:

```
Types:
  Daily stop-loss:   Max daily P&L loss (e.g., -$500K)
  Weekly stop-loss:  Max weekly cumulative loss (e.g., -$1.5M)
  Monthly stop-loss: Max monthly cumulative loss (e.g., -$3M)
  YTD stop-loss:     Max year-to-date loss (e.g., -$10M)

When triggered:
  1. Halt all risk-increasing activity
  2. Flatten or hedge existing positions
  3. Remain flat until reset period (next day, next week, etc.) or management approval
```

---

## 8. Stress Testing and Scenario Analysis

### Historical Scenarios

Historical stress tests replay actual market events against the current portfolio:

#### Implementation

```
1. Select historical period (e.g., March 2020 COVID crash, days March 9-23)
2. For each trading day in the period:
   a. Extract actual changes in all risk factors (prices, rates, vols, spreads, FX)
   b. Apply those changes to current portfolio holdings
   c. Revalue entire portfolio
   d. Record daily P&L
3. Report:
   - Cumulative loss over the period
   - Worst single-day loss
   - Maximum drawdown
   - Risk factor attribution of losses
```

#### Standard Historical Scenarios Library

```
Scenario: "2008 Global Financial Crisis (Peak Stress)"
  S&P 500:          -17% (October 2008 worst week)
  VIX:              +40 points (to ~80)
  10Y UST yield:    -50bps (flight to quality)
  IG credit spread: +200bps
  HY credit spread: +800bps
  USD/EUR:          +8%
  Oil:              -30%

Scenario: "2020 COVID Crash"
  S&P 500:          -12% (March 16, 2020 single day)
  VIX:              +30 points
  10Y UST yield:    -30bps
  IG credit spread: +150bps
  HY credit spread: +500bps
  Gold:             -3% (initially sold for liquidity)
```

### Hypothetical Scenarios

Hypothetical scenarios are designed by risk managers to test specific vulnerabilities:

```
Scenario: "Sudden Rate Hike"
  Fed funds rate:     +75bps immediately
  2Y UST yield:       +100bps
  10Y UST yield:      +50bps (flattening)
  30Y UST yield:      +25bps
  IG credit spreads:  +30bps
  Equity:             -5%
  USD:                +3% vs. all currencies

Scenario: "China Devaluation"
  USD/CNH:            +10%
  Hang Seng:          -15%
  Shanghai Composite: -10%
  EM FX:              -5% to -15%
  US equities:        -5%
  UST 10Y yield:      -25bps (flight to safety)
  Copper:             -20%
  Iron ore:           -25%

Scenario: "Cybersecurity Attack on Major Exchange"
  Market closure:     2 days
  Equity -8% on reopening
  VIX:                +25 points
  All spreads:        +50bps
  Counterparty risk:  Mark down affected exchange clearing member exposure
```

### Reverse Stress Testing

Reverse stress testing starts from a defined loss level and works backward to identify what scenarios would cause it:

```
Question: "What market moves would cause the portfolio to lose $50M?"

Method:
1. Define the loss threshold: $50M
2. Identify the portfolio's key risk sensitivities (largest Greeks, DV01, etc.)
3. Search for combinations of risk factor moves that produce the target loss:
   
   Optimization:
     min ||delta_RF||^2  (minimize severity of risk factor changes)
     subject to: PortfolioLoss(delta_RF) >= $50M
   
4. Report the most plausible (least extreme) scenarios that produce the target loss.

Output:
  "The portfolio would lose $50M if:
   - Equities fall 8% AND credit spreads widen 150bps, OR
   - Interest rates rise 75bps AND the yield curve flattens 50bps, OR
   - Implied volatility drops 10 points AND the underlying rallies 5%"
```

### Stress Testing Governance

| Element | Requirement |
|---|---|
| **Frequency** | Daily for core scenarios; weekly/monthly for expanded set |
| **Scenario review** | Quarterly review of scenario relevance; add new scenarios for emerging risks |
| **Limits** | Stress loss limits set at board/enterprise level |
| **Reporting** | Results reported to CRO, risk committee, and regulators |
| **Action triggers** | If stress loss exceeds threshold, mandatory risk reduction |
| **Documentation** | Full documentation of methodology, assumptions, and limitations |
| **Independent validation** | Model validation team reviews stress testing models annually |

### Sensitivity Analysis (Bump-and-Reprice)

The simplest form of stress testing: shift one risk factor at a time and measure impact.

```
Standard equity sensitivity grid:
  Spot move:  -20%, -10%, -5%, -2%, -1%, 0, +1%, +2%, +5%, +10%, +20%
  Vol move:   -10pts, -5pts, -2pts, -1pt, 0, +1pt, +2pt, +5pts, +10pts

Result matrix (P&L in $000s):
              Spot -10%   Spot -5%   Spot 0   Spot +5%   Spot +10%
  Vol -5pts    -$2,800    -$1,200    +$300    +$1,500    +$2,100
  Vol -2pts    -$2,500    -$1,000    +$200    +$1,600    +$2,300
  Vol 0        -$2,300    -$900      +$100    +$1,700    +$2,500
  Vol +2pts    -$2,000    -$700      +$50     +$1,900    +$2,800
  Vol +5pts    -$1,600    -$400      -$100    +$2,200    +$3,200
```

---

## 9. Regulatory Risk Requirements

### Basel III / IV Framework

The Basel framework establishes minimum capital requirements for banks. Basel III was implemented post-2008 crisis; Basel IV (also called the "final Basel III reforms") was finalized in 2017 with implementation in 2023-2028.

#### Capital Components

```
Total Capital = Common Equity Tier 1 (CET1) + Additional Tier 1 (AT1) + Tier 2

Minimum requirements (as % of Risk-Weighted Assets):
  CET1:          4.5%
  Tier 1:        6.0%
  Total Capital: 8.0%

Plus buffers:
  Capital Conservation Buffer:  2.5%
  Countercyclical Buffer:       0-2.5% (jurisdiction-specific)
  G-SIB Surcharge:              1-3.5% (for globally systemically important banks)
  
Effective CET1 for large banks: 10-13%+ of RWA
```

#### Risk-Weighted Assets (RWA)

```
Total RWA = RWA_Credit + RWA_Market + RWA_Operational

Market Risk RWA (under standardized approach):
  RWA_Market = 12.5 * CapitalCharge_Market
```

### FRTB (Fundamental Review of the Trading Book)

FRTB is the Basel Committee's overhaul of market risk capital requirements, replacing the previous Basel 2.5 framework.

#### Key Changes

| Feature | Previous (Basel 2.5) | FRTB |
|---|---|---|
| **Risk measure** | VaR + Stressed VaR | Expected Shortfall (ES) |
| **Confidence level** | 99% VaR | 97.5% ES |
| **Liquidity horizon** | 10 days (uniform) | Variable by risk factor (10-120 days) |
| **P&L attribution** | Not required | Required for IMA approval |
| **Trading/banking book boundary** | Flexible (intent-based) | Stricter rules, regulatory approval for reclassification |
| **Default risk** | IRC (Incremental Risk Charge) | DRC (Default Risk Charge) with stricter methodology |
| **Desk-level approval** | Firm-wide model | Each desk must individually qualify for IMA |

#### FRTB Standardized Approach (SA)

The SA uses a sensitivities-based method:

```
Capital = SensitivityBasedCharge + DefaultRiskCharge + ResidualRiskAddOn

SensitivityBasedCharge = f(Delta, Vega, Curvature) across 7 risk classes:
  1. General Interest Rate Risk (GIRR)
  2. Credit Spread Risk (non-securitization)
  3. Credit Spread Risk (securitization, non-CTP)
  4. Credit Spread Risk (securitization, CTP)
  5. Equity Risk
  6. Commodity Risk
  7. FX Risk
```

#### FRTB Internal Models Approach (IMA)

```
IMA Capital = max(ES_t-1, Multiplier * ES_avg) + DRC + SES

Where:
  ES = Expected Shortfall at 97.5% confidence
  ES is computed with varying liquidity horizons:
    ES = sqrt( ES(10d)^2 + sum_j [ ES_j(LH_j)^2 - ES_j(10d)^2 ] )
  
  Liquidity Horizons (LH):
    10 days: Large-cap equities, major FX pairs, major sovereign bonds
    20 days: Small-cap equities, minor FX pairs, IG credit
    40 days: Equity vol, cross-currency basis, HY credit
    60 days: EM sovereign, securitizations
    120 days: Bespoke correlation, longevity risk

  Multiplier = 1.5 (base) + penalty (0 to 0.5 based on backtesting exceptions)
  DRC = Default Risk Charge (similar to IRC but stricter)
  SES = Stressed Expected Shortfall (calibrated to a stressed period)
```

#### P&L Attribution Test (PLAT)

For a desk to use IMA, it must pass the PLAT:

```
Compare:
  Hypothetical P&L (HPL): P&L from full revaluation using actual market moves
  Risk-Theoretical P&L (RTPL): P&L estimated by the risk model

Metrics:
  Spearman correlation: corr(HPL, RTPL) 
  KL divergence: KL(HPL || RTPL)

Pass criteria:
  Correlation > 0.7 AND KL divergence < 0.09: GREEN (IMA allowed)
  Correlation > 0.6 OR KL divergence < 0.12: AMBER (warning)
  Otherwise: RED (desk must use SA)
```

### Margin Requirements for Non-Cleared Derivatives

Post-crisis regulations require bilateral margin exchange for OTC derivatives not cleared through a CCP.

#### Initial Margin (IM) - ISDA SIMM

The **ISDA Standard Initial Margin Model (SIMM)** is the industry-standard model:

```
SIMM calculates IM based on trade sensitivities:

IM = sqrt( sum_rc [ IM_rc^2 ] + 2 * sum_{rc1 < rc2} [ psi * IM_rc1 * IM_rc2 ] )

Where:
  rc = risk class (IR, Credit, Equity, Commodity, FX)
  psi = cross-risk-class correlation

Within each risk class:
  IM_rc = sqrt( sum_b [ K_b^2 ] + 2 * sum_{b1 < b2} [ gamma * S_b1 * S_b2 ] )

Where:
  b = bucket (e.g., currency for IR, sector for equity)
  K_b = within-bucket aggregation of weighted sensitivities
  gamma = cross-bucket correlation
  S_b = sum of weighted sensitivities in bucket b
```

SIMM risk weights by risk class (examples):

| Risk Class | Risk Factor | Weight |
|---|---|---|
| Interest Rates | 2Y tenor, regular currency | 61 bps |
| Interest Rates | 10Y tenor, regular currency | 52 bps |
| Credit (qualifying) | 5Y investment grade | 59 bps |
| Equity | Large-cap developed market | 21% |
| FX | Any currency pair | 7.4% |

#### Variation Margin (VM)

```
VM = max(0, NetMTM - CollateralReceived) for collateral calls
VM = max(0, -NetMTM - CollateralPosted) for collateral returns

VM exchange frequency: Daily (T+1 settlement)
VM threshold: $0 (full collateralization required under new regulations)
```

#### Phase-In Thresholds

Bilateral margin rules were phased in by AANA (Aggregate Average Notional Amount):

| Phase | Date | AANA Threshold |
|---|---|---|
| Phase 1 | Sep 2016 | > EUR 3T |
| Phase 2 | Sep 2017 | > EUR 2.25T |
| Phase 3 | Sep 2018 | > EUR 1.5T |
| Phase 4 | Sep 2019 | > EUR 0.75T |
| Phase 5 | Sep 2021 | > EUR 50B |
| Phase 6 | Sep 2022 | > EUR 8B |

---

## 10. Risk Attribution and Decomposition

### Factor-Based Risk Models

Factor models decompose portfolio risk into systematic factors and idiosyncratic (stock-specific) risk:

```
Return_i = alpha_i + sum_k (Beta_ik * Factor_k) + epsilon_i

Where:
  Return_i = return of asset i
  alpha_i = stock-specific expected return
  Beta_ik = exposure (loading) of asset i to factor k
  Factor_k = return of factor k
  epsilon_i = idiosyncratic return (uncorrelated across assets)
```

**Portfolio variance decomposition:**

```
Var(R_p) = w' * B * F * B' * w + w' * D * w

Where:
  w = vector of portfolio weights
  B = matrix of factor exposures (N assets x K factors)
  F = K x K factor covariance matrix
  D = N x N diagonal matrix of specific variances (idiosyncratic risk)

Systematic Risk = w' * B * F * B' * w
Idiosyncratic Risk = w' * D * w
Total Risk = Systematic Risk + Idiosyncratic Risk
```

### Common Risk Factor Taxonomies

#### Barra / MSCI Factor Model

```
Style Factors:
  - Value (book-to-price, earnings yield, dividend yield)
  - Growth (earnings growth, sales growth)
  - Momentum (12-month return minus 1-month return)
  - Size (log market cap)
  - Volatility (historical and predicted beta, daily return vol)
  - Leverage (debt-to-equity, book leverage)
  - Liquidity (share turnover, trading volume)
  - Quality (ROE, earnings stability, balance sheet accruals)

Industry/Sector Factors:
  - GICS Level 2 (24 Industry Groups) or Level 3 (69 Industries)

Country Factors:
  - Country of domicile or country of risk

Currency Factors:
  - Currency denomination of asset
```

#### Fixed Income Factor Model

```
Factors:
  - Level (parallel shift in yield curve)
  - Slope (steepening/flattening: 2s10s spread)
  - Curvature (butterfly: 2s vs 5s vs 10s)
  - Credit spread (IG, HY, by rating)
  - Sector spread (financials, industrials, utilities, etc.)
  - Liquidity premium
  - Inflation expectations (breakeven inflation rate)
  - Prepayment factor (MBS-specific)
```

### Sector Risk Decomposition

```
Portfolio Risk by GICS Sector:

Sector              Weight   Beta   Contrib to VaR   % of Total VaR
Technology          28%      1.25   $3.2M            32%
Financials          18%      1.10   $1.8M            18%
Healthcare          15%      0.85   $1.1M            11%
Consumer Disc.      12%      1.20   $1.4M            14%
Industrials         10%      1.05   $0.9M            9%
Energy               8%      1.30   $1.0M            10%
Other                9%      0.90   $0.6M            6%
                   -----                             -----
Total              100%              $10.0M           100%

Note: Contributions sum to total due to correlation effects.
The contribution-to-VaR calculation accounts for inter-sector correlations.
```

### Country/Geography Risk Decomposition

```
Risk by Country of Risk:

Country          Weight   Contrib to VaR   % of Total VaR   Country VaR
US               55%      $4.5M            45%              $8.2M
UK               12%      $1.3M            13%              $1.9M
Japan            10%      $0.8M            8%               $1.5M
Germany           8%      $0.9M            9%               $1.4M
China             5%      $1.2M            12%              $3.0M
Brazil            3%      $0.8M            8%               $2.8M
Other             7%      $0.5M            5%               $1.0M
                 -----    ------           -----
Total           100%      $10.0M           100%
```

### Style/Factor Risk Decomposition

```
Factor Risk Decomposition:

Factor          Exposure   Factor Vol   Contrib to Risk   % of Systematic
Market          1.05       15.0%        $5.2M             52%
Value          -0.30       4.5%         $0.8M             8%
Momentum        0.45       5.2%         $1.1M             11%
Size           -0.15       3.8%         $0.4M             4%
Volatility      0.20       6.1%         $0.7M             7%
Quality         0.35       3.2%         $0.5M             5%
Sector effects  ---        ---          $0.8M             8%
Currency        ---        ---          $0.5M             5%
                                        ------            -----
Systematic Risk                         $10.0M            100%
Idiosyncratic Risk                      $3.2M
                                        ------
Total Risk                              $13.2M
```

### Marginal and Component Risk

#### Marginal VaR

The change in portfolio VaR from a small increase in a position:

```
Marginal VaR_i = dVaR / dw_i

For parametric VaR:
  Marginal VaR_i = z_alpha * (Sigma * w)_i / sigma_p

Where:
  (Sigma * w)_i = row i of the covariance matrix times the weight vector
  sigma_p = portfolio standard deviation
```

Marginal VaR tells you which position to add to (or reduce) to most efficiently change portfolio risk.

#### Component VaR

The contribution of each position to total portfolio VaR:

```
Component VaR_i = w_i * Marginal VaR_i

Property: sum of all Component VaRs = Total VaR
  sum_i (CVaR_i) = VaR_portfolio
```

This is the standard tool for risk budgeting: allocating total risk to individual positions.

```
Example:
Position    Weight   Marginal VaR   Component VaR   % Contribution
AAPL        15%      $0.82M         $1.23M          12.3%
MSFT        12%      $0.75M         $0.90M          9.0%
GOOGL       10%      $0.88M         $0.88M          8.8%
SPY Hedge   -20%     -$0.65M        $1.30M          13.0%
Bonds       30%      $0.15M         $0.45M          4.5%
...         ...      ...            ...             ...
                                    -------         -----
Total                               $10.0M          100%
```

#### Incremental VaR

The change in portfolio VaR from adding (or removing) an entire position:

```
Incremental VaR = VaR(portfolio with position) - VaR(portfolio without position)
```

Unlike marginal VaR (infinitesimal change), incremental VaR captures the full non-linear impact.

### Risk Attribution Over Time

Risk attribution can also be performed across time to explain changes in portfolio risk:

```
VaR Change Attribution (Day over Day):

VaR(T-1) = $9.2M
VaR(T)   = $10.5M
Change   = +$1.3M

Attribution:
  New trades:               +$0.4M (added long equity positions)
  Position changes:         +$0.2M (didn't rebalance hedge)
  Volatility changes:       +$0.5M (realized vol increased)
  Correlation changes:      +$0.3M (correlations moved toward 1)
  Methodology/model change: -$0.1M (recalibrated vol surface)
                            ------
  Total explained:          +$1.3M
```

### Risk Reporting Hierarchy

```
Board Risk Committee
  ├── Enterprise Risk Report (monthly)
  │     - Firmwide VaR, ES, stress test results
  │     - Capital adequacy ratios
  │     - Limit utilization summary
  │     - Top 10 risk concentrations
  │     - Backtesting results
  │
  ├── CRO Daily Risk Report
  │     - All desk VaR and limit utilization
  │     - Breach summary
  │     - Stress test P&L by desk
  │     - Counterparty exposure summary
  │
  ├── Desk Head Report (real-time + daily)
  │     - Desk VaR, Greeks, P&L
  │     - Position detail with limits
  │     - Trader-level attribution
  │     - Scenario P&L
  │
  └── Trader Dashboard (real-time)
        - Position-level P&L
        - Greeks for each position
        - Limit utilization (personal)
        - Market data
```

---

## Appendix A: VaR Backtesting

Backtesting validates VaR model accuracy by comparing predicted VaR to actual P&L:

```
For each day t:
  If ActualLoss(t) > VaR(t):  count as an "exception"

Expected exceptions at 99% confidence over 250 days: 2.5

Basel Traffic Light System:
  Green zone:  0-4 exceptions  (no penalty)
  Yellow zone: 5-9 exceptions  (multiplier increased 0.4-0.85)
  Red zone:    10+ exceptions  (multiplier = 1.0 penalty; model review required)
```

Formal statistical tests:

**Kupiec POF Test:**
```
LR_POF = -2 * ln[(1-p)^(N-x) * p^x] + 2 * ln[(1-x/N)^(N-x) * (x/N)^x]

Where:
  p = expected exception rate (e.g., 0.01 for 99% VaR)
  N = number of observations
  x = number of exceptions

LR_POF ~ chi-squared(1) under H0
```

**Christoffersen Independence Test:**
Tests whether exceptions are independently distributed (not clustered).

## Appendix B: Key Formulas Reference

| Measure | Formula |
|---|---|
| Parametric VaR | `z * sigma_p * sqrt(T)` |
| Expected Shortfall | `E[Loss \| Loss > VaR]` |
| Delta | `dV/dS` or `N(d1)` for BS |
| Gamma | `d^2V/dS^2` |
| Vega | `dV/d(sigma)` |
| Theta | `dV/dT` |
| DV01 | `ModDuration * Price * 0.0001` |
| CS01 | `SpreadDuration * Price * 0.0001` |
| Component VaR | `w_i * dVaR/dw_i` |
| CVA | `(1-R) * integral[DF(t) * EPE(t) * dPD(t)]` |
| SIMM IM | `sqrt(sum[IM_rc^2] + 2*sum[psi*IM_rc1*IM_rc2])` |
| Market Impact | `sigma * sqrt(Q/V) * k` |
| LVaR | `VaR * sqrt(LiqHorizon) + LiquidationCost` |
| Portfolio Beta | `sum(w_i * Beta_i)` |
| HHI | `sum(w_i^2)` |
