## Break Management

### 4.1 Types of Breaks

A "break" is any discrepancy between two records that should agree. Breaks are the primary indicator of operational problems and are a key focus for middle and back office teams.

**Position breaks**:
- **Internal position break**: Front-office position does not match back-office position. Typically caused by a trade booked in one system but not the other, or booked with different terms.
- **External position break**: Internal position does not match custodian/clearing house/counterparty statement. Caused by missed settlements, incorrect corporate action processing, or booking errors.
- **Cash position break**: Cash ledger does not match bank statement. Caused by missed cash movements, incorrect fee calculations, or unbooked cash events.

**Trade breaks**:
- **Unmatched trade**: Trade exists internally but the counterparty has not confirmed it (alleged trade)
- **Disputed trade**: Both sides have confirmed but terms differ (price, quantity, settlement date, instrument)
- **Missing trade**: Counterparty has confirmed a trade that does not exist internally
- **Duplicate trade**: Same trade appears to have been booked twice

**Cash breaks**:
- **Settlement cash break**: Expected settlement amount does not match actual cash movement
- **Income break**: Expected coupon/dividend payment does not match actual receipt
- **Fee break**: Expected fee deduction does not match actual deduction
- **FX settlement break**: Expected currency amount does not match after FX conversion

### 4.2 Break Investigation Workflow

**Break lifecycle**:
```
Detected -> Assigned -> Under Investigation -> Root Cause Identified -> Resolution Proposed -> Resolved -> Closed
```

**Investigation process**:

1. **Detection**: The reconciliation engine flags a discrepancy that exceeds the tolerance threshold
2. **Categorization**: The break is automatically categorized by:
   - Type (position, trade, cash)
   - Materiality (based on dollar amount and percentage of position)
   - Age (new, 1 day, 2-5 days, >5 days)
   - Asset class and desk
3. **Assignment**: The break is assigned to an investigator based on desk ownership, asset class expertise, and workload balancing
4. **Investigation**: The investigator:
   - Reviews all relevant trade records, position snapshots, and external statements
   - Contacts the counterparty if needed (via Operations contacts, not traders)
   - Identifies the root cause from common causes: booking error, missed settlement, corporate action discrepancy, timing difference, data feed issue
5. **Resolution**: Based on the root cause, the investigator proposes a resolution:
   - **Amend**: Correct the trade details (price, quantity, date, account)
   - **Cancel/rebook**: Cancel the incorrect trade and enter the correct one
   - **Book missing trade**: Enter a trade that was missing from the system
   - **Adjust position**: Post a manual adjustment with full documentation
   - **Write-off**: For immaterial amounts that cannot be resolved, post a write-off (requires approval)
6. **Approval**: Material resolutions (above a threshold) require approval from a supervisor or operations manager
7. **Closure**: The break is marked as resolved, with full documentation of the root cause and resolution

### 4.3 Break Resolution SLAs

| Break Type | Materiality | Resolution SLA |
|---|---|---|
| Position break | > $1M | Same day |
| Position break | $100K - $1M | T+1 |
| Position break | < $100K | T+2 |
| Trade break (unmatched) | Any | T+1 (before settlement date) |
| Cash break | > $100K | Same day |
| Cash break | < $100K | T+2 |
| Aged break (> 5 days) | Any | Escalation to management |
| Aged break (> 30 days) | Any | Mandatory write-off review |

### 4.4 Break Aging and Escalation

Break aging is a critical metric. Old breaks indicate systemic problems and carry increasing risk.

**Aging escalation ladder**:
| Age | Action |
|---|---|
| T+1 | Break appears on daily break report, assigned to investigator |
| T+3 | Automatic escalation to operations manager |
| T+5 | Automatic escalation to desk head and risk manager |
| T+10 | Automatic escalation to COO / Head of Operations |
| T+30 | Mandatory management review, potential write-off |
| T+60 | Regulatory concern (some regulators require breaks to be resolved within defined timeframes) |

---

## Exception Handling

### 5.1 Failed Trades

A failed trade is one that did not settle on the intended settlement date. Settlement failure is a significant operational and regulatory event.

**Common causes of settlement failure**:
- **Insufficient securities**: Seller does not have the securities in the correct account at the custodian
- **Insufficient funds**: Buyer does not have the cash to pay for the securities
- **SSI mismatch**: Settlement instructions are incorrect or not set up at the custodian
- **Documentation gap**: Required documentation (e.g., legal agreement for an OTC derivative) is not in place
- **Counterparty failure**: The counterparty's operational infrastructure failed
- **CSD/ICSD issues**: The central securities depository experienced an outage or processing error
- **Regulatory restriction**: A regulatory hold or sanction prevents settlement

**Failed trade workflow**:

1. **Detection**: The settlement system reports that settlement did not occur on the expected date. This may come from the custodian, clearing house, or the CSD.
2. **Notification**: Operations is alerted immediately. The desk is notified if the failure may have trading implications (e.g., a short position that was supposed to be covered).
3. **Root cause investigation**: Operations determines why the trade failed and what is needed to resolve it.
4. **Resolution actions**:
   - Resubmit with corrected SSIs
   - Arrange securities borrowing if short of inventory
   - Contact counterparty operations to resolve on their side
   - Escalate to custodian or CSD if the issue is on their end
5. **Partial settlement**: Some CSDs support partial settlement (delivering a portion of the position while the remainder is pending). Operations decides whether to accept partial settlement.
6. **Penalty tracking**: Under CSDR (Central Securities Depositories Regulation) in the EU, settlement failures incur daily cash penalties. These must be tracked, allocated to the responsible party, and reported.
7. **Buy-in procedures**: If a trade remains failed beyond a defined period, the buyer may initiate a mandatory buy-in (purchasing the securities from another source and charging the failing seller for any price difference).

**Settlement failure metrics**:
- Settlement failure rate (target: <2% by value)
- Average days to resolution
- Penalty costs incurred
- Repeat failures by counterparty (for relationship management)

### 5.2 Rejected Orders

Orders can be rejected at multiple points in the execution chain.

**Rejection points and handling**:

| Rejection Point | Common Causes | Handling |
|---|---|---|
| **Pre-trade risk check** | Limit breach, restricted instrument, invalid parameters | Immediate feedback to trader, suggest corrective action |
| **Compliance check** | Restricted list, mandate breach, position limit | Notify compliance, trader cannot override |
| **Venue validation** | Invalid instrument for venue, market closed, invalid order type | Immediate feedback, suggest alternative |
| **Exchange rejection** | Price outside daily limit, invalid lot size, self-trade prevention | Immediate feedback with exchange error code |
| **Broker rejection** | Credit limit breach, bilateral agreement issue | Notify operations, escalate to credit |
| **Clearing rejection** | Margin insufficient, position limit at clearing house | Notify operations, arrange margin |

**Rejection workflow**:
1. System captures the rejection with full context (reason code, timestamp, original order details)
2. Trader is notified immediately with a clear explanation
3. If the rejection is due to a system or configuration issue (not a legitimate business rule), IT is notified
4. Repeated rejections of the same type trigger an investigation (is there a systemic problem?)
5. All rejections are logged for compliance surveillance (patterns of rejected orders can indicate market manipulation attempts)

### 5.3 Unmatched Trades

Unmatched trades are trades that have been booked internally but not confirmed by the counterparty.

**Unmatched trade workflow**:
1. **Automatic matching**: The confirmation platform (DTCC, MarkitWire, etc.) attempts to match the trade electronically
2. **T+0 matching check**: At EOD, any unmatched trades are flagged
3. **Counterparty chase**: Operations contacts the counterparty's operations team to determine why the trade is unmatched:
   - Counterparty has not yet booked the trade (timing lag)
   - Counterparty has booked with different terms (dispute)
   - Counterparty does not recognize the trade (potential error)
4. **Escalation**: If unmatched by T+1 (or before settlement date, whichever is earlier), escalate to desk and relationship management
5. **Resolution**: Amend terms if agreed, or cancel and rebook if necessary
6. **Settlement risk**: Unmatched trades that approach their settlement date without resolution may need to be settled on a "with-risk" basis (settling without confirmation, accepting the risk of subsequent dispute)

### 5.4 Late Allocations

Late allocations occur when a block trade has been executed but the allocation to individual accounts/funds has not been completed in time.

**Late allocation impact**:
- Settlement may be delayed because the custodian does not know which account to deliver to/from
- NAV calculations may be incorrect because the trade is not assigned to the correct fund
- Regulatory reporting may be delayed or inaccurate

**Late allocation workflow**:
1. **SLA monitoring**: Block trades must be allocated within a defined time window (e.g., T+0 for same-day settlement markets, before the allocation cut-off for the custodian/prime broker)
2. **Alert**: If the allocation deadline is approaching and allocations are not complete, operations and the PM are alerted
3. **Default allocation**: Some systems support a "default allocation" that is applied automatically if no instructions are received. This uses a pre-defined allocation model (pro-rata by AUM, equal weight, etc.)
4. **Late allocation processing**: If allocations are received after the cut-off:
   - Custodian/PB may charge late allocation fees
   - Settlement may be delayed by a day
   - The block trade may settle to a suspense account and then be transferred, creating additional operational work
5. **Root cause analysis**: Persistent late allocations indicate a process problem (PM not providing timely instructions, system integration issue, timezone mismatch for global funds)
