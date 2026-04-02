## Dark Pools and Alternative Trading Systems

### 5.1 Overview

Dark pools are trading venues that do not display orders in the public order book (no pre-trade transparency). They exist to allow institutional investors to execute large orders without revealing their trading intent to the broader market.

As of recent data, dark pool volume accounts for approximately 15-18% of total US equity volume. Off-exchange volume (including dark pools and single-dealer platforms) represents approximately 40-45% of total volume.

### 5.2 Types of Dark Pools

**Exchange-Operated Dark Pools**:
- Operated by exchange groups as separate ATSs
- Examples: NYSE Arca Dark, Cboe BIDS
- Subject to Reg ATS and exchange supervision
- Typically offer midpoint matching and price improvement

**Broker-Operated Dark Pools**:
- Operated by broker-dealers as ATSs
- Examples: Goldman Sachs Sigma-X2, Morgan Stanley MS Pool, JP Morgan JPM-X, UBS ATS
- May internalize order flow before routing to other venues
- Subject to Reg ATS; quarterly Form ATS-N filings required (publicly available since 2019)
- Potential conflict of interest: broker routing to its own pool vs. external venues

**Independent Dark Pools / Crossing Networks**:
- Not affiliated with a major broker or exchange
- Examples: Liquidnet, BIDS Trading, IntelligentCross, Level ATS
- Liquidnet operates as a block-crossing network with minimum quantity thresholds (historically 10,000 shares, now more flexible)
- BIDS Trading uses a conditional negotiation protocol

**Electronic Liquidity Providers (ELPs) / Single-Dealer Platforms**:
- Not technically ATSs but operate as systematic internalizers
- Examples: Citadel Connect, Virtu (formerly KCG)
- The dealer provides liquidity from its own inventory
- Typically provide price improvement (sub-penny) vs. NBBO
- Account for a significant and growing share of off-exchange volume

### 5.3 Matching Mechanisms

**Midpoint Matching**:
- Orders match at the midpoint of the NBBO
- Provides price improvement of half the spread for both sides
- Most common dark pool matching model
- Vulnerable to "information leakage" if the midpoint is moving quickly

**Price Improvement (Sub-Penny)**:
- Match at NBBO midpoint or better, in sub-penny increments
- Rule 612 (Sub-Penny Rule) prohibits sub-penny quoting on lit exchanges for stocks above $1.00, but dark pools can match at sub-penny prices
- Example: NBBO is $50.00 x $50.02; dark pool matches at $50.01 (midpoint) or $50.009 (sub-penny improvement)

**Periodic Auction / Batch Matching**:
- Orders accumulate over a short interval (e.g., 100 milliseconds) and match simultaneously
- Reduces speed advantage and adverse selection
- Examples: Cboe Periodic Auctions (Europe), IntelligentCross (US)
- IEX's speed bump serves a similar anti-latency-arbitrage purpose

**Conditional Orders**:
- Used in block-crossing venues (BIDS Trading, Liquidnet)
- Two-phase protocol:
  1. **Indication phase**: Participant indicates interest (symbol, side, approximate size) without committing
  2. **Firm-up phase**: When a contra-side match is found, both parties receive a conditional notification and must "firm up" (commit to a specific price and quantity) within a short window
- Reduces information leakage: interest is only revealed to matched contra-side participants
- Firm-up rate (percentage of conditional notifications that result in fills) is a key quality metric

### 5.4 Indications of Interest (IOIs)

IOIs are messages from dark pool operators (or brokers) indicating potential liquidity. Types:

| IOI Type | Description | Actionability |
|----------|-------------|---------------|
| **Natural** | Represents genuine institutional order flow | High |
| **Facilitation** | Broker may commit capital to fill | Medium |
| **Informational** | General indication, may not represent firm interest | Low |

**IOI Fields**:
- Symbol, Side, Approximate Quantity (range, not exact), Price indication
- IOI qualifier: Natural vs. Facilitation vs. Informational
- Venue identifier

**Regulatory Concerns**:
- FINRA Rule 5310 requires IOIs to represent genuine interest
- "Actionable IOIs" that contain all material terms (symbol, side, size, price) must be reported as quotes
- Dark pools that broadcast IOIs aggressively may cause information leakage

### 5.5 Dark Pool Regulation

**Reg ATS (US)**:
- Dark pools with more than 5% of volume in any NMS stock in 4 of the last 6 months must display best-priced orders (effectively becoming quasi-lit)
- Form ATS-N: detailed public disclosure of dark pool operations, conflicts of interest, order types, subscriber categories
- Fair Access requirements for large ATSs

**MiFID II (EU)**:
- Dark pool volume caps (Double Volume Cap mechanism): limits the percentage of trading in a stock that can occur in dark pools
- Reference price waiver: dark pools can avoid pre-trade transparency if they match at the reference price (midpoint of the primary market best bid/offer)
- Large-in-scale (LIS) waiver: orders above the LIS threshold are exempt from pre-trade transparency requirements
