## 4. Best Execution Monitoring and Reporting

Best execution is the obligation to take sufficient steps to obtain the best possible result for clients when executing orders, taking into account price, costs, speed, likelihood of execution, settlement, size, nature, and any other relevant consideration.

### 4.1 Execution Quality Statistics

Trading desk applications maintain comprehensive execution quality metrics:

- **Price improvement:** Percentage of orders receiving a price better than the prevailing quote at time of receipt. Measured in basis points of improvement and as a percentage of order flow.
- **Effective spread vs. quoted spread:** The effective spread (2 * |execution price - midpoint at time of order|) compared to the prevailing quoted spread.
- **Implementation shortfall (IS):** The difference between the paper portfolio return (using decision price) and the actual portfolio return after all trading costs. Decomposed into:
  - Delay cost (market movement between decision and order release)
  - Market impact (price movement due to the order itself)
  - Timing cost (intraday price movement during execution)
  - Opportunity cost (unfilled portion of the order)
- **VWAP slippage:** Execution price vs. volume-weighted average price over the relevant benchmark period.
- **Fill rates:** Percentage of orders fully filled, partially filled, and unfilled, segmented by order type, size, and venue.
- **Latency metrics:** Order submission to acknowledgment, order to first fill, and order to complete fill.
- **Reversion analysis:** Post-trade price movement (5-second, 1-minute, 5-minute, 30-minute) to assess information leakage and market impact.

### 4.2 Venue Analysis

- **Venue-by-venue comparison:** Fill rates, average execution prices, spreads, and latency across all connected venues (exchanges, dark pools, systematic internalisers, market makers).
- **Toxicity analysis:** Measuring adverse selection by venue — some venues have higher rates of trades that are immediately followed by price moves against the order.
- **Venue tiering:** Classifying venues by execution quality for different order types and sizes to inform smart order routing (SOR) logic.
- **Dark pool analysis:** Comparing dark pool execution quality (midpoint fills, fill rates, information leakage) with lit venue alternatives.
- **Internalization monitoring:** Tracking when the firm internalizes client orders and comparing execution quality against external venues.

### 4.3 RTS 27 and RTS 28 Reports (MiFID II)

**RTS 28 (now the active requirement after RTS 27 was suspended):**

- Investment firms must publish annually a report identifying the top five execution venues by trading volume for each class of financial instrument, separately for retail and professional clients.
- The report must include the percentage of orders executed at each venue, the percentage of passive vs. aggressive orders, and the percentage of directed orders.
- Firms must disclose payment for order flow arrangements, close links with venues, and conflicts of interest.
- The report must cover executed client orders and securities financing transactions.

**RTS 27 (suspended by European Commission until further notice, originally required):**

- Execution venues were required to publish quarterly execution quality data including: prices and costs, speed and likelihood of execution, at a per-instrument level.
- Data was to be published in machine-readable format to enable comparison across venues.
- Although suspended in the EU, the transparency objectives behind RTS 27 continue to influence best execution monitoring practices.

**Best execution policy requirements (MiFID II Article 27):**

- Firms must establish, implement, and maintain a best execution policy that specifies the relative importance of execution factors for each asset class.
- The policy must identify the venues the firm relies on and the criteria for selecting between them.
- Regular monitoring (at minimum quarterly) of execution quality obtained, with adjustments to venue selection and routing logic as needed.
- Annual best execution report to clients summarizing monitoring results and any material changes.
