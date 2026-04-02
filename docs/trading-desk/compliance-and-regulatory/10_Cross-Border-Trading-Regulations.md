## 10. Cross-Border Trading Regulations

### 10.1 United States — SEC and CFTC

**Key regulatory bodies:** Securities and Exchange Commission (SEC), Commodity Futures Trading Commission (CFTC), Financial Industry Regulatory Authority (FINRA).

**Key regulations for trading desks:**

- Securities Exchange Act of 1934 (broker-dealer registration, market structure rules)
- Regulation NMS (order protection, access, sub-penny pricing, market data)
- Regulation SHO (short selling)
- Regulation ATS (alternative trading systems registration and fair access)
- SEC Rule 15c3-5 (market access controls)
- SEC Rule 15c3-1 (net capital requirements)
- Dodd-Frank Title VII (OTC derivatives regulation)
- Volcker Rule (restrictions on proprietary trading by banks)
- FINRA Rules (suitability, best execution, trade reporting)

### 10.2 United Kingdom — FCA

**Key regulatory body:** Financial Conduct Authority (FCA).

**Post-Brexit framework:**

- UK retained and onshored MiFID II / MiFIR as UK domestic law, then began diverging.
- UK MiFIR transaction reporting remains largely aligned with EU MiFIR but with UK-specific modifications (e.g., reporting to the FCA rather than through EU ARMs).
- The FCA has proposed reforms under the Wholesale Markets Review, including:
  - Replacing the share trading obligation and the double volume cap
  - Reforming the transparency regime for equities and fixed income
  - Reviewing the systematic internaliser regime
- UK EMIR retained for derivatives reporting, with the FCA and Bank of England as supervisory authorities.
- UK Benchmark Regulation covers LIBOR transition and benchmark manipulation (post-LIBOR scandal reforms).
- Senior Managers and Certification Regime (SM&CR) imposes personal accountability on senior management for compliance failures.

### 10.3 European Union — ESMA

**Key regulatory body:** European Securities and Markets Authority (ESMA), plus national competent authorities (NCAs) in each member state (e.g., BaFin in Germany, AMF in France, CONSOB in Italy).

**Key regulations:**

- MiFID II / MiFIR (investment services, market structure, transparency, transaction reporting)
- MAR (Market Abuse Regulation — insider dealing, market manipulation, unlawful disclosure)
- EMIR (OTC derivatives clearing and reporting)
- SFTR (securities financing transactions reporting)
- CSDR (Central Securities Depositories Regulation — settlement discipline, mandatory buy-ins postponed but still contemplated)
- EU Short Selling Regulation (SSR)
- BMR (Benchmarks Regulation)
- DORA (Digital Operational Resilience Act — effective January 2025, covering ICT risk management, incident reporting, digital operational resilience testing, and third-party risk management for financial entities)

### 10.4 Singapore — MAS

**Key regulatory body:** Monetary Authority of Singapore (MAS).

**Key regulations:**

- Securities and Futures Act (SFA) — licensing, market conduct, and market abuse provisions.
- Financial Advisers Act (FAA) — suitability and advice obligations.
- MAS Notice SFA04-N16 — risk management practices for capital market services licensees.
- OTC derivatives reporting under the SFA Part VIA — reporting of specified derivatives to a licensed trade repository.
- Position limits set by SGX (Singapore Exchange) for exchange-traded derivatives.
- Short selling is permitted but regulated: "naked" short selling is prohibited; covered short selling must comply with SGX rules including a mandatory buy-in regime.
- Substantial shareholding notifications required at 5% threshold under Section 135 of the SFA.

### 10.5 Hong Kong — SFC / HKMA

**Key regulatory bodies:** Securities and Futures Commission (SFC), Hong Kong Monetary Authority (HKMA, for banking institutions).

**Key regulations:**

- Securities and Futures Ordinance (SFO) — market misconduct, licensing, disclosure.
- SFC Code of Conduct — suitability, best execution, client asset protection.
- OTC derivatives mandatory clearing and reporting under the SFO Part IIIA.
- Short selling: SFC maintains a list of designated securities eligible for short selling. Short selling of securities not on the list is prohibited. All short sales must be covered and executed at or above the best current ask price (tick rule).
- Disclosure of interests: Substantial shareholding disclosure required at 5% under Part XV of the SFO, with notification within 3 business days.
- Stock Connect (Shanghai-Hong Kong, Shenzhen-Hong Kong): Cross-border trading link with specific regulatory requirements including daily quotas, eligible securities, investor qualification, and settlement arrangements.

### 10.6 Australia — ASIC

**Key regulatory body:** Australian Securities and Investments Commission (ASIC).

**Key regulations:**

- Corporations Act 2001 — market integrity rules, licensing, market misconduct.
- ASIC Market Integrity Rules — separate rule sets for ASX, Chi-X, and other venues covering pre-trade controls, order management, best execution, and market manipulation.
- ASIC derivative transaction rules (reporting) — reporting of OTC derivatives to a licensed trade repository (DTCC GTR or other).
- Short selling: Covered short selling is permitted; naked short selling is prohibited. Short sale indicators must be included in all sell orders that are short sales. ASIC publishes daily aggregated short sale data.
- Substantial holding disclosure required at 5% under the Corporations Act, with notification within 2 business days.
- Design and Distribution Obligations (DDO) — product governance requirements for financial products.
- ASIC requires algorithmic trading participants to have adequate risk controls, including kill switch capabilities, testing requirements, and monitoring.

### 10.7 Cross-Border Implementation Considerations

When building a multi-jurisdictional trading platform, the following considerations apply:

- **Regulatory perimeter mapping:** Determine which regulations apply based on the entity executing the trade, the venue of execution, the domicile of the client, and the domicile of the instrument's issuer. A single trade may trigger obligations under multiple jurisdictions.
- **Equivalence and substituted compliance:** Some jurisdictions recognize each other's regulatory regimes as equivalent (e.g., EU-US substituted compliance for swap reporting). The system must track which equivalence determinations are in effect and route reporting accordingly.
- **Data localization requirements:** Some jurisdictions require certain data to be stored within their borders (e.g., China, Russia). The system architecture must accommodate data residency constraints.
- **Timezone handling:** Regulatory deadlines are defined in local time of the relevant jurisdiction. A global platform must handle settlement dates, reporting deadlines, and trading hours across all time zones.
- **Multi-entity booking model:** Large firms operate through multiple legal entities across jurisdictions. The system must support entity-specific compliance rules, reporting obligations, and capital requirements.
- **Regulatory change management:** The system must be configurable to adapt to regulatory changes without code changes wherever possible. Regulation evolves continuously, and the platform must support versioned rule sets with effective dates.
