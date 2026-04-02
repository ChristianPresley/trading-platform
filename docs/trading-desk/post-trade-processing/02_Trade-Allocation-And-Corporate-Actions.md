## 3. Trade Allocation

### 3.1 Block Trade Allocation

Institutional investment managers frequently execute block trades (large orders covering multiple client accounts) and then allocate the fills to individual accounts post-execution.

**Allocation workflow:**

1. **Pre-trade allocation intent:** The portfolio manager or compliance system determines the intended allocation before the order is placed. This is a best execution and fairness requirement: allocations should not be determined based on whether the trade was profitable.
2. **Order execution:** The block order is executed as a single order to minimize market impact and achieve best execution.
3. **Allocation instruction submission:** After execution (or during execution for partial fills), the investment manager submits allocation instructions to the broker, specifying the account, quantity, and settlement details for each allocation.
4. **Allocation matching:** The broker's system matches the total allocated quantity to the total executed quantity. Any discrepancy is flagged for resolution.
5. **Trade booking:** Individual trades are booked to each account in the OMS and downstream systems (portfolio accounting, custodian instructions).

**Allocation timing under T+1:**

- Under SEC Rule 15c6-2, allocations must be completed by end of trade date to achieve same-day affirmation. This requires highly automated allocation processes.
- Pre-trade allocation models (where allocation instructions are submitted with the order) are increasingly preferred over post-trade allocation.
- Allocation instructions are typically communicated electronically via FIX messages (FIX tag 79 for AllocAccount), DTCC CTM, or proprietary platform APIs.

**Fairness requirements:**

- SEC and FINRA require that allocations be fair and equitable across accounts. Common acceptable methods include: pro-rata allocation, rotational allocation, and random allocation.
- Prohibited practices: allocating winning trades to favored accounts (cherry-picking), allocating trades based on post-execution price movement.
- Compliance systems monitor allocation patterns for signs of unfair allocation, including: accounts that consistently receive better prices, accounts that receive disproportionately large allocations of profitable trades, and deviation from the firm's stated allocation policy.

### 3.2 Step-Outs and Give-Ups

**Step-out trades:**

- A step-out occurs when an investment manager executes a trade through one broker but directs that part or all of the trade be "stepped out" (transferred) to another broker for clearing and settlement.
- Common reasons: the manager wants execution quality from one broker but has a relationship (research services, CSA — commission sharing arrangement) with another.
- The executing broker submits the trade to the clearing broker on behalf of the client, typically via FIX Allocation messages or DTCC platform instructions.
- Commission is typically split: the executing broker retains an execution-only commission, and the step-out broker receives the remainder.

**Give-up trades:**

- A give-up occurs primarily in futures trading. A client executes a trade through an executing broker but "gives up" the trade to a different clearing FCM (Futures Commission Merchant).
- The executing broker submits the trade to the clearing FCM via the exchange's give-up system (e.g., CME's give-up system).
- Give-up agreements (typically using the FIA standard give-up agreement) define the rights and obligations of the executing broker, the clearing FCM, and the client.
- The clearing FCM accepts the give-up and carries the position in the client's account, including margin obligations.

### 3.3 Average Price Allocation

When a block order is filled in multiple partial executions at different prices, the average price is calculated and allocated to client accounts.

**Average pricing rules:**

- **FINRA Rule 5320.02:** Permits average price execution for institutional accounts, provided the customer has consented and the firm discloses the use of average pricing.
- The average price is calculated as the weighted average of all fill prices for the block, weighted by quantity at each price.
- Allocation to individual accounts uses the average price, so all accounts in the block receive the same per-share (or per-unit) price regardless of which specific fills are allocated to them. This ensures fairness.
- Residual share/lot allocation: When the block quantity does not divide evenly among accounts, residual shares are allocated according to the firm's stated policy (e.g., round-robin across accounts, allocated to the account with the largest target allocation).

**Average pricing across days:**

- If a block order is executed over multiple days, average pricing may be applied across all fills or on a day-by-day basis, depending on the firm's policy and client agreement.
- Cross-day averaging introduces additional complexity for P&L calculation and regulatory reporting (trade date vs. settlement date attribution).

---

## 4. Corporate Actions Processing

Corporate actions are events initiated by a publicly traded company that affect the securities it has issued. Accurate and timely processing of corporate actions is critical to maintaining correct positions, entitlements, and valuations.

### 4.1 Mandatory Corporate Actions

Mandatory actions occur automatically without requiring a decision from the security holder.

**Types:**

- **Cash dividends:** Payment of cash to shareholders on the record date. Processing involves: capturing the announcement, setting up the event in the system (ex-date, record date, payment date, rate per share), calculating entitlements based on positions held on record date, booking the payment on payment date.
- **Stock dividends / Bonus issues:** Distribution of additional shares. The system must adjust positions (increase share count) and adjust cost basis per share.
- **Stock splits / Reverse splits:** The system must adjust position quantities and per-share cost basis by the split ratio (e.g., 2-for-1 split doubles shares and halves cost basis).
- **Mergers / Acquisitions (cash or stock consideration):** The acquired company's shares are removed from the portfolio and replaced with cash, acquirer shares, or a combination. Fractional share handling, proration, and mixed consideration require careful processing.
- **Spinoffs:** Distribution of shares in a newly created company. The system must create a new position, allocate cost basis between the parent and spinoff (using IRS-provided allocation ratios or fair market value apportionment), and adjust the parent position's cost basis.
- **Name changes / CUSIP changes:** Security identifier changes that must be reflected in the security master and all position records.
- **Mandatory conversions:** Convertible securities that mandatorily convert to common stock at a predetermined date or trigger event.

### 4.2 Voluntary Corporate Actions

Voluntary actions require the security holder to make an election.

**Types:**

- **Tender offers:** An offer to purchase shares at a specified price (usually at a premium). The system must support election submission (tender all, tender partial, or do not tender), track the election deadline, and process the outcome (full acceptance, proration, or rejection).
- **Rights issues:** Offering existing shareholders the right to purchase additional shares at a discount. Elections include: exercise rights, sell rights, or let rights lapse.
- **Optional dividends (DRIP — Dividend Reinvestment Plans):** Shareholders choose to receive dividends in additional shares rather than cash. Standing elections must be maintained and applied automatically.
- **Consent solicitations:** Requests for bondholder consent to amend indenture terms. The system must track elections and apply any consent fees.
- **Exchange offers:** Offers to exchange existing securities for new securities with different terms (common in debt restructuring).
- **Put/call options on bonds:** Bondholders may exercise put rights or issuers may exercise call rights. The system must track exercise dates, notify relevant parties, and process redemptions.

**Election management:**

- The system must present upcoming voluntary actions to portfolio managers with all relevant details, deadlines, and default elections.
- Election instructions must be communicated to the custodian before the election deadline (often 1-3 business days before the issuer's deadline, as custodians impose earlier internal deadlines).
- For multi-custodian setups, elections may need to be split across custodians based on where the securities are held.
- Standing instructions (e.g., always reinvest dividends, always exercise oversubscription privileges) reduce manual intervention.

### 4.3 Record Dates and Ex-Dates

- **Declaration date:** The date the company announces the corporate action.
- **Ex-date (ex-dividend date):** The date on or after which the security trades without entitlement to the pending action. For US securities, the ex-date is typically one business day before the record date (aligned with T+1 settlement). Trades executed on or after the ex-date will settle after the record date, so the buyer is not entitled.
- **Record date:** The date on which the company's records are examined to determine which shareholders are entitled to the action.
- **Payment date:** The date on which the cash dividend is paid, the stock dividend is distributed, or the merger consideration is delivered.

**Ex-date processing:**

- On the ex-date, the system must adjust open orders. For cash dividends, limit buy orders below the market are typically reduced by the dividend amount (DK — Don't Know adjustment) unless marked "Do Not Reduce."
- Stock splits require adjustment of both the share quantity and the limit price on open orders.
- The security's price reference is adjusted on the ex-date to reflect the corporate action, which must be accounted for in P&L calculations, technical analysis, and historical price charts.

### 4.4 Data Sources and Standards

- **DTCC (Corporate Actions via GCA — Global Corporate Actions):** The primary source for US corporate action data, distributed via automated feeds.
- **SWIFT corporate action messages (MT564-MT568):** ISO 15022 messages for corporate action notification (MT564), election instruction (MT565), confirmation (MT566), status (MT567), and narrative (MT568). Being replaced by ISO 20022 equivalents (seev.031-seev.044).
- **ISO 20022 corporate actions messages:** The industry is migrating to ISO 20022 format for corporate actions messaging, with richer data content and improved machine readability.
- **Bloomberg corporate actions data (CACS function):** Widely used reference data source for corporate action details.
- **SIX Financial Information, ICE Data Services, Refinitiv:** Additional corporate actions data providers.
- **XBRL (Inline XBRL) and EDGAR:** For US-listed companies, corporate action details may be extracted from SEC filings.
