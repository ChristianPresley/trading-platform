## 8. AML/KYC in Trading Context

### 8.1 Suspicious Activity Monitoring

While AML programs are primarily a firm-wide compliance function, trading desk applications integrate with AML systems in several ways:

- **Transaction monitoring:** Trading activity is fed to AML transaction monitoring systems (e.g., NICE Actimize, Oracle Financial Services AML, SAS Anti-Money Laundering) that apply rules and models to detect patterns indicative of money laundering, terrorist financing, or other financial crimes.
- **Suspicious patterns in trading:**
  - Structuring of transactions to avoid reporting thresholds
  - Rapid movement of funds through securities transactions (buying securities, immediately selling, and wiring proceeds)
  - Trading in thinly traded securities to manipulate prices and create artificial profits
  - Layering transactions through multiple accounts to obscure the audit trail
  - Mirror trading (offsetting transactions in correlated securities in different jurisdictions)
  - Use of shell companies or nominee accounts to conceal beneficial ownership

- **SAR/STR filing:** When suspicious activity is identified, the firm must file a Suspicious Activity Report (SAR) with FinCEN in the US (within 30 days of detection, or 60 days if no suspect is identified) or a Suspicious Transaction Report (STR) with the FCA (UK) or relevant NCA. The filing is confidential, and the firm must not "tip off" the subject.
- **Currency Transaction Reports (CTRs):** In the US, cash transactions exceeding $10,000 must be reported to FinCEN on a CTR. While less common in securities trading (which is predominantly electronic), physical settlement or cash transactions may trigger this requirement.

### 8.2 Sanctions Screening

Trading desks must screen all counterparties, issuers, and beneficial owners against sanctions lists.

**Key sanctions lists:**

- **OFAC SDN List (US):** The Office of Foreign Assets Control's Specially Designated Nationals and Blocked Persons List. Also includes sectoral sanctions (SSI) and non-SDN lists (CAPTA, NS-MBS).
- **EU/UK sanctions lists:** Consolidated lists maintained by the EU and the UK Office of Financial Sanctions Implementation (OFSI).
- **UN Security Council sanctions.**
- **Country-specific programs:** Cuba, Iran, North Korea, Syria, Russia (which has expanded significantly since 2022), and others.

**Implementation in trading systems:**

- **Pre-trade screening:** Every order is screened against sanctions lists to verify that neither the counterparty nor the issuer of the security (nor any substantially owned subsidiary) is sanctioned.
- **Reference data enrichment:** Security master data must include issuer domicile, ultimate parent, and ownership chain to support sanctions screening against securities issued by sanctioned entities or entities in sanctioned jurisdictions.
- **Real-time list updates:** Sanctions lists can be updated at any time. Systems must be able to ingest updates and apply them to pending orders within minutes.
- **Secondary sanctions:** US secondary sanctions may apply to non-US persons who transact with sanctioned parties. Firms operating globally must consider the extraterritorial reach of US sanctions.
- **Sectoral sanctions:** Some sanctions prohibit only specific types of transactions (e.g., debt with maturity over 14 days, new equity issuance) rather than all transactions with the designated party. This requires more granular screening logic.
