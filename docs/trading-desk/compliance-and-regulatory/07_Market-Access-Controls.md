## 7. Market Access Controls

### 7.1 SEC Rule 15c3-5 (Market Access Rule)

SEC Rule 15c3-5 requires broker-dealers with market access (or that provide market access to others) to establish, document, and maintain a system of risk management controls and supervisory procedures that are reasonably designed to manage the financial, regulatory, and other risks of market access.

**Required controls:**

- **Pre-trade financial risk controls:**
  - Credit/capital thresholds: hard limits on the aggregate financial exposure from orders routed to the market, by customer, trading desk, and firmwide.
  - Single order size limits (preventing "fat finger" errors).
  - Order price reasonability checks (rejecting orders priced significantly away from the current market).
  - Position concentration limits (preventing excessive accumulation in a single security).
  - Aggregate notional/exposure limits per trader, desk, account, and firm.

- **Pre-trade regulatory risk controls:**
  - Restricted list checks (as described in Section 1.1).
  - Short sale compliance (locate verification, SSR enforcement).
  - Regulation NMS compliance (order protection rule / trade-through prevention).
  - LULD (Limit Up-Limit Down) price band enforcement.

- **Post-trade controls:**
  - Real-time position monitoring.
  - P&L monitoring with alert thresholds.
  - Intraday exposure reports.

**Key requirements:**

- Controls must be under the exclusive control of the broker-dealer providing market access (they cannot be outsourced to or controlled by the customer).
- Controls must prevent the entry of orders that exceed pre-set credit or capital thresholds.
- The system must be subject to regular review (at minimum annually) and the CEO must certify compliance.
- Direct market access (DMA) and sponsored access customers require the same level of controls as if the broker-dealer were entering the orders itself.

### 7.2 Pre-Trade Risk Controls (General)

Beyond SEC Rule 15c3-5, pre-trade risk controls are standard practice and increasingly mandated globally:

- **Kill switch / emergency halt:** The ability to immediately cancel all open orders and halt new order entry for a specific trader, algorithm, account, or the entire firm. Must be operable by risk management independently of the trading desk.
- **Rate limiters (message throttles):** Preventing excessive order submission rates that could overwhelm exchanges or trigger exchange-imposed throttles.
- **Duplicative order detection:** Identifying and preventing the same order from being submitted multiple times due to system glitches.
- **Self-trade prevention (STP):** Controls to prevent the firm from inadvertently trading with itself across different accounts or strategies. Exchanges typically offer STP mechanisms (cancel newest, cancel oldest, cancel both, decrement).
- **Algorithm-specific limits:** Individual risk limits per algorithm, including maximum order size, maximum participation rate, maximum position, and maximum loss.

### 7.3 Erroneous Trade Prevention

- **Price collars:** Rejecting orders priced more than a configurable percentage away from the NBBO or last trade price. Thresholds typically vary by security price (e.g., 5% for stocks over $25, 10% for stocks $3-$25, 20% for stocks under $3).
- **LULD compliance:** During Limit Up-Limit Down bands, orders that would execute outside the price bands are handled according to exchange rules (typically held or rejected, not executed).
- **Clearly erroneous execution (CEE) policies:** Exchanges have rules (e.g., NYSE Rule 128, Nasdaq Rule 11890) that allow trades to be broken or adjusted if they occur at prices substantially away from the prevailing market. Firms should have internal procedures for requesting CEE review.
- **Fat finger protection:** Maximum order size and notional limits to prevent data entry errors from reaching the market.
