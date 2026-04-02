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
