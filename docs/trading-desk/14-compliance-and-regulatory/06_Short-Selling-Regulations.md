## 6. Short Selling Regulations

### 6.1 Locate Requirements

Before executing a short sale, the broker-dealer must have reasonable grounds to believe that the security can be borrowed and delivered by settlement date.

**US (Regulation SHO Rule 203(b)):**

- The firm must document the locate source (stock loan desk confirmation, easy-to-borrow list, or third-party locate service).
- Easy-to-borrow (ETB) lists must be updated at least daily and are based on the firm's historical ability to borrow the security.
- For securities not on the ETB list, a specific locate must be obtained from the stock loan desk or an external lending agent.
- Locates are typically valid for the trading day only and must be refreshed for orders carried overnight.
- Market makers may have an exception from the locate requirement under certain conditions (Rule 203(b)(2)(iii)), though this exception has been narrowed over time.

**EU Short Selling Regulation (SSR — Regulation 236/2012):**

- Requires a "locate" arrangement: the seller must have borrowed the shares, entered into an agreement to borrow, or have an arrangement with a third party confirming that the shares can be located and there is a reasonable expectation of settlement.
- Uncovered (naked) short selling of shares admitted to trading on an EU venue is prohibited.
- Uncovered short selling of EU sovereign debt CDS is also restricted (unless the buyer can demonstrate a hedging purpose).

### 6.2 Regulation SHO (US)

Regulation SHO is the primary US regulation governing short sales.

**Key provisions:**

- **Rule 200:** Definitions of long, short, and short exempt positions. Requires firms to aggregate net positions across all accounts and strategies to determine long/short status, with exceptions for independent trading units.
- **Rule 203(b)(1) — Locate requirement:** As described above.
- **Rule 203(b)(3) — Close-out requirement:** If a fail to deliver persists for 13 consecutive settlement days (T+13 from trade date, or T+3 from settlement date under T+1 settlement), the firm must purchase or borrow shares to close out the position. During the close-out period, the firm (and any broker acting on its behalf) is prohibited from further short sales in that security without first pre-borrowing.
- **Rule 204 — Close-out for CNS fails:** Positions that result in a fail to deliver at the NSCC's Continuous Net Settlement (CNS) system must be closed out by the morning of T+2 (under T+1 settlement), or T+4 in the case of long sales or market maker activity.
- **Threshold securities list:** The exchanges publish daily lists of securities with significant FTD levels (aggregate fails of 10,000+ shares that persist for 5+ consecutive settlement days and represent at least 0.5% of the total shares outstanding). Enhanced close-out obligations apply to threshold securities.

### 6.3 Short Sale Rule (SSR) / Circuit Breaker

SEC Rule 201 (the "Alternative Uptick Rule" or "Short Sale Circuit Breaker"):

- **Trigger:** When a security's price declines by 10% or more from the previous day's closing price.
- **Effect:** Once triggered, short sale orders may only be executed at a price above the current national best bid (the "uptick" requirement). This restriction applies for the remainder of the trading day and the entire following trading day.
- **Purpose:** Prevents short sellers from exacerbating a rapid price decline.
- **Implementation:** The listing exchange triggers the circuit breaker and disseminates a "short sale price test restriction" indicator via market data feeds. The OMS must enforce the restriction by rejecting or re-pricing short sale orders that do not comply.
- **Exceptions:** Market makers may be exempt for bona fide market-making activity. Orders marked "short exempt" may execute below the bid if the trader has an independent basis for marking the order exempt (e.g., the order was placed before the trigger, or the sale is for a VWAP contract).

### 6.4 Reporting Requirements

- **SEC Form SH (historical):** Previously required for institutional managers with significant short positions; no longer in effect, but proposals for new short position reporting have been advanced (SEC Rule 13f-2, effective January 2025).
- **SEC Rule 13f-2 and Form SHO:** Requires institutional investment managers to report short position data to the SEC on a monthly basis when positions exceed certain thresholds. Aggregated, anonymized data is then published by the exchanges.
- **EU SSR reporting thresholds:** Net short positions in shares of 0.1% of issued share capital must be reported to the NCA; positions of 0.5% and each subsequent 0.1% increment must be publicly disclosed. For sovereign debt, thresholds are set by the relevant NCA.
- **FCA (UK):** Similar disclosure regime post-Brexit, with reporting to the FCA at 0.1% and public disclosure at 0.5%.
- **ESMA emergency powers:** ESMA can impose temporary short selling bans in exceptional circumstances (invoked during the March 2020 COVID-19 market stress).
