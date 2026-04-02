## Data Feeds and Vendors

### Bloomberg

| Product | Description | Transport |
|---------|-------------|-----------|
| **Bloomberg Terminal** | Desktop platform; real-time data, news, analytics, messaging | Proprietary |
| **B-PIPE** | Server-side real-time tick data feed | BLPAPI over TCP |
| **Bloomberg Data License (BSDL)** | Bulk reference and pricing data delivery | SFTP, API |
| **Bloomberg SAPI** | Server API for programmatic access without terminal | BLPAPI |
| **Bloomberg PER** | Per-security pricing service | Flat file / API |
| **Bloomberg Enterprise Access Point** | Cloud connectivity for data delivery | API |

**Data coverage**: Equities, fixed income, derivatives, FX, commodities, indices, funds, economic data, ESG, alternative data. Over 35 million instruments.

### Refinitiv / LSEG Data & Analytics

| Product | Description |
|---------|-------------|
| **Workspace** | Desktop platform (successor to Eikon) |
| **LSEG Real-Time (Elektron)** | Enterprise real-time data distribution |
| **Datascope** | Reference data and end-of-day pricing |
| **Tick History** | Historical tick data archive (petabytes; back to 1996 for major markets) |
| **World-Check** | KYC/AML screening data |
| **Refinitiv Data Platform (RDP)** | Cloud-native data APIs |
| **Real-Time Optimized (RTO)** | Cloud-delivered real-time data |

### ICE Data Services

| Product | Description |
|---------|-------------|
| **ICE Consolidated Feed** | Multi-asset real-time data |
| **ICE Pricing and Analytics** | Fixed-income evaluated pricing |
| **ICE Reference Data** | Security master, corporate actions |
| **ICE Connect** | Desktop and API access |
| **NYSE market data** | Via ICE as NYSE parent |

### FactSet

| Product | Description |
|---------|-------------|
| **FactSet Workstation** | Desktop research and analytics |
| **FactSet SDK / Open:FactSet** | APIs for data integration |
| **FactSet Real-Time** | Tick-level market data |
| **FactSet Concordance** | Entity matching and resolution |
| **FactSet ESG** | ESG scores and data |

### S&P Global / Capital IQ

| Product | Description |
|---------|-------------|
| **S&P Capital IQ Pro** | Desktop and API for fundamentals, estimates, M&A |
| **Xpressfeed** | Bulk data feeds for quantitative research |
| **Market Intelligence** | Company data, filings, transcripts |
| **Ratings data** | Credit ratings and research |

### Specialized Data Providers

| Provider | Specialty |
|----------|-----------|
| **MSCI** | Indices, ESG ratings, factor models, risk analytics |
| **FTSE Russell** | Indices, benchmarks, analytics |
| **Markit (S&P)** | CDS pricing, loan data, securities finance |
| **Morningstar** | Fund data, research, sustainability ratings |
| **SIX Financial Information** | Reference data, corporate actions (strong in European markets) |
| **DTCC** | Trade repository data, reference data (AVOX) |
| **Broadridge** | Proxy data, corporate actions |

### Data Quality and Management

Professional trading platforms must handle:

- **Symbology mapping**: ISIN, CUSIP, SEDOL, FIGI, Bloomberg Ticker, RIC (Refinitiv), exchange-specific codes. Mapping between symbology systems is non-trivial.
- **Corporate actions**: Splits, dividends, mergers, spin-offs require retroactive adjustment of historical data and real-time position updates.
- **Reference data mastering**: Golden source management across multiple vendors; conflict resolution.
- **Entitlement management**: Vendor licensing requires tracking which users and applications can access which data.
- **Data validation**: Stale tick detection, outlier detection, cross-source validation.
