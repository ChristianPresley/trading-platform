## Execution Quality Measurement (TCA)

### 6.1 Overview

Transaction Cost Analysis (TCA) measures the quality of trade execution by comparing actual execution prices to various benchmarks. TCA is both a compliance requirement (MiFID II best execution reporting) and a tool for optimizing execution strategy.

### 6.2 Cost Components

**Explicit Costs**:
- Commission: broker commission per share or per order
- Exchange fees: maker/taker fees, clearing fees
- Taxes: stamp duty (UK), financial transaction tax (EU jurisdictions)
- Clearing and settlement fees

**Implicit Costs** (the primary focus of TCA):

| Cost Component | Definition | Calculation |
|----------------|------------|-------------|
| **Spread Cost** | Cost of crossing the bid-ask spread | (Execution Price - Midpoint at Execution) / Midpoint |
| **Market Impact** | Price move caused by the order itself | Typically modeled as the difference between execution price and a "no-trade" counterfactual |
| **Timing Cost** | Cost due to market movement between decision time and execution time | (VWAP during execution - Arrival Price) / Arrival Price |
| **Opportunity Cost** | Cost of not completing the order | (Close Price - Arrival Price) x Unfilled Quantity / Total Quantity |
| **Delay Cost** | Cost of delay between decision and order submission | (Price at Submission - Price at Decision) / Price at Decision |

### 6.3 Benchmarks

| Benchmark | Definition | Use Case |
|-----------|------------|----------|
| **Arrival Price** | Midpoint of NBBO at the time the order reaches the broker | Most popular benchmark for IS algorithms |
| **VWAP** | Volume-weighted average price over the execution window | Standard for VWAP algorithms |
| **TWAP** | Time-weighted average price over the execution window | Standard for TWAP algorithms |
| **Close** | Official closing price | Standard for MOC orders and index-tracking funds |
| **Open** | Official opening price | Less common; used for MOO orders |
| **Previous Close** | Prior day's closing price | Used for overnight/decision-time analysis |
| **Interval VWAP** | VWAP over a specific sub-interval | Useful for partial-day execution windows |

### 6.4 Implementation Shortfall Decomposition

The implementation shortfall framework, originally proposed by Andre Perold (1988), decomposes total execution cost into its components. The standard decomposition:

**Total Implementation Shortfall** = Paper Portfolio Return - Actual Portfolio Return

Decomposed as:

```
Total IS = Delay Cost + Trading Cost + Opportunity Cost

Where:
  Delay Cost = (Benchmark Price at Execution Start - Decision Price) x Total Shares
  Trading Cost = (Average Execution Price - Benchmark Price at Execution Start) x Filled Shares
  Opportunity Cost = (Close Price - Decision Price) x Unfilled Shares
```

More granular decomposition:

```
Trading Cost = Market Impact + Timing Cost + Spread Cost

Where:
  Market Impact = Permanent + Temporary impact (separated via regression models)
  Timing Cost = Market drift during execution (beta-adjusted)
  Spread Cost = Half-spread at time of each fill
```

### 6.5 TCA Metrics

**Per-Order Metrics**:
| Metric | Calculation |
|--------|-------------|
| Arrival Slippage (bps) | (Avg Exec Price - Arrival Price) / Arrival Price x 10,000 |
| VWAP Slippage (bps) | (Avg Exec Price - Interval VWAP) / Interval VWAP x 10,000 |
| Spread Capture | 1 - (Avg Exec Price - Midpoint) / Half-Spread |
| Fill Rate | Filled Quantity / Total Quantity |
| Participation Rate | Filled Quantity / Market Volume during execution |
| Time to Fill | Duration from order start to complete fill |

**Aggregate / Portfolio-Level Metrics**:
| Metric | Description |
|--------|-------------|
| Volume-Weighted Slippage | Slippage weighted by order notional value |
| Alpha Capture | Portion of expected alpha preserved after execution costs |
| Effective Spread | 2 x |Exec Price - Midpoint| at time of execution |
| Realized Spread | 2 x Side x (Exec Price - Midpoint after T seconds) — measures adverse selection |
| Reversion | Price reversion after a fill — indicates temporary vs. permanent impact |

### 6.6 TCA Reporting

**Pre-Trade TCA**:
- Cost estimate before execution begins
- Uses impact models to predict expected cost for different algorithm choices and parameter settings
- Enables algorithm selection: "If you use VWAP over 2 hours, expected cost is 8 bps; if you use IS Aggressive, expected cost is 12 bps but with lower risk"

**Real-Time / Intra-Trade TCA**:
- Monitors execution cost vs. benchmark in real time during execution
- Alerts if slippage exceeds threshold (e.g., more than 20 bps behind arrival price)
- Enables mid-execution intervention (cancel, change urgency, switch algorithm)

**Post-Trade TCA**:
- Comprehensive analysis after execution is complete
- Compares actual execution against multiple benchmarks
- Breaks down costs by time period, venue, order size, algorithm, and other dimensions
- Used for broker evaluation, algorithm selection, and regulatory reporting

**Peer Comparison**:
- Compares a firm's execution quality against an anonymous peer group
- TCA vendors (e.g., Abel Noser, ITG/Virtu, Bloomberg BTCA, Liquidmetrix) maintain peer databases
- Metrics: "Your large-cap buy orders averaged 3.2 bps vs. arrival; peer median is 4.1 bps"
