## Intraday Monitoring Checklists and Operational Dashboards

### 11.1 Intraday Monitoring Checklists

Operations and technology teams run scheduled checks throughout the trading day to detect problems before they escalate.

**Pre-Market Checklist** (60-90 minutes before market open):

| # | Check | Owner | Status |
|---|---|---|---|
| 1 | SOD positions loaded and reconciled | Operations | |
| 2 | All FIX sessions connected | IT/Operations | |
| 3 | Market data feeds active and ticking | IT | |
| 4 | Risk limits loaded and active | Risk | |
| 5 | Compliance rules loaded (restricted list, etc.) | Compliance | |
| 6 | Reference data loaded (instruments, calendars) | IT | |
| 7 | Overnight batch completed successfully | IT | |
| 8 | Outstanding breaks reviewed | Operations | |
| 9 | System performance nominal (CPU, memory, latency) | IT | |
| 10 | DR replication current | IT | |
| 11 | Known issues / system changes reviewed | IT/Operations | |
| 12 | Trading readiness sign-off | Operations Manager | |

**Mid-Morning Check** (1-2 hours after market open):

| # | Check | Owner |
|---|---|---|
| 1 | Order flow is normal (no stuck orders, no unusual rejections) | Operations |
| 2 | FIX session health (message counts, sequence numbers, no gaps) | IT |
| 3 | Market data quality (no stale feeds, no anomalous prices) | IT |
| 4 | P&L is calculating correctly (spot-check against manual estimate) | Operations |
| 5 | Risk utilization is within expected ranges | Risk |
| 6 | No unusual compliance alerts | Compliance |
| 7 | Algo execution is performing as expected | Trading |
| 8 | Settlement status for T+0 settlements | Operations |

**Mid-Day Check** (around noon or mid-session):

| # | Check | Owner |
|---|---|---|
| 1 | System resource utilization (trending, not just snapshot) | IT |
| 2 | Trade count vs. historical average (detect anomalies) | Operations |
| 3 | Break count and aging (any new breaks, any aged breaks not progressing) | Operations |
| 4 | Margin call status (any outstanding calls) | Operations |
| 5 | Counterparty settlement status (any expected fails) | Operations |
| 6 | Corporate actions pending for today (any actions not yet processed) | Operations |

**Pre-Close Check** (30-60 minutes before market close):

| # | Check | Owner |
|---|---|---|
| 1 | Open algo orders scheduled to complete by close | Trading |
| 2 | GTC order review (any orders that should be cancelled) | Trading |
| 3 | Allocation instructions received for today's block trades | Operations |
| 4 | Batch processing prerequisites met | IT |
| 5 | EOD pricing sources ready | Operations |
| 6 | Regulatory reporting data complete for the day | Compliance |

**Post-Close Check** (after market close):

| # | Check | Owner |
|---|---|---|
| 1 | All orders cancelled or filled (no unexpected open orders) | Operations |
| 2 | All fills received and matched | Operations |
| 3 | Preliminary P&L calculated and reviewed | Operations/Trading |
| 4 | Allocations completed | Operations |
| 5 | Batch processing initiated | IT |
| 6 | After-hours system maintenance window communicated | IT |

### 11.2 Operational Dashboards

Operational dashboards provide real-time visibility into the health and performance of the trading operation.

**Dashboard 1: System Health**

Displays the real-time status of all platform components:
```
+------------------------------------------------------------------+
| SYSTEM HEALTH DASHBOARD                        2026-04-02 10:35  |
+------------------------------------------------------------------+
| Component            | Status | Latency | Throughput | Errors    |
|---------------------|--------|---------|------------|-----------|
| Order Management     | GREEN  | 2ms     | 450/sec    | 0         |
| Execution Mgmt       | GREEN  | 1ms     | 320/sec    | 0         |
| Risk Engine          | GREEN  | 5ms     | 200/sec    | 0         |
| Position Server      | GREEN  | 3ms     | 150/sec    | 0         |
| Market Data (Eqs)    | GREEN  | <1ms    | 50K/sec    | 0         |
| Market Data (FI)     | AMBER  | 12ms    | 5K/sec     | 3         |
| FIX: NYSE            | GREEN  | Connected| -         | 0         |
| FIX: NASDAQ          | GREEN  | Connected| -         | 0         |
| FIX: CME             | GREEN  | Connected| -         | 0         |
| FIX: Broker A        | GREEN  | Connected| -         | 0         |
| FIX: Broker B        | RED    | Disconn  | -         | ALERT     |
| Database Primary     | GREEN  | 1ms     | -          | 0         |
| Database Replica     | GREEN  | 1ms     | Lag: 0.2s  | 0         |
| DR Replication       | GREEN  | -       | Lag: 0.5s  | 0         |
+------------------------------------------------------------------+
| Alerts: FIX Broker B disconnected at 10:33:12 - auto-reconnect  |
|         Market Data FI latency elevated - investigating          |
+------------------------------------------------------------------+
```

**Dashboard 2: Trading Activity**

Displays real-time trading metrics:
```
+------------------------------------------------------------------+
| TRADING ACTIVITY                               2026-04-02 10:35  |
+------------------------------------------------------------------+
| Metric                          | Today    | Avg (20d) | Delta   |
|---------------------------------|----------|-----------|---------|
| Orders Submitted                | 12,450   | 14,200    | -12%    |
| Orders Filled                   | 8,230    | 9,800     | -16%    |
| Orders Rejected                 | 45       | 30        | +50%    |
| Fill Rate                       | 66.1%    | 69.0%     | -2.9%   |
| Notional Traded (USD equiv)     | $2.4B    | $3.1B     | -23%    |
| Avg Order-to-Fill Latency       | 45ms     | 42ms      | +7%     |
| Algo Orders Active              | 34       | 28        | +21%    |
| Manual Trades Entered           | 7        | 5         | +40%    |
+------------------------------------------------------------------+
| By Desk:                                                         |
|   US Equities:  5,200 orders | $1.1B notional | P&L: +$450K     |
|   US Rates:     2,100 orders | $800M notional | P&L: -$120K     |
|   FX:           3,400 orders | $350M notional | P&L: +$85K      |
|   Credit:       1,750 orders | $150M notional | P&L: +$210K     |
+------------------------------------------------------------------+
```

**Dashboard 3: Risk Overview**

Displays real-time risk metrics:
```
+------------------------------------------------------------------+
| RISK OVERVIEW                                  2026-04-02 10:35  |
+------------------------------------------------------------------+
| Desk         | VaR Util | P&L Today | Loss Limit | Greeks       |
|--------------|----------|-----------|------------|--------------|
| US Equities  | 72%      | +$450K    | 35% used   | Delta: 2.1M  |
| US Rates     | 85%      | -$120K    | 55% used   | DV01: $45K   |
| FX           | 45%      | +$85K     | 12% used   | -            |
| Credit       | 61%      | +$210K    | 22% used   | CS01: $15K   |
| TOTAL FIRM   | 68%      | +$625K    | 28% used   | -            |
+------------------------------------------------------------------+
| Alerts:                                                          |
|   US Rates VaR at 85% - approaching limit                       |
|   Trader JSmith: intraday loss at 55% of limit                  |
+------------------------------------------------------------------+
```

**Dashboard 4: Operations and Settlement**

Displays operational status:
```
+------------------------------------------------------------------+
| OPERATIONS DASHBOARD                           2026-04-02 10:35  |
+------------------------------------------------------------------+
| Settlement Status (T+0):                                         |
|   Pending: 234 trades ($450M)                                    |
|   Settled: 189 trades ($320M)                                    |
|   Failed:  12 trades ($28M) [see details]                        |
|                                                                  |
| Trade Matching:                                                  |
|   Matched: 1,245 (94.2%)                                        |
|   Alleged: 52 (3.9%)                                             |
|   Disputed: 8 (0.6%)                                             |
|   Unmatched: 17 (1.3%)                                           |
|                                                                  |
| Breaks:                                                          |
|   New today: 14                                                  |
|   Outstanding (1-3 days): 23                                     |
|   Outstanding (>3 days): 8 [ESCALATED]                           |
|   Resolved today: 19                                             |
|                                                                  |
| Allocations:                                                     |
|   Pending: 5 block trades (awaiting PM instructions)             |
|   Completed: 42 block trades                                     |
|   Late: 2 block trades [ALERT - approaching custodian cutoff]    |
|                                                                  |
| Margin:                                                          |
|   Calls issued: 3 ($12M total)                                   |
|   Calls received: 2 ($8M total)                                  |
|   Calls outstanding: 1 ($4M - counterparty DEF, due by 14:00)   |
+------------------------------------------------------------------+
```

**Dashboard 5: Compliance Monitoring**

Displays compliance and surveillance status:
```
+------------------------------------------------------------------+
| COMPLIANCE DASHBOARD                           2026-04-02 10:35  |
+------------------------------------------------------------------+
| Pre-Trade Checks Today:                                          |
|   Total evaluated: 12,450                                        |
|   Passed: 12,380 (99.4%)                                        |
|   Soft blocks (overridden): 25 (0.2%)                            |
|   Hard blocks: 45 (0.4%)                                         |
|     Restricted list: 3                                           |
|     Position limit: 12                                           |
|     Mandate breach: 8                                             |
|     Risk limit: 22                                               |
|                                                                  |
| Surveillance Alerts:                                             |
|   New alerts today: 7                                            |
|   Under investigation: 15                                        |
|   Closed today: 4                                                |
|   Alert types: Spoofing(2), Layering(1), Front-running(1),      |
|                Wash trade(1), Unusual volume(2)                   |
|                                                                  |
| Restricted List:                                                 |
|   Active restrictions: 34 instruments                            |
|   Added today: 1 (XYZ Corp - pending M&A announcement)          |
|   Removed today: 0                                               |
|                                                                  |
| Regulatory Reporting:                                            |
|   T-1 EMIR reports: Submitted (1,234 trades)                    |
|   T-1 MiFIR reports: Submitted (892 trades)                     |
|   Rejections from regulator: 3 [investigating]                   |
+------------------------------------------------------------------+
```

### 11.3 Alert Management

Alerts generated by dashboards and monitoring systems must be managed systematically to prevent alert fatigue and ensure critical issues are addressed.

**Alert severity levels**:
| Level | Description | Response | Example |
|---|---|---|---|
| **Critical** | Trading is impacted or at imminent risk | Immediate response, all-hands | Exchange connectivity lost, risk engine down |
| **High** | Significant operational issue | Response within 15 minutes | Settlement fails exceeding threshold, VaR limit breach |
| **Medium** | Issue requiring attention | Response within 1 hour | Unmatched trade approaching settlement, elevated rejection rate |
| **Low** | Informational or minor issue | Response within 4 hours | New break detected, minor data quality issue |

**Alert lifecycle**:
```
Generated -> Acknowledged -> Assigned -> Under Investigation -> Resolved -> Closed
```

**Alert routing rules**:
- System health alerts route to IT on-call
- Risk alerts route to the risk manager and desk head
- Compliance alerts route to the compliance officer
- Settlement alerts route to operations
- Multiple unresolved alerts of the same type trigger escalation to management

**Alert suppression**: To prevent alert fatigue, the system should support:
- Grouping related alerts (e.g., 50 settlement failures for the same counterparty become one alert)
- Suppressing known issues (e.g., if a FIX session is down for planned maintenance, suppress the connectivity alert)
- Escalating alerts that have been acknowledged but not resolved within the SLA
- Daily alert summary reports showing alert counts by type, severity, and resolution time
