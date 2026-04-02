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
