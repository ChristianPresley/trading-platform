## Start-of-Day Procedures

The start-of-day (SOD) process is the critical transition from overnight batch processing to live trading readiness. A failed or incomplete SOD can delay the desk's ability to trade and expose the firm to risk from stale data.

### 1.1 SOD Position Loading

Positions are the foundation of trading operations. Every desk must begin the day with an accurate view of what it holds.

**Position loading sequence**:

1. **Extract closing positions from the books of record**: The overnight batch (see Section 6) produces end-of-day positions for T-1. These are the authoritative positions that include all settlements, corporate actions, and reconciliation adjustments from the previous day.

2. **Apply overnight events**: Between market close and the next morning, several events may affect positions:
   - **Settlements**: Trades settling on T (today) cause actual delivery/receipt of securities and cash
   - **Corporate actions**: Ex-date processing (dividends, splits, mergers) may alter positions
   - **Margin calls**: Collateral movements processed overnight
   - **Transfers**: Internal book-to-book or entity-to-entity transfers executed overnight

3. **Load into the real-time position server**: The calculated SOD positions are loaded into the in-memory position engine that traders will interact with during the day. This engine applies real-time trade and fill events on top of the SOD base.

4. **Validate SOD positions against external sources**:
   - **Custodian positions**: Compare against custodian/depository statements received overnight
   - **Prime broker positions**: For hedge funds, compare against PB statements
   - **Exchange positions**: For listed derivatives, compare against clearing house margin statements
   - **Fund administrator positions**: For asset managers, compare against fund admin NAV packs

5. **Flag and investigate discrepancies**: Any difference between the internal SOD position and external statements must be flagged as a break and investigated before trading begins (see Section 4 on Break Management).

**Position loading timeline** (typical US equities desk):
| Time (ET) | Activity |
|---|---|
| 04:00 | Overnight batch completes, T-1 EOD positions finalized |
| 04:30 | SOD position files generated and validated |
| 05:00 | Positions loaded into real-time engine |
| 05:30 | External position files received (custodian, PB) |
| 06:00 | Automated reconciliation runs, breaks flagged |
| 06:30 | Operations reviews breaks, escalates material items |
| 07:00 | Desk head confirms trading readiness |
| 07:30 | Pre-market trading begins (if applicable) |
| 09:30 | Regular market open |

**Failure mode**: If SOD positions cannot be loaded (e.g., batch failure, data corruption), the desk must either trade on estimated/stale positions (with heightened risk controls) or delay trading until the issue is resolved. This decision involves the desk head, risk management, and operations, and must be documented.

### 1.2 System Health Checks

Before the trading day begins, automated and manual checks verify that all platform components are operational.

**Automated health check suite**:

| Component | Check | Pass Criteria | Impact if Failed |
|---|---|---|---|
| Order Management System | Heartbeat, order submission test | Response < 50ms | Cannot trade |
| Execution Management System | Connectivity to all venues | All configured venues connected | Reduced venue access |
| FIX Connectivity | Session status per counterparty | All sessions logged on | Cannot route to specific venues |
| Market Data Feed | Tick count, last update time | Ticks received within last 5 seconds | Stale pricing, cannot trade |
| Risk Engine | Limit loading, calculation test | All limits loaded, test calc correct | Cannot enforce risk limits |
| Position Server | SOD positions loaded, count validation | Position count matches expected | Incorrect P&L, risk exposure |
| Database | Connection pool, query performance | Connections available, queries < 100ms | Degraded performance |
| Network | Latency to exchanges, internal latency | Within normal bounds | Execution quality degradation |
| Disaster Recovery | DR site replication lag | Lag < 30 seconds | Increased recovery time |
| Reference Data | Instrument master load | All expected instruments present | Cannot trade missing instruments |

**Health check dashboard**: The SOD health check results are displayed on an operational dashboard with red/amber/green status. All red items must be resolved before trading begins. Amber items can proceed with documented risk acceptance.

**Sign-off process**: The operations manager or a designated SOD controller must formally sign off that the system is ready for trading. This sign-off is logged and timestamped.

### 1.3 Market Data Validation

Stale or incorrect market data is one of the most dangerous failure modes in a trading system because it can cause orders to be priced incorrectly.

**Market data validation checks**:

1. **Staleness check**: Verify that market data feeds are delivering fresh ticks. Compare the last tick timestamp against the current time. A feed that has not updated in more than N seconds (configurable per asset class) is flagged as stale.

2. **Cross-source validation**: Compare prices from multiple data sources (e.g., Bloomberg, Refinitiv, direct exchange feeds). Divergences beyond a configurable threshold trigger an alert.

3. **Reasonability check**: Compare current prices against previous close. Moves exceeding a configurable threshold (e.g., >10% for equities, >50bps for sovereign bonds) are flagged for review. This catches data errors (e.g., a decimal point shift) and also surfaces legitimate overnight moves that may require attention.

4. **Corporate action adjustment**: Verify that prices reflect corporate actions (e.g., a stock that split 2:1 overnight should show approximately half the previous close).

5. **Holiday calendar validation**: Confirm that market data feeds for closed markets are correctly showing as inactive rather than stale. A feed showing zero ticks for the Tokyo exchange on a Japanese holiday is correct, not an error.

6. **Derived data validation**: Verify that calculated values (implied volatility, yield, spread) are consistent with their inputs. A bond showing a negative yield when the price and coupon imply a positive yield indicates a calculation error.

### 1.4 Risk Limit Loading

Risk limits must be loaded and active before any trading is permitted.

**Risk limit loading process**:

1. **Load limit definitions**: Read the current limit configuration from the limit management database. This includes all desk-level, trader-level, and book-level limits.
2. **Apply overnight changes**: Any limit changes approved overnight (e.g., a temporary limit increase approved the previous evening) are applied.
3. **Expire temporary limits**: Temporary limit increases that have passed their expiry time are reverted to the base limit.
4. **Validate limit hierarchy**: Ensure that sub-limits (e.g., per-trader limits) do not exceed parent limits (e.g., desk limits). Flag configuration errors.
5. **Load current utilization**: Calculate current limit utilization based on SOD positions. A desk starting the day at 90% of its VaR limit needs to know this immediately.
6. **Activate pre-trade risk checks**: Enable the real-time pre-trade risk check engine that evaluates every incoming order against applicable limits.

**Limit loading failure mode**: If limits cannot be loaded, no trading is permitted. This is a hard requirement. Trading without risk limits is equivalent to trading with unlimited risk.

### 1.5 Price Validation and Reference Data

Reference data (instrument master, counterparty master, settlement instructions) must be loaded and validated before trading.

**Reference data checks**:
- **Instrument count**: Compare the number of loaded instruments against the expected count. A significant shortfall (e.g., >1% missing) indicates a data load failure.
- **New instruments**: Verify that any newly listed instruments (IPOs, new bond issues, new derivatives series) are present and correctly configured.
- **Expired instruments**: Verify that expired instruments (matured bonds, expired options, delisted stocks) are correctly marked as inactive.
- **Static data quality**: Spot-check key attributes (tick size, lot size, currency, exchange, settlement cycle) against a reference source.
- **Pricing reference data**: Verify that closing prices, settlement prices, and reference rates (SOFR, EURIBOR, etc.) are loaded correctly.
- **Calendar data**: Verify that holiday calendars and trading schedules are current for all markets the desk trades.
