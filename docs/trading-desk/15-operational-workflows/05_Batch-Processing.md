## Batch Processing

### 6.1 Overnight Batch Runs

The overnight batch is the backbone of the daily operational cycle. It processes the day's activity into the official books and records and prepares the system for the next trading day.

**Batch sequence** (typical order):

```
Phase 1: Close of Business (COB) Processing
  1.1  Trade snapshot - Lock the day's trade population
  1.2  Price snapshot - Lock closing/settlement prices
  1.3  FX rate snapshot - Lock closing FX rates
  1.4  Position calculation - Calculate official EOD positions
  1.5  P&L calculation - Calculate official EOD P&L
  1.6  Risk calculation - Run overnight risk calculations (full VaR, stress tests)

Phase 2: Settlement Processing
  2.1  Settlement instruction generation - Generate settlement messages (SWIFT MT5xx)
  2.2  Netting - Net settlement obligations by counterparty, currency, and CSD
  2.3  Settlement file generation - Create files for custodian/CSD
  2.4  Cash projection - Calculate expected cash movements for the next N days
  2.5  Margin calculation - Calculate margin requirements for cleared positions

Phase 3: Corporate Actions Processing
  3.1  Ex-date processing - Apply corporate actions going ex on T+1
  3.2  Record date processing - Determine entitlements based on positions at record date
  3.3  Payment processing - Book dividend/coupon payments for pay date = T+1
  3.4  Mandatory event processing - Apply splits, mergers, consolidations

Phase 4: Regulatory and Client Reporting
  4.1  Transaction reporting - Generate EMIR, MiFIR, Dodd-Frank transaction reports
  4.2  Position reporting - Generate regulatory position reports (CFTC large trader, SEC 13F)
  4.3  Client reporting - Generate client statements and portfolio reports
  4.4  Internal management reporting - Generate management dashboards and KPIs

Phase 5: System Preparation for Next Day
  5.1  Roll forward dates - Advance the system date to T+1
  5.2  Reference data updates - Load updated instrument master, calendar data
  5.3  Market data preparation - Prime the market data cache for the next trading day
  5.4  Pre-generate SOD files - Prepare position and limit files for the SOD load
  5.5  Archive and purge - Archive intraday data, purge temporary files
```

**Batch monitoring**: Each batch phase has a scheduled start time and an expected completion time. Batch monitoring tools track progress, alert on delays, and provide estimated completion times based on historical run times.

**Batch failure recovery**: If a batch step fails, the system must support:
- **Retry**: Re-run the failed step from the beginning
- **Skip and continue**: Proceed with subsequent steps (if independent) and return to the failed step later
- **Rollback**: Undo the partially-completed step and restore to the pre-step state
- **Manual override**: Allow an operator to manually complete the step and mark it as done

### 6.2 Settlement Processing

Settlement processing converts traded obligations into actual securities and cash movements.

**Settlement lifecycle**:
```
Trade Execution -> Trade Matching -> Settlement Instruction Generation -> Pre-settlement Matching -> Settlement -> Confirmation
```

**Settlement instruction generation**:
1. For each trade settling on T+N, generate settlement instructions
2. Apply netting rules (net buy/sell obligations with the same counterparty, same instrument, same settlement date)
3. Validate settlement instructions against the SSI database
4. Format instructions per the custodian/CSD requirements (SWIFT MT541/MT543 for deliveries, MT542/MT544 for receipts)
5. Submit instructions to the custodian/CSD before their cut-off time

**Settlement cycles by market**:
| Market | Standard Cycle | Notes |
|---|---|---|
| US Equities | T+1 | Changed from T+2 in May 2024 |
| European Equities | T+2 | |
| UK Equities | T+1 | Changed from T+2 in October 2027 (planned) |
| US Treasuries | T+1 | |
| Corporate Bonds | T+2 | Varies by market |
| FX Spot | T+2 (T+1 for CAD, TRY, RUB) | |
| Listed Derivatives | Varies | Daily margining, no final settlement until expiry |
| OTC Derivatives | Varies | Initial margin and variation margin |

### 6.3 Corporate Actions Processing

Corporate actions (CAs) are events initiated by the issuer of a security that affect the holders of that security. They are one of the most complex and error-prone areas of operations.

**Corporate action types**:

| Type | Category | Complexity | Example |
|---|---|---|---|
| Cash dividend | Mandatory | Low | AAPL pays $0.24/share |
| Stock split | Mandatory | Medium | NVDA 10:1 split |
| Merger (cash) | Mandatory | High | Target delisted, cash per share |
| Merger (stock) | Mandatory | High | Target shares converted to acquirer shares |
| Rights issue | Voluntary | High | Holder can subscribe for new shares at discount |
| Tender offer | Voluntary | High | Offer to buy shares at a premium |
| Bond coupon | Mandatory | Low | Semi-annual coupon payment |
| Bond call | Mandatory/Voluntary | Medium | Issuer redeems bond before maturity |
| Spin-off | Mandatory | High | New entity shares distributed to holders |

**Corporate actions processing workflow**:
1. **Notification**: Receive CA notification from data vendors (Bloomberg, DTCC, S&P) or custodian
2. **Scrubbing**: Validate CA details against multiple sources (vendor A vs. vendor B vs. issuer announcement)
3. **Setup**: Configure the CA event in the system (dates, rates, options, election deadlines)
4. **Entitlement calculation**: Determine which positions are entitled based on record date holdings
5. **Election** (for voluntary events): Collect elections from portfolio managers by the deadline
6. **Instruction**: Submit elections/instructions to the custodian by their deadline
7. **Processing**: On the effective date, apply the CA to positions:
   - Adjust quantities (for splits, mergers, spin-offs)
   - Book cash payments (for dividends, coupons, cash mergers)
   - Create new positions (for spin-offs, rights)
   - Close positions (for full redemptions, cash mergers)
8. **Reconciliation**: Verify that the CA was applied correctly by comparing positions and cash before/after
9. **Claims management**: If the firm is entitled to CA proceeds but did not receive them (e.g., because securities were on loan), initiate a claim against the borrower

### 6.4 Data Loads

The trading platform depends on reference data feeds that are loaded in batch.

**Key data feeds**:
| Feed | Source | Frequency | Content |
|---|---|---|---|
| Instrument master | Bloomberg, Refinitiv, exchange | Daily | New listings, delistings, attribute changes |
| Corporate actions | Bloomberg, DTCC, custodian | Daily + intraday | Upcoming and processed corporate actions |
| Closing prices | Exchange, Bloomberg BVAL | Daily | Official settlement/closing prices |
| FX rates | WM/Reuters, Bloomberg | Daily (4pm London fix) | Official closing FX rates for valuation |
| Reference rates | Administrators (SOFR, EURIBOR) | Daily | Benchmark interest rates |
| Counterparty master | Internal, LEI lookup | As needed | New counterparties, KYC updates, credit ratings |
| Holiday calendars | Bloomberg, exchange | Quarterly | Market holidays and trading schedules |
| Regulatory data | Regulators, industry bodies | As needed | Regulation changes, reporting requirement updates |

**Data load validation**: Every data load must be validated:
- Row count vs. expected count
- Checksums on critical fields
- Referential integrity (no orphaned foreign keys)
- Business rule validation (no negative prices, no future dates for historical data)
- Comparison against previous load (flag anomalous changes)
