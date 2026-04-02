## Market Data Sources and Exchanges

### Major Equity Exchanges

#### United States

| Exchange | Operator | Primary Feed | Protocol |
|----------|----------|-------------|----------|
| **NYSE** | Intercontinental Exchange (ICE) | NYSE Pillar | NYSE Pillar Gateway (binary) |
| **NYSE Arca** | ICE | NYSE Arca Integrated Feed | Pillar binary |
| **NYSE American** | ICE | NYSE American Integrated Feed | Pillar binary |
| **NASDAQ** | Nasdaq Inc. | TotalView-ITCH 5.0 | ITCH (binary, multicast UDP) |
| **NASDAQ BX** | Nasdaq Inc. | BX TotalView-ITCH | ITCH |
| **NASDAQ PSX** | Nasdaq Inc. | PSX TotalView-ITCH | ITCH |
| **Cboe BZX** | Cboe Global Markets | Cboe PITCH | PITCH (binary) |
| **Cboe BYX** | Cboe | Cboe PITCH | PITCH |
| **Cboe EDGX** | Cboe | Cboe PITCH | PITCH |
| **Cboe EDGA** | Cboe | Cboe PITCH | PITCH |
| **IEX** | IEX Group | IEX TOPS / DEEP | IEX-TP (binary, free) |
| **MEMX** | Members Exchange | MEMX Memoir | Memoir (binary) |
| **LTSE** | Long-Term Stock Exchange | LTSE data feed | LTSE proprietary |
| **MIAX Pearl Equities** | Miami International Holdings | MIAX Pearl MACH | MEI protocol |

There are currently 16 registered national securities exchanges in the US for equities, plus numerous ATSs (Alternative Trading Systems) / dark pools.

#### Europe

| Exchange | Operator | Primary Feed |
|----------|----------|-------------|
| **LSE** | London Stock Exchange Group (LSEG) | MIT (Millennium Exchange) via UDP multicast |
| **Euronext** (Paris, Amsterdam, Brussels, Lisbon, Dublin, Oslo, Milan) | Euronext N.V. | Optiq MDG (Market Data Gateway) |
| **Eurex** | Deutsche Boerse | EOBI (Enhanced Order Book Interface), EMDI |
| **Xetra** | Deutsche Boerse | T7 EMDI/EOBI |
| **SIX Swiss Exchange** | SIX Group | FIX/FAST, proprietary binary |
| **Nasdaq Nordic/Baltic** | Nasdaq | ITCH |
| **Cboe Europe** | Cboe | Cboe Europe PITCH |
| **Aquis Exchange** | Aquis Exchange PLC | ITCH |
| **Turquoise** | LSEG | MIT-based |

#### Asia-Pacific

| Exchange | Operator | Primary Feed |
|----------|----------|-------------|
| **TSE** (Tokyo) | Japan Exchange Group | arrowhead (FLEX Full/Standard) |
| **HKEX** | Hong Kong Exchanges | OMD (Orion Market Data) |
| **SGX** | Singapore Exchange | ITCH (Titan OMS) |
| **ASX** | ASX Ltd | ASX ITCH |
| **SSE** (Shanghai) | SSE | FAST/Binary |
| **SZSE** (Shenzhen) | SZSE | Binary |
| **BSE/NSE** (India) | BSE Ltd / NSE | Proprietary binary, multicast |
| **KRX** (Korea) | Korea Exchange | KOSCOM feed |

### Derivatives Exchanges

| Exchange | Asset Classes | Primary Feed |
|----------|--------------|-------------|
| **CME Group** (CME, CBOT, NYMEX, COMEX) | Futures, options on futures (rates, equity index, FX, energy, metals, agriculture) | MDP 3.0 (Market Data Platform), SBE encoding, multicast UDP |
| **ICE** (ICE Futures US, ICE Futures Europe, ICE Futures Canada) | Energy, soft commodities, rates, equity index | iMpact multicast |
| **Cboe Options** (C1, C2, BZX Options, EDGX Options) | Equity options | Cboe PITCH |
| **NASDAQ Options** (PHLX, ISE, GEMX, MRX, BX Options, NASDAQ Options) | Equity options | ITCH |
| **NYSE Options** (NYSE Arca Options, NYSE American Options) | Equity options | Pillar |
| **MIAX Options** (MIAX, PEARL, EMERALD) | Equity options | MEI / MACH |
| **Eurex** | European derivatives (EURO STOXX, DAX, rates) | EOBI, EMDI |
| **LME** | Base metals | LMEselect (proprietary) |

### Consolidated Feeds vs Direct Feeds

#### Consolidated Feeds (US Equities)

In the US, the consolidated tape is mandated by Regulation NMS and operated by the Securities Information Processors (SIPs):

- **CTA (Consolidated Tape Association)**: Covers NYSE-listed (Tape A) and NYSE Arca / regional-listed (Tape B) securities. Operated by the NYSE on behalf of the CTA Plan participants.
  - **CTS (Consolidated Tape System)**: Trade reports (last sale).
  - **CQS (Consolidated Quotation System)**: Best bid/offer quotes from each exchange.

- **UTP (Unlisted Trading Privileges Plan)**: Covers NASDAQ-listed (Tape C) securities. Operated by Nasdaq on behalf of UTP Plan participants.
  - **UTDF (UTP Trade Data Feed)**: Trade reports.
  - **UQDF (UTP Quotation Data Feed)**: Best bid/offer quotes.

The SIP aggregates quotes from all NMS exchanges and calculates the NBBO. SIP latency is typically in the range of hundreds of microseconds to low single-digit milliseconds. Under the SEC's 2023 market data infrastructure rule updates, the consolidated tape is evolving toward a competing consolidator model in the US.

In Europe, following MiFID II/MiFIR, there was no mandatory consolidated tape until the EU adopted rules for a European consolidated tape provider (CTP) in 2024, with Cboe subsidiary being selected as the first CTP for equities.

#### Direct Exchange Feeds

Professional trading desks subscribe to direct feeds from individual exchanges for several reasons:

- **Lower latency**: Direct feeds arrive faster than the consolidated tape because there is no aggregation step. The latency advantage can be 10-500 microseconds depending on infrastructure.
- **Greater depth**: Direct feeds typically provide full depth-of-book or more price levels than the consolidated tape.
- **Order-level detail**: MBO feeds are only available via direct feeds.
- **Imbalance and auction data**: Opening/closing auction indicative prices, paired/unpaired shares.
- **Additional message types**: Order imbalance indicators, LULD (Limit Up-Limit Down) bands, short sale restriction indicators, regulatory halt messages.

The trade-off is cost: each direct feed requires a separate exchange data license, co-location or network connectivity, and a dedicated feed handler. A US equities desk subscribing to all 16 exchanges' direct feeds will spend significantly more than one using only the SIP, but gains a material latency and information advantage.

### Market Data Vendors

Major third-party market data vendors provide aggregated, normalized feeds:

| Vendor | Key Products |
|--------|-------------|
| **Bloomberg** | Bloomberg B-PIPE (real-time), Bloomberg Terminal, BVAL (valuations) |
| **Refinitiv (LSEG)** | Refinitiv Real-Time (Elektron/TREP), Eikon, Datascope |
| **ICE Data Services** | ICE Consolidated Feed, ICE Global Network, ICE Pricing & Analytics |
| **Nasdaq Global Data Services** | Nasdaq Global Data Service, Nasdaq Basic |
| **FactSet** | Real-time feed via Open:FactSet |
| **S&P Global Market Intelligence** | Capital IQ real-time |
| **MayStreet** | Ultra-low-latency normalized feeds, full packet capture |
| **Exegy** | Hardware-accelerated feed handling, nxFramework |

Vendor feeds offer convenience (single API, normalized symbology, broad coverage) at the cost of additional latency (typically 1-10ms over direct) and higher per-instrument licensing fees.
