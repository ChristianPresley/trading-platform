## 7. Custody and Asset Servicing

### 7.1 Custodian Interactions

Custodians hold securities on behalf of their clients and perform safekeeping, settlement, income collection, and corporate actions processing.

**Key custodian functions:**

- **Safekeeping:** Securities are held in the custodian's account at the relevant CSD (DTC in the US, Euroclear/Clearstream in Europe, CCASS in Hong Kong, etc.). The custodian maintains sub-accounts for each client.
- **Settlement:** The custodian receives settlement instructions from the client and executes deliveries and receipts of securities and cash at the CSD.
- **Income collection:** The custodian collects dividends, interest payments, and other income on behalf of clients, applying appropriate tax withholding and reclaim processes.
- **Corporate actions:** The custodian notifies clients of corporate actions, collects elections, and processes outcomes.
- **Proxy voting:** The custodian facilitates proxy voting by forwarding materials and collecting/submitting votes (often via services like Broadridge).
- **Reporting:** Daily and periodic statements of holdings, transactions, income, and tax.

**Major global custodians:** BNY, State Street, Citibank, JPMorgan, HSBC, BNP Paribas, Northern Trust.

### 7.2 SWIFT Messaging

SWIFT (Society for Worldwide Interbank Financial Telecommunication) provides the standardized messaging infrastructure for communication between custodians, investment managers, and other financial institutions.

**Key SWIFT message types for securities (MT5xx series, ISO 15022):**

| MT Type | Purpose |
|---------|---------|
| MT502 | Order to Buy or Sell |
| MT509 | Trade Status Message |
| MT515 | Client Confirmation of Purchase or Sale |
| MT517 | Trade Confirmation Affirmation |
| MT518 | Market-Side Securities Trade Confirmation |
| MT535 | Statement of Holdings |
| MT536 | Statement of Transactions |
| MT537 | Statement of Pending Transactions |
| MT540 | Receive Free (delivery without payment) |
| MT541 | Receive Against Payment |
| MT542 | Deliver Free |
| MT543 | Deliver Against Payment |
| MT544-MT547 | Settlement Confirmations (corresponding to MT540-543) |
| MT548 | Settlement Status and Processing Advice |
| MT564 | Corporate Action Notification |
| MT565 | Corporate Action Instruction |
| MT566 | Corporate Action Confirmation |
| MT567 | Corporate Action Status |
| MT568 | Corporate Action Narrative |
| MT578 | Settlement Allegement |
| MT586 | Statement of Settlement Allegements |

**Migration to ISO 20022:**

- The securities industry is migrating from ISO 15022 (MT messages) to ISO 20022 (MX messages) for richer, more structured data.
- SWIFT has set a migration timeline with a coexistence period. For payments (MT1xx/MT2xx), the deadline was November 2025. For securities (MT5xx), the migration timeline extends into 2025-2028 depending on market infrastructure readiness.
- ISO 20022 securities messages use the "sese" (securities settlement), "semt" (securities management), and "seev" (securities events/corporate actions) message families.
- Benefits of ISO 20022: richer data content, structured and unambiguous fields, better support for regulatory reporting, enhanced STP rates.

### 7.3 Income Collection

- **Dividend collection:** The custodian collects dividends on behalf of clients based on record date positions. The custodian ensures that dividend entitlements from securities on loan are collected from the borrower (manufactured dividends).
- **Coupon/interest collection:** For fixed income securities, the custodian collects periodic coupon payments. Accrued interest calculations at purchase and sale must be reconciled against the custodian's records.
- **Income pre-notification:** Custodians provide advance notification of expected income payments, allowing the investment manager to reconcile expected vs. actual receipts.
- **Tax on income:** See Section 8 below for withholding tax and reclaim processes.

---

## 8. Tax Reporting and Withholding

### 8.1 Wash Sale Rules

Under IRC Section 1091 (US), a wash sale occurs when a taxpayer sells a security at a loss and purchases a "substantially identical" security within 30 days before or after the sale (the 61-day window).

**Wash sale implications:**

- The loss is disallowed for tax purposes.
- The disallowed loss is added to the cost basis of the replacement security.
- The holding period of the replacement security includes the holding period of the original security.

**Implementation complexity:**

- Wash sale detection must span all accounts controlled by the same taxpayer (including IRAs and spouse accounts under common interpretations, though the IRS has not provided definitive guidance on cross-account wash sales).
- "Substantially identical" is not precisely defined but includes: same CUSIP, same issuer with similar terms, options on the same security, and convertible securities.
- Short sales, options exercises, and corporate actions (spinoffs, mergers) can all trigger or complicate wash sale calculations.
- The system must track the chain of wash sale adjustments across multiple lots and cascading sales/repurchases.

### 8.2 Tax Lot Accounting

Tax lot accounting tracks the acquisition date, cost basis, and adjustment history for each individual lot of securities.

**Tax lot selection methods:**

- **FIFO (First In, First Out):** The oldest lots are sold first. This is the IRS default method if no other method is elected.
- **LIFO (Last In, First Out):** The newest lots are sold first.
- **Specific identification:** The taxpayer designates which specific lots are being sold. Under IRS regulations, the specific lots must be adequately identified at the time of sale.
- **Average cost:** Available for mutual fund shares and certain dividend reinvestment plan shares. The average cost basis of all shares is used.
- **Highest cost first:** Sells the lots with the highest cost basis first, minimizing realized gains.
- **Tax-optimal (loss harvesting):** Algorithmic selection of lots that minimizes the tax liability, considering short-term vs. long-term gains, losses available for harvest, and wash sale implications.

**Cost basis reporting (US):**

- Under IRC Section 6045, broker-dealers must report cost basis and holding period to both the IRS and the customer on Form 1099-B.
- "Covered securities" (acquired after specific dates depending on security type: equities after January 1, 2011; mutual funds/ETFs after January 1, 2012; fixed income and options after January 1, 2014) require broker reporting of adjusted cost basis.
- Adjustments for wash sales, corporate actions, amortization/accretion of bond premium/discount, and return of capital distributions must be reflected in the reported cost basis.

### 8.3 1099 Reporting

US broker-dealers and custodians issue various 1099 forms:

| Form | Reports |
|------|---------|
| 1099-B | Proceeds from broker and barter exchange transactions (sales, redemptions, maturities). Includes cost basis, gain/loss, short-term/long-term classification, and wash sale adjustments for covered securities. |
| 1099-DIV | Dividends and distributions (ordinary dividends, qualified dividends, capital gain distributions, nondividend distributions/return of capital, foreign tax paid). |
| 1099-INT | Interest income (taxable interest, tax-exempt interest, Treasury interest, foreign tax paid, original issue discount). |
| 1099-OID | Original issue discount on bonds purchased at a discount to par. |
| 1099-MISC | Miscellaneous income (substitute payments in lieu of dividends or interest from securities lending, various other income types). |

**Consolidated 1099:** Most broker-dealers issue a single consolidated 1099 statement combining all applicable 1099 forms, typically in late January or February (with corrections through mid-March).

**Reporting deadlines:** Forms are due to recipients by February 15 and to the IRS by February 28 (paper) or March 31 (electronic).

### 8.4 W-8BEN and International Tax Withholding

**W-8BEN / W-8BEN-E:**

- Non-US persons (W-8BEN for individuals, W-8BEN-E for entities) must provide this form to the US withholding agent (custodian or broker) to claim reduced withholding rates under applicable tax treaties.
- The standard US withholding rate on dividends paid to non-resident aliens is 30%. Tax treaties may reduce this rate (e.g., 15% for UK residents, 0% for certain pension funds).
- The W-8BEN must include the beneficial owner's country of residence, tax identification number (or foreign TIN), and the specific treaty article and rate claimed.
- Forms are valid for 3 years from the date of signing (unless a change in circumstances occurs earlier).

**Qualified Intermediary (QI) regime:**

- Under the QI Agreement (Revenue Procedure 2022-43 and subsequent updates), foreign financial institutions that act as intermediaries in the payment chain can assume withholding and reporting responsibilities.
- QIs apply appropriate withholding rates based on their knowledge of beneficial owners, reducing the need to disclose individual customer identities to US withholding agents.
- QIs must have a compliance program, undergo periodic review, and certify compliance.

**FATCA (Foreign Account Tax Compliance Act):**

- US legislation requiring foreign financial institutions (FFIs) to report US account holders to the IRS or face 30% withholding on US-source payments.
- Implemented through intergovernmental agreements (IGAs) with over 100 jurisdictions.
- FFIs must perform due diligence on new and pre-existing accounts to identify US indicia.
- Reporting via Form 8966 (FATCA Report) or through the IGA partner jurisdiction's tax authority.

**CRS (Common Reporting Standard):**

- OECD-developed global standard for automatic exchange of financial account information between participating jurisdictions (over 100).
- Similar in concept to FATCA but multilateral. Financial institutions must identify the tax residence of account holders and report account details to their local tax authority, which exchanges the information with the account holder's country of tax residence.

**Dividend withholding tax reclaims:**

- When dividends from foreign securities are subject to withholding tax exceeding the applicable treaty rate, the system must track the excess withholding and facilitate reclaim applications to the source country's tax authority.
- Reclaim processes vary significantly by country: some are quick (e.g., US, UK), others take years (e.g., Italy, Spain historically).
- The system must track: gross dividend, statutory withholding rate, treaty rate, actual withholding applied, amount eligible for reclaim, reclaim filing status, and amount recovered.
- Tax relief at source (where the correct treaty rate is applied at the time of payment) is the preferred approach but requires proper documentation (e.g., W-8BEN for US securities, certificate of residence for other jurisdictions) to be on file with the custodian before the payment date.
