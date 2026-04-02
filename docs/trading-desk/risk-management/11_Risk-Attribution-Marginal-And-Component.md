### Marginal and Component Risk

#### Marginal VaR

The change in portfolio VaR from a small increase in a position:

```
Marginal VaR_i = dVaR / dw_i

For parametric VaR:
  Marginal VaR_i = z_alpha * (Sigma * w)_i / sigma_p

Where:
  (Sigma * w)_i = row i of the covariance matrix times the weight vector
  sigma_p = portfolio standard deviation
```

Marginal VaR tells you which position to add to (or reduce) to most efficiently change portfolio risk.

#### Component VaR

The contribution of each position to total portfolio VaR:

```
Component VaR_i = w_i * Marginal VaR_i

Property: sum of all Component VaRs = Total VaR
  sum_i (CVaR_i) = VaR_portfolio
```

This is the standard tool for risk budgeting: allocating total risk to individual positions.

```
Example:
Position    Weight   Marginal VaR   Component VaR   % Contribution
AAPL        15%      $0.82M         $1.23M          12.3%
MSFT        12%      $0.75M         $0.90M          9.0%
GOOGL       10%      $0.88M         $0.88M          8.8%
SPY Hedge   -20%     -$0.65M        $1.30M          13.0%
Bonds       30%      $0.15M         $0.45M          4.5%
...         ...      ...            ...             ...
                                    -------         -----
Total                               $10.0M          100%
```

#### Incremental VaR

The change in portfolio VaR from adding (or removing) an entire position:

```
Incremental VaR = VaR(portfolio with position) - VaR(portfolio without position)
```

Unlike marginal VaR (infinitesimal change), incremental VaR captures the full non-linear impact.

### Risk Attribution Over Time

Risk attribution can also be performed across time to explain changes in portfolio risk:

```
VaR Change Attribution (Day over Day):

VaR(T-1) = $9.2M
VaR(T)   = $10.5M
Change   = +$1.3M

Attribution:
  New trades:               +$0.4M (added long equity positions)
  Position changes:         +$0.2M (didn't rebalance hedge)
  Volatility changes:       +$0.5M (realized vol increased)
  Correlation changes:      +$0.3M (correlations moved toward 1)
  Methodology/model change: -$0.1M (recalibrated vol surface)
                            ------
  Total explained:          +$1.3M
```

### Risk Reporting Hierarchy

```
Board Risk Committee
  ├── Enterprise Risk Report (monthly)
  │     - Firmwide VaR, ES, stress test results
  │     - Capital adequacy ratios
  │     - Limit utilization summary
  │     - Top 10 risk concentrations
  │     - Backtesting results
  │
  ├── CRO Daily Risk Report
  │     - All desk VaR and limit utilization
  │     - Breach summary
  │     - Stress test P&L by desk
  │     - Counterparty exposure summary
  │
  ├── Desk Head Report (real-time + daily)
  │     - Desk VaR, Greeks, P&L
  │     - Position detail with limits
  │     - Trader-level attribution
  │     - Scenario P&L
  │
  └── Trader Dashboard (real-time)
        - Position-level P&L
        - Greeks for each position
        - Limit utilization (personal)
        - Market data
```

---
