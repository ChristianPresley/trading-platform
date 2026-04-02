## IPO and Secondary Offering Participation

### IPO Process (Primary Market)

- **Book building**: lead underwriter(s) solicit indications of interest (IOIs) from institutional investors during the roadshow period. IOIs specify share quantity and sometimes price limits.
- **Allocation**: underwriter allocates shares based on investor quality, long-term holding intent, and relationship factors. Allocations are discretionary.
- **Pricing**: IPO price is set the night before the first trading day based on the order book, market conditions, and issuer/underwriter negotiation.
- **Stabilization**: the underwriter may engage in stabilizing transactions (buying shares in the aftermarket) to support the IPO price. The greenshoe option (over-allotment option, typically 15% of the offering) allows the underwriter to sell additional shares and buy them back if the price drops.
- **Lock-up period**: insiders and pre-IPO investors are typically restricted from selling for 90-180 days after the IPO.

**Trading desk considerations:**
- IOI submission and tracking workflow.
- Allocation notification parsing and position booking.
- First-day trading: often volatile with wide spreads. Market makers in the IPO typically get the first look at the order book.
- Tracking lock-up expiry dates for potential supply events.

### Secondary Offerings

- **Follow-on offerings**: additional shares issued by an already-public company. Can be dilutive (new shares) or non-dilutive (selling shareholders).
- **Accelerated bookbuilds (ABBs)**: overnight block offerings, typically priced at a discount to the closing price. Common in European and Asian markets.
- **At-the-market (ATM) offerings**: issuer sells shares gradually through a broker-dealer at prevailing market prices. Minimal price impact but slower capital raise.
- **Rights issues**: existing shareholders offered the right to buy new shares at a discount. Rights may be tradeable.
- **Block trades**: large secondary sales by existing holders (private equity exits, insider sales). See Block Trading section.

**Trading desk workflow:**
- Receive deal terms (pricing, size, discount).
- Decision to participate based on fundamental view and portfolio fit.
- Allocation tracking and settlement (typically T+1 or T+2 depending on jurisdiction).
- Hedging during the offering period if participating as an underwriter or syndicate member.

---

## Short Selling Mechanics

### Locate and Borrow

Before selling short, the broker-dealer must have reasonable grounds to believe the security can be borrowed for delivery on settlement date (SEC Reg SHO Rule 203(b)(1)).

**Locate process:**
1. Trader submits locate request specifying security and quantity.
2. Securities lending desk checks internal inventory (long positions held in margin accounts, proprietary positions).
3. If not available internally, the desk contacts external lenders (custodian banks, asset managers, pension funds, insurance companies) or uses electronic locate platforms (e.g., EquiLend, NGT, SL-x).
4. Locate is granted with a rate (borrow cost) expressed in basis points or fee per share.
5. Locate is valid for the trading day; pre-borrows can lock shares for multi-day availability.

**Borrow cost components:**
- **General collateral (GC)**: easy-to-borrow securities. Borrow rate is minimal (close to the federal funds rate or slightly above).
- **Specials**: hard-to-borrow securities command a premium rate, sometimes hundreds of basis points.
- **Collateral**: short seller posts cash collateral (typically 102% of the borrowed security's value for US domestic, 105% for international). The lender rebates interest on this cash minus the borrow fee (the "rebate rate"). A negative rebate means the borrower is paying more than the risk-free rate.
- **Mark-to-market**: collateral is adjusted daily based on the security's closing price.

### Hard-to-Borrow (HTB) Lists

- Maintained by prime brokers and updated daily (sometimes intraday).
- Securities on the HTB list have limited supply relative to demand. Locates may be unavailable or available only at elevated rates.
- Factors driving HTB status: high short interest, small float, concentrated ownership, corporate events (mergers, spin-offs), regulatory restrictions.
- Trading platforms must integrate HTB status into the order entry workflow, preventing short sales when no locate is available.

### Recall Risk

- The securities lender can recall borrowed shares at any time (subject to contractual notice periods, typically T+2 or T+3).
- Recall triggers: lender wants to sell the position, lender needs shares for a proxy vote, corporate action requiring share tender.
- Upon recall, the short seller must either: find an alternative borrow or buy the shares in the market (forced buy-in).
- **Buy-in risk**: if the short seller fails to deliver shares by settlement, the broker or clearinghouse initiates a buy-in, purchasing shares in the open market at potentially unfavorable prices.
- CSDR (EU Central Securities Depositories Regulation) imposes mandatory buy-in penalties for settlement fails.

### Short Interest and Data

- **Short interest**: total shares sold short, reported by FINRA bi-monthly (settlement dates around mid-month and end-of-month).
- **Days to cover (short interest ratio)**: short interest divided by average daily volume. Higher values indicate more crowded short positions.
- **Utilization**: shares on loan divided by shares available to lend. High utilization (>90%) signals a crowded borrow.
- **Cost to borrow**: available from securities lending data providers (IHS Markit / S&P Global, DataLend, FIS Astec Analytics).
- Short squeeze dynamics: when a heavily shorted stock rises, short sellers buy to cover, driving the price higher in a feedback loop.

### Regulatory Framework

- **Reg SHO (US)**: locate requirement, close-out requirement for fails to deliver, threshold securities list.
- **Short Sale Circuit Breaker (Rule 201 / Alternative Uptick Rule)**: when a stock drops 10% or more from the prior day's close, short sales are restricted to prices above the national best bid for the remainder of that day and the following day.
- **EU Short Selling Regulation (SSR)**: disclosure requirements for net short positions (0.2% to regulators, 0.5% to the public). Ban on naked short selling.
- **Market-wide short selling bans**: regulators may impose temporary bans during market stress (as seen in 2008, 2020).
