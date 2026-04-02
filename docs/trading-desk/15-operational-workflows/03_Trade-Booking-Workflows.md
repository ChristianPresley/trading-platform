## Trade Booking Workflows

### 3.1 Trade Capture

Trade capture is the process of recording a trade in the system. The goal is to capture every trade accurately, completely, and as close to real-time as possible.

**Capture methods**:

| Method | Description | STP Rate | Latency |
|---|---|---|---|
| **Electronic execution** | Orders filled on exchange or via electronic venues | >99% | Milliseconds |
| **Algo execution** | Fills from algorithmic execution strategies | >99% | Milliseconds |
| **RFQ platforms** | Trades executed via electronic RFQ (Tradeweb, MarketAxess, Bloomberg) | >95% | Seconds |
| **Voice broker** | Trades negotiated by phone, entered manually | 0% (manual) | Minutes to hours |
| **Block trade** | Large trades negotiated off-exchange | 50-80% | Minutes |
| **Give-up/take-up** | Trades executed by one broker, given up to another for clearing | 60-80% | Hours |
| **Allocation** | Block trades split across multiple accounts/funds | 70-90% | Minutes to hours |

**Trade capture data model** (core fields):
```
Trade
  TradeId (system-generated, immutable)
  ExternalTradeId (exchange/platform trade ID)
  TradeDate
  SettlementDate
  Instrument
    InstrumentId, ISIN, CUSIP, SEDOL, Ticker
    InstrumentType
  Side (Buy/Sell/SellShort/BuyCover)
  Quantity / Notional
  Price / Rate
  Currency
  Counterparty
  Broker / ExecutingVenue
  Account / Book
  Trader (who executed)
  OrderId (link to originating order)
  TradeStatus (new, confirmed, settled, cancelled, amended)
  CommissionAndFees
    ExchangeFee, BrokerCommission, ClearingFee, Tax
  SettlementInstructions
    DeliveryAgent, ReceivingAgent
    SWIFT/BIC codes, account numbers
  RegulatoryFields
    ReportingFlag, TransactionReportId
    LEI (Legal Entity Identifier) of both parties
    TradingCapacity (principal, agent, riskless principal)
```

### 3.2 Trade Enrichment

Enrichment is the process of automatically populating fields that the trader did not explicitly enter but are required for booking, settlement, and reporting.

**Enrichment rules**:

| Field | Enrichment Source | Rule |
|---|---|---|
| Settlement date | Market convention engine | T+2 for equities (US/EU), T+1 for US Treasuries, T+0 for FX spot (T+2 for most pairs) |
| Settlement instructions | SSI database | Look up default SSI for counterparty + instrument type + currency |
| Clearing broker | Clearing relationship table | Based on instrument type and execution venue |
| Commission | Commission schedule | Based on broker, instrument type, and trade size |
| Exchange fees | Fee schedule | Based on exchange, instrument, and trade side |
| Tax | Tax rules engine | Stamp duty, FTT, withholding tax based on jurisdiction |
| Regulatory flags | Regulatory rules engine | Determine if trade is reportable under EMIR, MiFIR, Dodd-Frank |
| LEI | Counterparty master | Look up Legal Entity Identifier |
| Account | Allocation rules | For PM-initiated trades, determine target account based on allocation model |
| Book | Booking rules | Determine which book the trade should be booked to based on desk, strategy, instrument type |

**Enrichment failure handling**: If enrichment cannot complete (e.g., no SSI found for a new counterparty, unknown instrument), the trade is placed in an exception queue for manual enrichment by operations. The trade must not be booked to a live book until enrichment is complete.

### 3.3 Trade Validation

Validation checks ensure the trade is internally consistent and passes all business rules before booking.

**Validation checks**:

1. **Mandatory field validation**: All required fields are present and non-null
2. **Reference data validation**: Instrument, counterparty, account, and book all exist in the reference data and are active
3. **Date validation**: Trade date is valid (not a holiday, not in the future for non-forward trades), settlement date is correct per market convention
4. **Price validation**: Trade price is within a configurable tolerance of the current market price (fat-finger check)
5. **Quantity validation**: Trade quantity is a valid lot size for the instrument
6. **Limit validation**: Trade does not breach position limits, notional limits, or concentration limits
7. **Compliance validation**: Trade does not involve a restricted instrument, does not breach mandate constraints
8. **Counterparty validation**: Counterparty is approved, credit limit is not breached, all required documentation (ISDA, CSA) is in place
9. **Duplicate check**: Trade is not a duplicate of an already-booked trade (based on key fields and timing)
10. **Settlement instruction validation**: SSIs are valid, correspondent banks are correct

### 3.4 Booking to Books and Accounts

Once enriched and validated, the trade is booked, meaning it becomes part of the firm's official position and P&L record.

**Booking process**:

1. **Assign to book**: The trade is assigned to the appropriate trading book based on booking rules (desk, strategy, instrument type, trader)
2. **Generate accounting entries**: The trade generates accounting entries in the general ledger:
   - Debit/credit to the position account (securities inventory)
   - Debit/credit to the cash/settlement account (payable/receivable)
   - Commission and fee accruals
3. **Update position**: The real-time position engine is updated with the new trade
4. **Update P&L**: The P&L engine recalculates for the affected book
5. **Generate confirmations**: Trade confirmations are generated and sent to the counterparty (via SWIFT, DTCC, or electronic platform)
6. **Generate regulatory reports**: If the trade is reportable, the regulatory report is generated and queued for submission
7. **Notify downstream systems**: Trade events are published to downstream consumers (risk, compliance, settlement, accounting)

**Booking status lifecycle**:
```
New -> Enriched -> Validated -> Booked -> Confirmed -> Settled
                                    \-> Amended (creates new version)
                                    \-> Cancelled (soft delete)
```
