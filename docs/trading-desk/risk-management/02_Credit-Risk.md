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
