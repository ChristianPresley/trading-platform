## 9. Position Reporting

### 9.1 Large Trader Reporting (SEC)

**SEC Rule 13h-1 (Large Trader Reporting):**

- Any person or entity whose transactions in NMS securities equal or exceed 2 million shares or $20 million in any calendar day, or 20 million shares or $200 million in any calendar month, must register as a "large trader" with the SEC.
- Large traders receive a Large Trader ID (LTID) which must be provided to all broker-dealers through whom they transact.
- Broker-dealers must maintain records of LTID-associated transactions and report them to the SEC upon request (via electronic filing through the EDGAR system or, historically, the EBS — Electronic Blue Sheet system, now being replaced by CAT).

### 9.2 CFTC Position Limits and Reporting

**CFTC Position Limits (Part 150):**

- Federal position limits apply to 25 core referenced futures contracts (agricultural, energy, metals) and their economically equivalent swaps.
- Spot month limits are set at 25% of estimated deliverable supply (physical delivery contracts) or 25% of open interest (cash-settled contracts), up to a maximum of 10,000 contracts.
- Single-month and all-months limits are set at 10% of open interest for the first 25,000 contracts and 2.5% thereafter.
- Exchange-set position limits and accountability levels may be more restrictive.

**CFTC Reporting requirements:**

- **Form 40 (Statement of Reporting Trader):** Filed by traders who hold or control positions at or above reporting levels. Contains identification information and trading purpose.
- **Large Trader Reporting System (LTRS):** Futures commission merchants (FCMs) and clearing members must file daily large trader reports (Part 17) for any account holding a position at or above the CFTC's reportable level in any single futures or options contract.
- **Ownership and control reporting (OCR):** Links trading accounts to their owners, controllers, and associated entities for surveillance purposes.

### 9.3 SEC 13F Filings

**SEC Form 13F:**

- Filed quarterly (within 45 days of quarter-end) by institutional investment managers exercising investment discretion over $100 million or more in Section 13(f) securities (primarily US exchange-listed equities, ETFs, and certain convertible bonds and options).
- Reports the name, class, CUSIP, number of shares, and market value of each holding, along with investment discretion (sole, shared, none) and voting authority.
- Confidential treatment requests may be made for positions that the manager is actively accumulating or disposing of, though the SEC scrutinizes such requests and disclosure is delayed, not eliminated.
- 13F data is publicly available via the SEC EDGAR system and is widely used by the investment community for position tracking.

### 9.4 Schedule 13D and 13G

**Schedule 13D (Beneficial Ownership Report):**

- Required when any person or group acquires beneficial ownership of more than 5% of a class of registered equity securities.
- Must be filed within 5 business days of crossing the 5% threshold (reduced from 10 calendar days under 2024 amendments).
- Requires disclosure of: the identity and background of the acquirer, the source and amount of funds used, the purpose of the acquisition (including any plans for mergers, reorganizations, or other extraordinary transactions), and the number of shares held.
- Material changes (1% or more change in position, or change in purpose or plans) require an amendment within 2 business days.

**Schedule 13G (Short-Form Beneficial Ownership Report):**

- Available to certain categories of filers who acquire more than 5% but are not seeking to change or influence control of the issuer:
  - **Qualified Institutional Investors (QIIs):** Must file within 45 days of quarter-end in which the 5% threshold is first crossed. Amendments required within 5 business days of month-end if holdings exceed 10% or change by 5%.
  - **Passive investors:** Must file within 5 business days of crossing 5%. Must file within 2 business days of exceeding 10%.
  - **Exempt investors:** Certain investors who acquired shares prior to the issuer's registration.
- If the holder's intent changes from passive to active, they must switch to Schedule 13D within 10 days.

**Trading desk implementation:**

- Position monitoring systems must track beneficial ownership percentages in real time across all funds, accounts, and strategies managed by the firm.
- Alerts must fire when positions approach the 5% threshold (typically at 4.5% or a configurable warning level) to allow for timely filing preparation.
- Holdings must be aggregated across all accounts under common control, including derivative positions that confer economic exposure or voting rights (swaps, options, convertible securities).
