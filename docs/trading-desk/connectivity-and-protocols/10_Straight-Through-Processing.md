## Straight Through Processing (STP)

**STP** is the end-to-end automation of trade processing from order entry through settlement without manual intervention.

### STP Workflow

```
Trade Execution
      |
      v
Trade Capture & Enrichment
  (add SSIs, fees, commissions, regulatory flags)
      |
      v
Trade Confirmation & Matching
  (DTCC CTM, Bloomberg VCON, Omgeo, MarkitWire)
      |
      v
Allocation & Booking
  (split block trades across accounts/funds)
      |
      v
Settlement Instruction Generation
  (SWIFT MT540-543, ISO 20022 sese.023)
      |
      v
Clearing
  (CCP: LCH, CME Clearing, DTCC/NSCC, OCC, Eurex Clearing)
      |
      v
Settlement
  (CSD: DTCC/DTC, Euroclear, Clearstream, CREST)
      |
      v
Position & Cash Reconciliation
```

### Key STP Components

#### Trade Confirmation and Matching

| Platform | Description |
|----------|-------------|
| **DTCC CTM** (Central Trade Matching) | Central matching for institutional equity and fixed income trades |
| **Bloomberg VCON** | Real-time trade matching on Bloomberg Terminal |
| **MarkitWire** (S&P) | OTC derivatives confirmation and matching |
| **Traiana/CME** | FX and listed derivatives matching |
| **SWIFT Accord** | Cross-border securities trade matching |

#### Settlement Standing Instructions (SSIs)

SSIs specify the custodian accounts, agent banks, and delivery instructions for each counterparty. Maintained in:

- **ALERT** (Omgeo/DTCC): Global SSI database
- **Internal SSI database**: Mapped by counterparty, asset class, currency, market
- Auto-enrichment at trade capture eliminates manual instruction entry

#### Clearing Houses (CCPs)

| CCP | Markets |
|-----|---------|
| **DTCC/NSCC** | US equities and corporate bonds |
| **OCC** | US-listed options |
| **CME Clearing** | CME Group futures and options; OTC interest rate swaps |
| **LCH (LSEG)** | Interest rate swaps (SwapClear), CDS, FX, equities |
| **Eurex Clearing** | European derivatives |
| **ICE Clear** | Energy, CDS, futures |

#### Central Securities Depositories (CSDs)

| CSD | Region |
|-----|--------|
| **DTCC/DTC** | US equities, corporate bonds |
| **Euroclear** | Pan-European; Belgian, French, Dutch, Irish, Finnish, Swedish securities |
| **Clearstream** | Pan-European; German securities; fund processing |
| **CREST (Euroclear UK)** | UK and Irish securities |
| **CDS** | Canadian securities |

### STP Rates and Targets

- **Equity**: Target STP rate > 98% for standard flow
- **Fixed Income**: Lower STP rates (85-95%) due to less standardization
- **OTC Derivatives**: Historically low STP; improving with electronic confirmation platforms
- **FX**: High STP via CLS (Continuous Linked Settlement) for PvP settlement

### Middleware for STP

| Product | Vendor | Role |
|---------|--------|------|
| **Calypso** (Adenza/Broadridge) | Front-to-back trading and risk platform |
| **Murex** | MX.3 front-to-back platform |
| **OpenFin** | Desktop interoperability (FDC3 standard) |
| **FIS/SunGard** | Various: Global Plus (custody), GMI (clearing) |
| **SS&C** | Post-trade: Advent Geneva, Eze OMS |
| **SimCorp** | Investment management platform with full STP |
| **Ion Group** | XTP (cross-asset trading platform), Fidessa |
