## 2. Trade Surveillance

Trade surveillance systems monitor order flow and trading activity in real time and historically to detect potential market abuse. These systems operate on both real-time streaming data and batch analysis of historical patterns.

### 2.1 Market Manipulation Detection

Market manipulation encompasses a broad range of behaviors intended to artificially influence the price, supply, or demand for a security. Under MAR Article 12 and Dodd-Frank Section 747, firms must have systems to detect and report suspected manipulation.

**Common patterns detected:**

- **Marking the close / Marking the open:** Placing orders near market close or open to influence settlement or reference prices. Detected by analyzing order placement timing relative to auction periods and their impact on closing/opening prices.
- **Painting the tape:** Executing a series of transactions that are reported publicly to give the impression of active trading. Detected through unusual volume spikes in low-liquidity securities correlated with limited counterparty diversity.
- **Pump and dump / Trash and cash:** Building a position, disseminating misleading positive (or negative) information, then unwinding at an artificial price. Detected by correlating trading patterns with communication analysis and social media monitoring.
- **Cornering / Squeezing:** Acquiring a dominant position in a security to control supply and force short sellers to cover at inflated prices. Detected through position concentration analysis.
- **Ramping:** Placing aggressive orders to move the price in a desired direction before a large trade, then canceling the aggressive orders. Overlaps with spoofing detection.

### 2.2 Spoofing and Layering Detection

Spoofing (placing orders with the intent to cancel before execution) and layering (placing multiple orders at different price levels to create false depth) are prohibited under Dodd-Frank Section 747 and MAR Article 12(1)(a).

**Detection methodology:**

- **Order-to-trade ratio analysis:** Abnormally high ratios of orders placed to orders filled, measured by trader, by security, and by time period. Thresholds are typically calibrated per venue and asset class.
- **Cancel-to-fill ratio:** Tracking the percentage of orders canceled versus filled. Ratios above a configurable threshold (e.g., 90%+) trigger alerts.
- **Temporal analysis:** Identifying orders placed and canceled within very short time windows (sub-second to seconds), particularly when the cancellation follows an execution on the opposite side.
- **Order book depth analysis:** Detecting non-bona-fide orders placed at multiple price levels on one side of the book that are removed after a fill on the opposite side.
- **Flipping detection:** Identifying rapid alternation between buy and sell sides, where orders on one side are consistently canceled after the other side executes.
- **Machine learning models:** Supervised models trained on confirmed spoofing cases and regulator-flagged patterns, using features such as order duration, distance from best bid/offer, volume relative to average, and subsequent price impact.

**Alert workflow:**

1. Real-time detection engine generates an alert with severity scoring.
2. Alert is enriched with order book context, trader history, and related alerts.
3. Compliance analyst reviews the alert in a case management interface.
4. Analyst dispositions the alert: escalate, close with rationale, or request further investigation.
5. Escalated alerts enter a formal investigation workflow and may result in a SAR (Suspicious Activity Report) or STR (Suspicious Transaction Report) filing.

### 2.3 Wash Trading Detection

Wash trading involves executing trades where there is no genuine change of beneficial ownership, creating misleading appearance of market activity. Prohibited under CEA Section 4c(a) and MAR.

**Detection approaches:**

- **Same-account matching:** Identifying cases where the same account (or accounts under common control) appears on both sides of a trade.
- **Beneficial ownership analysis:** Resolving trades to ultimate beneficial owners to detect wash trades across different accounts controlled by the same entity.
- **Pre-arranged trading patterns:** Detecting trades between accounts that exhibit suspiciously precise matching in timing, price, and quantity.
- **Cross-venue wash trading:** Monitoring for offsetting trades across different venues that net to zero position change.
- **Volume inflation:** Statistical analysis to identify securities where reported volume significantly exceeds genuine changes in beneficial ownership.

### 2.4 Front-Running Detection

Front-running occurs when a firm or individual trades ahead of a client order to profit from the expected price impact. Prohibited under MiFID II Article 25(1) and SEC common law principles.

**Detection methodology:**

- **Temporal correlation:** Analyzing the timing of proprietary or personal trades relative to large client orders in the same security. A pattern of proprietary buys preceding large client buy orders is indicative.
- **Information barrier monitoring:** Detecting leakage of client order information across information barriers by correlating trading activity with order receipt.
- **Communication analysis:** Cross-referencing trading timestamps with communication records (chat, voice, email) to detect information sharing preceding proprietary trades.
- **Statistical patterns:** Building baseline models of expected proprietary trading behavior and flagging statistically significant deviations that correlate with subsequent client order flow.
- **Reverse front-running:** Detecting cases where a trader delays or resequences client orders to benefit from anticipated market movements.

### 2.5 Cross-Trading Monitoring

Cross trades (trades between accounts managed by the same firm) are permitted in some circumstances but heavily regulated to prevent conflicts of interest.

**Controls:**

- **Price fairness validation:** Cross trades must be executed at a fair market price, typically the midpoint of the NBBO (National Best Bid and Offer) or the current market price.
- **Client consent verification:** Both sides of the cross trade must have consented to cross-trading, either through investment management agreements or specific consent.
- **Regulatory compliance by jurisdiction:** SEC Rule 17a-7 (for investment companies), ERISA Section 406 (for pension funds), and MiFID II Article 23 (for systematic internalisers) each impose different requirements.
- **Audit trail:** Complete documentation of the rationale for the cross, the pricing methodology, and confirmation that both accounts benefited or were not disadvantaged.
- **Aggregate cross-trade monitoring:** Identifying patterns where one account consistently loses on cross trades with another, which may indicate favoritism.
