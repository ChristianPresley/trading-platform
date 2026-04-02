## Drop Copy and Trade Reporting

### Drop Copy

A **drop copy** is a real-time, read-only copy of all execution reports for a firm (or a set of accounts) sent by an exchange or broker to a designated FIX session. It serves as an independent record of trade activity, separate from the trading session.

**Purpose**:

- **Risk management**: Middle-office systems consume drop copy to calculate real-time positions and P&L independent of the trading system
- **Compliance**: Surveillance systems monitor all executions for suspicious patterns
- **Reconciliation**: Verify that the trading system's internal state matches the exchange/broker record
- **Disaster recovery**: If the trading system loses state, the drop copy provides a recovery source

**Implementation**:

- Dedicated FIX session (separate SenderCompID/TargetCompID from trading sessions)
- Receives `ExecutionReport` (MsgType=8) messages for all fills, cancels, and rejects
- Typically uses `TradeCaptureReport` (MsgType=AE) at some venues
- Exchanges provide drop copy as a standard service: CME iLink Drop Copy, NYSE Pillar Drop, Nasdaq OUCH Drop

### Trade Reporting

#### Regulatory Trade Reporting

- **TRACE** (FINRA): Fixed-income trade reporting for US corporate bonds, agency debt
- **ORF** (FINRA): OTC equity trade reporting
- **APA** (Approved Publication Arrangement): MiFID II post-trade transparency in Europe (e.g., Tradeweb APA, Bloomberg APA)
- **ARM** (Approved Reporting Mechanism): MiFID II transaction reporting to regulators (e.g., LSEG ARM, Kaizen ARM)
- **CAT** (Consolidated Audit Trail): US equities and options lifecycle reporting to FINRA

#### Protocols and Formats

- **FpML** (Financial products Markup Language): XML standard for OTC derivatives trade reporting
- **FIX TradeCaptureReport**: Standard FIX message for trade lifecycle events
- **ISO 20022**: Increasingly used for trade confirmation and settlement reporting
- **DTCC CTM/Omgeo**: Central trade matching and confirmation for institutional trades
