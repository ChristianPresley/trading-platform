## Clearing and Margining

### Central Counterparty (CCP) Clearing

All exchange-traded futures are cleared through a CCP. The CCP interposes itself between buyer and seller, becoming the buyer to every seller and the seller to every buyer.

**Benefits:**
- **Counterparty risk elimination:** If one party defaults, the CCP covers the other side using its waterfall of financial resources.
- **Netting:** Positions offset at the clearing level. If a firm is long 100 ES and short 50 ES, net exposure is 50.
- **Standardization:** Uniform margin and settlement processes.

**Major CCPs:**

| CCP | Exchange(s) | Products |
|---|---|---|
| **CME Clearing** | CME, CBOT, NYMEX, COMEX | Futures, options, OTC cleared swaps |
| **ICE Clear US** | ICE Futures US | Soft commodities, credit derivatives |
| **ICE Clear Europe** | ICE Futures Europe | Energy, emissions |
| **Eurex Clearing** | Eurex | European equity/fixed income derivatives |
| **LCH (LCH.Clearnet)** | LSE, various | OTC interest rate swaps (world's largest), listed derivatives |
| **JSCC** | OSE/JPX | JGB futures, equity derivatives |
| **OCC** | US options exchanges | Listed equity/index options |

### Initial Margin

The deposit required to open a position. Determined by the exchange/CCP using risk models (SPAN, PRISMA, VaR-based).

**SPAN (Standard Portfolio Analysis of Risk):** See the options document for details. For futures, SPAN evaluates 16 price/volatility scenarios and sets margin at the worst-case loss.

**Eurex PRISMA:** A more advanced margin model that uses historical simulation and Monte Carlo to estimate a 2-day 99.7% Expected Shortfall. Allows broader portfolio offsets.

**LCH PAIRS:** Portfolio Approach to Interest Rate Scenarios. Used for OTC cleared swaps. Evaluates portfolio P&L under hundreds of historical stress scenarios.

### Variation Margin

The daily mark-to-market cash flows.

- If the position gains value, the CCP pays variation margin to the clearing member.
- If the position loses value, the clearing member pays variation margin to the CCP.
- Variation margin is exchanged every business day (often intraday for large moves).

**Important distinction:** Initial margin is a deposit (returned when the position is closed). Variation margin is an actual cash transfer (realized P&L).

### Margin Calls

If an account's equity falls below the **maintenance margin** level:

1. The clearing firm issues a margin call.
2. The call must be met by the next business day's clearing deadline (typically by the start of the next trading session).
3. If not met, the clearing firm can liquidate positions.

**Intraday margin calls:** During extreme volatility, exchanges can issue intraday margin calls (CME Rule 930). These require immediate satisfaction, often within one hour.

**Exchange margin increases:** Exchanges frequently adjust margins during volatile periods. For example, CME increased initial margin on silver (SI) by 84% during the 2011 silver spike, and margins on crude oil surged in 2020 when WTI went negative.

### Margin Offsets

The clearing system recognizes correlated positions and reduces margin:

- **Intra-commodity spreads:** Long March ES vs short June ES. Margin is a fraction of the outright.
- **Inter-commodity spreads:** Long ES vs short NQ. Partial offset because S&P 500 and NASDAQ 100 are correlated.
- **Exchange-recognized combos:** CME publishes a list of inter-commodity spread credits (updated monthly).

### Default Waterfall

If a clearing member defaults, the CCP uses a waterfall of financial resources:

1. **Defaulting member's initial margin** — covers most losses.
2. **Defaulting member's default fund contribution** — the member's share of the mutualized guarantee fund.
3. **CCP's own capital (skin in the game)** — CCP contributes its own funds.
4. **Other members' default fund contributions** — mutualized loss sharing.
5. **Assessment powers** — CCP can call for additional contributions from surviving members.
6. **CCP's remaining capital and recovery tools** — tear-up of positions, partial settlement, etc.

This waterfall is designed to ensure that a single member's default does not cause systemic failure.

---

## Delivery and Settlement

### Physical Delivery

For physically-delivered contracts, the short position must deliver the underlying asset, and the long position must accept and pay for it.

**Delivery process (example: WTI Crude Oil — CL):**

1. **First Notice Day (FND):** The first day the exchange can issue delivery notices. For CL, this is one business day before the start of the delivery month. Long holders who do not want delivery must exit before FND.
2. **Delivery notice:** The short position submits a notice indicating intent to deliver. The exchange matches the oldest long position (FIFO).
3. **Delivery period:** The delivery occurs over a specified window (for CL, the entire delivery month).
4. **Delivery location:** Cushing, Oklahoma for WTI. The contract specifies acceptable delivery points, quality specifications (API gravity, sulfur content), and pipeline/storage requirements.
5. **Final settlement:** The long pays the invoice amount (settlement price x contract size) and receives a warehouse receipt or pipeline ticket.

**Quality standards:** Contracts specify acceptable grades. For WTI: light sweet crude with 37-42 API gravity and max 0.42% sulfur. Premiums/discounts apply for grades outside the par specification.

### Cash Settlement

For cash-settled contracts, no physical delivery occurs. Instead, the final settlement price is determined by a reference index, and positions are marked-to-market one final time.

**Examples:**
- **ES (E-mini S&P 500):** Settles to the Special Opening Quotation (SOQ) of the S&P 500 on the third Friday of the contract month.
- **SOFR Futures (SR3):** Settle to 100 minus the arithmetic average of daily SOFR rates during the contract month.
- **VIX Futures:** Settle to the VIX Special Opening Quotation on expiration morning.
- **Brent Crude (ICE BRN):** Cash-settled to the ICE Brent Index (a price assessment based on physical cargoes).

### Key Dates

| Date | Description | Significance |
|---|---|---|
| **First Notice Day (FND)** | First day delivery notices can be issued | Longs must exit if they don't want delivery |
| **Last Notice Day (LND)** | Last day delivery notices can be issued | Short must have exited or delivered |
| **Last Trading Day (LTD)** | Final day the contract trades | After this, open positions go to delivery/settlement |
| **First Delivery Day** | First day physical delivery can occur | Usually 1-2 days after FND |
| **Last Delivery Day** | Last day physical delivery can occur | End of the delivery window |

**Timing warning:** For physical delivery contracts, retail traders and most institutions must exit before FND. Brokers typically auto-liquidate any remaining positions 2-3 days before FND. The April 2020 WTI negative price event (-$37.63) was partly caused by traders unable to take delivery being forced to sell at any price.

### Delivery Logistics by Asset Class

**Agricultural (ZC, ZS, ZW):**
- Delivery via warehouse receipts at exchange-approved facilities (e.g., Chicago, Toledo, St. Louis for corn and soybeans).
- Quality inspected by exchange-licensed inspectors.
- Storage charges accrue to the receipt holder.

**Metals (GC, SI):**
- Delivery via vault receipts at COMEX-approved depositories (primarily in New York metro area).
- Gold bars must meet minimum fineness of .995 and weigh 100 troy oz (+/- 5%).
- Delivery is by book-entry transfer at the depository.

**Treasury Futures (ZN, ZB):**
- Delivery of the actual bond/note via Fedwire.
- The short chooses which eligible issue to deliver (the "cheapest to deliver" or CTD bond).
- A conversion factor adjusts the invoice price based on the coupon of the delivered bond relative to the contract's notional coupon (6% for CBOT Treasury futures).
- The CTD bond is the one that minimizes: (Bond Price - Futures Price x Conversion Factor).

**Energy (CL):**
- Physical delivery at Cushing, Oklahoma via pipeline.
- Requires access to pipeline and storage facilities.
- Most commercial participants use Exchange for Physical (EFP) to arrange delivery privately rather than through the exchange process.
