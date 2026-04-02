## Best Execution Obligations

### 10.1 US Regulation: Reg NMS

**Regulation NMS (National Market System)** is the SEC's framework for equity market structure, adopted in 2005:

**Rule 611 (Order Protection Rule)**:
- Prohibits "trade-throughs": executing at a price inferior to a protected quote displayed at another trading center
- Protected quotes: automated quotes at the NBBO displayed by a trading center
- Manual quotes (e.g., NYSE specialist quotes before automation) are not protected
- Practical effect: aggressive orders must sweep all venues displaying better prices before executing at an inferior price

**Rule 610 (Access Rule)**:
- Limits access fees to $0.003 per share for orders that execute against protected quotations
- Requires fair and non-discriminatory access to quotations
- Establishes the maker-taker fee ceiling that shapes exchange fee schedules

**Rule 612 (Sub-Penny Rule)**:
- Prohibits displaying, ranking, or accepting orders in sub-penny increments for stocks priced >= $1.00
- Exception: midpoint orders in dark pools (matching, not displaying)
- Effect: minimum tick size of $0.01 for lit exchanges

**FINRA Rule 5310 (Best Execution)**:
- Requires broker-dealers to use "reasonable diligence" to determine the best market for a customer order
- Factors: execution price, order size, trading characteristics, speed, fill likelihood
- Requires regular and rigorous review of execution quality

### 10.2 EU Regulation: MiFID II

**MiFID II Best Execution (Article 27)** imposes more prescriptive requirements than US rules:

**Execution Factors** (ranked by importance for retail clients):
1. Total consideration (price + costs)
2. Speed of execution
3. Likelihood of execution and settlement
4. Size and nature of the order
5. Any other factor relevant to execution

**Best Execution Policy**:
- Investment firms must establish and publish a best execution policy
- Policy must list execution venues used and factors considered
- Annual publication of top 5 execution venues per asset class and per client category (RTS 28 reports)

**Execution Venue Monitoring**:
- Firms must monitor execution quality on an ongoing basis
- Review best execution arrangements at least annually
- Must be able to demonstrate best execution to regulators on demand

**RTS 28 (Top 5 Execution Venues Report)**:
- Annual publication listing the top 5 venues by execution volume for each asset class
- Broken down by client type (retail, professional) and order type (passive, aggressive, directed)
- Includes information on payment for order flow (PFOF) arrangements
- Publicly available on the firm's website

**RTS 27 (Execution Quality Reports)**:
- Execution venues publish quarterly reports on execution quality
- Metrics: fill rates, spread, speed, cost
- Intended to help investment firms compare venues

### 10.3 Best Execution Policy Implementation

A best execution policy typically includes:

1. **Venue selection criteria**: methodology for selecting and ranking execution venues
2. **Venue review process**: regular assessment of execution quality by venue, with escalation procedures for underperforming venues
3. **Algorithm selection framework**: criteria for choosing between algorithms and DMA
4. **Monitoring framework**: real-time monitoring triggers and post-trade TCA
5. **Conflicts of interest**: disclosure and management of conflicts (e.g., routing to affiliated venues, PFOF)
6. **Client consent**: obtaining client consent for the best execution policy and any material changes
7. **Record keeping**: retention of execution data for regulatory examination

### 10.4 Regulatory Reporting

| Requirement | Jurisdiction | Content |
|------------|-------------|---------|
| Rule 606 (Order Routing Report) | US (SEC) | Quarterly report on order routing practices, including PFOF |
| RTS 28 (Top 5 Venues) | EU | Annual report on top 5 execution venues |
| RTS 27 (Execution Quality) | EU | Quarterly venue-level execution quality |
| CAT (Consolidated Audit Trail) | US (SEC/FINRA) | Order lifecycle reporting for regulatory surveillance |
| Transaction Reporting (MiFIR Art. 26) | EU | T+1 transaction reports to national regulators |
| Trade Reporting (MiFIR Art. 20-21) | EU | Real-time trade reporting to APAs (Approved Publication Arrangements) |
