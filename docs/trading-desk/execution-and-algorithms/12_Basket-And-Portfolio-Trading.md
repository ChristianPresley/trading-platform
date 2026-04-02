## Basket and Portfolio Trading

### 11.1 Overview

Basket trading involves executing a list of orders (potentially hundreds or thousands) simultaneously, coordinating execution across all names to achieve portfolio-level objectives.

### 11.2 List Trading

The simplest form: a list of individual orders submitted together for execution. Each order is independent but managed as a group for monitoring and reporting.

**Workflow**:
1. Portfolio manager generates a trade list (from portfolio construction / optimization system)
2. Trade list imported into OMS/EMS (via FIX List Order, CSV, or API)
3. Trader reviews the list, assigns algorithms and parameters (possibly in bulk)
4. Execution begins; trader monitors aggregate progress
5. Post-trade: aggregate TCA across the entire list

**Bulk Algorithm Assignment**:
- Apply the same algorithm to all orders (e.g., "VWAP 10:00-15:00" for all)
- Rule-based assignment: liquid names get IS algorithm, illiquid names get TWAP
- ADV-based: orders > 20% ADV get more passive treatment; orders < 5% ADV get aggressive treatment

### 11.3 Program Trading

Coordinated execution of a basket where the portfolio-level outcome matters more than individual order execution quality.

**Principal Program Trade**:
- The broker guarantees execution of the entire basket at a specified price (e.g., previous close, today's VWAP)
- The broker assumes market risk and earns a risk premium (bid-ask spread on the basket)
- Pricing: typically quoted as a spread (e.g., "we'll buy the basket at VWAP minus 3 bps")
- Used when the client wants certainty of execution and is willing to pay for risk transfer

**Agency Program Trade**:
- The broker executes the basket as agent, passing through the actual execution prices
- Lower cost (commission only, no risk premium) but the client bears market risk
- Algorithm selection and monitoring are critical

**Risk / Guaranteed Program Trade**:
- Hybrid: broker commits to a minimum fill rate and execution quality, taking partial risk
- Pricing reflects the risk the broker assumes

### 11.4 Index Rebalancing

When an index changes composition (quarterly rebalance, corporate actions), index-tracking funds must trade to match the new composition.

**Rebalance Characteristics**:
- Known well in advance (index providers announce changes days or weeks ahead)
- Large, coordinated, one-directional flow across many names simultaneously
- Concentrated at the close (index-tracking funds benchmark to closing prices)
- Creates predictable demand/supply imbalances

**Execution Considerations**:
- MOC orders for names being added to or removed from the index
- Pre-close trading to reduce closing auction risk for large orders
- Cross-trading between index funds within the same asset manager (when one fund is buying and another is selling the same stock)
- Careful management of tracking error: deviations from the index weight must be minimized

**Index Reconstitution Events**:
- Russell reconstitution (late June): largest annual index rebalance event, massive volume in affected names
- S&P 500 additions/deletions: event-driven, significant price impact around announcement and effective dates
- MSCI rebalances: global equity index changes, affect cross-border capital flows

### 11.5 Transition Management

The wholesale restructuring of a portfolio, typically when:
- Changing investment managers (firing/hiring)
- Restructuring asset allocation (e.g., moving from active to passive, or between asset classes)
- Fund mergers or liquidations

**Transition Manager Role**:
- Specialized broker-dealers that manage large-scale portfolio transitions
- Objective: minimize total cost (market impact + opportunity cost + explicit cost) and risk during the transition
- Manage the "legacy portfolio" (what you have) to "target portfolio" (what you want) transformation

**Transition Cost Components**:
- Explicit costs: commissions, taxes, fees
- Market impact: the cost of trading large quantities across many names
- Opportunity cost: the cost of being out of the target portfolio during the transition
- Tracking error: deviation from the target benchmark during transition

**Execution Approach**:
1. **Crossing**: Identify overlapping positions between legacy and target portfolios; these require no market execution
2. **Netting**: Within the trade list, buy orders and sell orders in the same name net against each other
3. **In-kind transfer**: Where possible, transfer securities between accounts without market execution
4. **Market execution**: Residual trades that must be executed in the market
5. **Risk management**: During the transition, use futures or ETFs to maintain market exposure and minimize tracking error

**Transition Analytics**:
- Pre-transition cost estimate: model expected costs under different scenarios (all-at-once, 2-day, 5-day)
- Real-time monitoring: track actual vs. expected costs, market exposure, and tracking error
- Post-transition report: comprehensive TCA comparing actual costs to estimates and benchmarks
- T-Standard (Transition Management Association of Canada): industry standard for measuring and reporting transition costs

### 11.6 Basket Risk Management

**Net Exposure Monitoring**:
- Track aggregate long/short exposure as the basket executes
- If the basket is a rebalance (buys and sells), manage the sequence to keep net market exposure close to neutral
- Example: execute sells of stocks you are underweighting simultaneously with buys of stocks you are overweighting

**Sector / Factor Exposure**:
- Monitor unintended sector or factor tilts during execution
- If all sell orders complete before buy orders, the portfolio may be temporarily underweight the market
- Interleave buys and sells to maintain factor neutrality during execution

**Cash Management**:
- Track cash position throughout execution
- Avoid becoming unintentionally long or short cash
- Coordinate with settlement timing (T+1 in US equities since May 2024)
