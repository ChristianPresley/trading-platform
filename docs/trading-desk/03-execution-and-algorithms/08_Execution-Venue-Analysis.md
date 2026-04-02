## Execution Venue Analysis

### 7.1 Fill Rate Analysis

Fill rate measures the probability that an order routed to a venue will receive a fill. Key dimensions:

| Dimension | Description |
|-----------|-------------|
| **Unconditional Fill Rate** | % of orders routed to a venue that receive any fill |
| **Size Fill Rate** | Average fill size / order size — measures how much of the order is filled |
| **Time to Fill** | Average time between order arrival and first fill |
| **Dark Pool Hit Rate** | For dark pools: % of pings/IOC orders that result in a fill |

### 7.2 Adverse Selection

Adverse selection measures how much the price moves against a fill after execution. A venue with high adverse selection tends to fill orders just before the price moves unfavorably — indicating that the contra-side had superior information.

**Measurement**:
```
Adverse Selection (T) = Side x (Midpoint at T seconds after fill - Midpoint at fill) / Midpoint at fill

Where Side = +1 for buys, -1 for sells
T = measurement horizon (e.g., 1 second, 10 seconds, 1 minute, 5 minutes)
```

A positive value indicates adverse selection (price moved against the fill recipient).

**Venue Comparison**:
- Lit exchanges with co-located HFT participants typically show higher adverse selection (HFT firms are fast to take liquidity when they detect a price move)
- Dark pools vary: some have high adverse selection (toxic flow), others have low adverse selection (natural institutional flow)
- IEX's speed bump is designed to reduce adverse selection for passive orders

### 7.3 Information Leakage

Information leakage occurs when the market price moves in the direction of the order before execution is complete, suggesting that market participants have detected the order's presence.

**Detection**:
- Compare price trajectory during execution against a no-trade counterfactual (e.g., sector return, beta-adjusted market return)
- Significant residual price movement in the direction of the order suggests leakage
- Compare fill rates at the beginning vs. end of execution: declining fill rates suggest other participants are pulling liquidity

**Sources of Leakage**:
- Dark pool pinging by HFT firms: detecting hidden orders by sending small probing orders
- IOI distribution: some dark pools share IOI information broadly
- Venue data feeds: some venues sell data about aggregate order flow
- Pattern detection: HFT algorithms that detect algorithmic order patterns (e.g., VWAP schedule, iceberg replenishment)

### 7.4 Venue Toxicity Metrics

**VPIN (Volume-Synchronized Probability of Informed Trading)**:
- Measures the probability that trading activity is driven by informed traders
- Calculated as the absolute difference between buy and sell volume, normalized by total volume, over volume buckets
- High VPIN indicates toxic (informed) flow

**Spread Decomposition**:
- Decompose the bid-ask spread into adverse selection, inventory, and order processing components
- Venues where the adverse selection component is large attract informed flow

**Queue Jumping / Phantom Liquidity**:
- Measure how often displayed quotes at a venue disappear before an incoming order can fill them
- High phantom liquidity indicates that the venue's displayed depth is unreliable

### 7.5 Venue Scoring Model

A comprehensive venue scoring model combines multiple factors:

```
VenueScore = w1 * FillRate
           + w2 * (1 - AdverseSelection)
           + w3 * PriceImprovement
           + w4 * (1 - FeePerShare)
           + w5 * (1 - Latency)
           + w6 * (1 - InformationLeakage)
           - w7 * RejectRate
```

Weights are calibrated per instrument type, order size, and strategy. The SOR uses venue scores to prioritize routing decisions.
