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
