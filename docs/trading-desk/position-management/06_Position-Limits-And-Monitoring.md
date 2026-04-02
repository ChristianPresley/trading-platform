## 10. Position Limits and Monitoring

### Limit Types

Professional trading desks enforce multiple layers of position limits:

| Limit Type | Scope | Example |
|---|---|---|
| **Per-Trader** | Individual trader limits | Max $10M net notional per trader |
| **Per-Desk** | Aggregate desk limits | Max $100M gross notional for equity desk |
| **Per-Instrument** | Single security concentration | Max 50,000 shares of any single name |
| **Per-Sector** | GICS sector exposure | Max 30% of NAV in Technology |
| **Per-Country** | Country concentration | Max 15% of NAV in any emerging market country |
| **Per-Asset-Class** | Asset class allocation | Max 40% of NAV in fixed income |
| **Per-Strategy** | Strategy allocation | Max $25M to mean-reversion strategy |
| **Per-Issuer** | Issuer concentration | Max 5% of NAV in any single issuer |
| **Per-Currency** | Currency exposure | Max 20% unhedged FX exposure |
| **Per-Tenor** | Maturity bucket (fixed income) | Max $50M DV01 in 10Y+ bucket |

### Limit Metrics

Limits can be expressed in various units:

| Metric | Description |
|---|---|
| **Quantity** | Number of shares/contracts |
| **Notional** | Market value of position |
| **% of NAV** | Position as percentage of fund net asset value |
| **% of ADV** | Position as percentage of average daily volume |
| **DV01** | Dollar value of 1bp interest rate move |
| **Delta-adjusted** | Options positions expressed as delta-equivalent underlying |
| **VaR** | Value at Risk contribution |
| **Margin** | Margin requirement as limit measure |

### Limit Monitoring Architecture

```
[Trade Entry / OMS]
        |
        v
[Pre-Trade Limit Check]  <-- Synchronous, blocks order if limit breached
        |
        v
[Order Routing / Execution]
        |
        v
[Post-Trade Position Update]
        |
        v
[Real-Time Limit Monitor]  <-- Asynchronous, alerts on utilization thresholds
        |
        v
[Alert / Dashboard / Escalation Engine]
```

### Utilization Thresholds

Limits typically have multiple alert thresholds:

| Utilization Level | Action |
|---|---|
| 0-75% | Green: Normal trading |
| 75-90% | Amber: Warning alert to trader and risk manager |
| 90-100% | Red: Urgent alert, reduced order sizes, requires approval for new positions |
| >100% | Breach: Trading halted for risk-increasing trades, escalation to management |

### Hard Limits vs. Soft Limits

| Characteristic | Hard Limit | Soft Limit |
|---|---|---|
| Enforcement | Automated rejection of orders | Alert-based, allows temporary exceedance |
| Override | Requires senior management approval | Trader can acknowledge and proceed (within reason) |
| Example | Regulatory position limits (CFTC speculative limits) | Internal risk budget guidelines |
| Audit trail | Full log of any override | Log of acknowledgment |

### Regulatory Position Limits

| Regulation | Scope | Example |
|---|---|---|
| **CFTC Speculative Limits** | US futures | Spot month limits on agricultural, energy, metals |
| **SEC Rule 105** | Short selling before offerings | No short sales within 5 business days of offering |
| **EU Short Selling Regulation** | European equities | Reporting at 0.1% of issued share capital, public disclosure at 0.5% |
| **Section 13(d)/13(g)** | Beneficial ownership | Report within 10 days of crossing 5% of outstanding shares |
| **Hart-Scott-Rodino** | Merger control | Filing required for acquisitions above threshold (~$111.4M in 2023) |

### Position Limit Calculation Example

```
Trader: J. Smith
Desk: US Equity Long/Short
Base Currency: USD
NAV: $500,000,000

Limit Framework:
  Max Gross Notional: $1,000,000,000 (200% of NAV)
  Max Net Notional: $250,000,000 (50% of NAV)
  Max Single Name: $25,000,000 (5% of NAV)
  Max Sector: $150,000,000 (30% of NAV)
  Max Single Name % ADV: 15%

Current Positions:
  Long Notional:  $620,000,000
  Short Notional: $480,000,000
  Gross Notional: $1,100,000,000 ** BREACH: 220% > 200% limit **
  Net Notional:   $140,000,000  (OK: 28% < 50% limit)

  Largest Single Name: AAPL $30,000,000 ** BREACH: 6% > 5% limit **
  Tech Sector: $145,000,000 (OK: 29% < 30% limit)
```

### Concentration Limits

Concentration risk is monitored across multiple dimensions:

```
HHI (Herfindahl-Hirschman Index) = sum((Weight_i)^2) for all positions i

Interpretation:
  HHI < 0.01:  Highly diversified
  0.01-0.15:   Unconcentrated
  0.15-0.25:   Moderate concentration
  HHI > 0.25:  High concentration
```

Top-N concentration:
```
Top 5 Concentration = sum of top 5 position weights as % of total
Top 10 Concentration = sum of top 10 position weights as % of total
```

Many funds target Top 10 concentration below 40-50% of NAV.

### Real-Time Monitoring Dashboard

A typical position limit monitoring dashboard displays:

```
+------------------------------------------------------------------+
| POSITION LIMIT MONITOR - US Equity Desk      2024-03-15 14:35:22 |
+------------------------------------------------------------------+
| Metric              | Current    | Limit      | Util% | Status   |
|---------------------|------------|------------|-------|----------|
| Gross Notional      | $980M      | $1,000M    | 98%   | RED      |
| Net Notional        | $120M      | $250M      | 48%   | GREEN    |
| Max Single Name     | $24.5M     | $25M       | 98%   | RED      |
| Tech Sector         | $140M      | $150M      | 93%   | RED      |
| EM Country Max      | $42M       | $75M       | 56%   | GREEN    |
| VaR (95%, 1d)       | $8.2M      | $10M       | 82%   | AMBER    |
| Leverage            | 3.8x       | 4.0x       | 95%   | RED      |
+------------------------------------------------------------------+
| ACTIVE BREACHES: 0                                                |
| WARNINGS: Gross Notional approaching limit                       |
+------------------------------------------------------------------+
```

