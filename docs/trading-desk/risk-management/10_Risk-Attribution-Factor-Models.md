## 10. Risk Attribution and Decomposition

### Factor-Based Risk Models

Factor models decompose portfolio risk into systematic factors and idiosyncratic (stock-specific) risk:

```
Return_i = alpha_i + sum_k (Beta_ik * Factor_k) + epsilon_i

Where:
  Return_i = return of asset i
  alpha_i = stock-specific expected return
  Beta_ik = exposure (loading) of asset i to factor k
  Factor_k = return of factor k
  epsilon_i = idiosyncratic return (uncorrelated across assets)
```

**Portfolio variance decomposition:**

```
Var(R_p) = w' * B * F * B' * w + w' * D * w

Where:
  w = vector of portfolio weights
  B = matrix of factor exposures (N assets x K factors)
  F = K x K factor covariance matrix
  D = N x N diagonal matrix of specific variances (idiosyncratic risk)

Systematic Risk = w' * B * F * B' * w
Idiosyncratic Risk = w' * D * w
Total Risk = Systematic Risk + Idiosyncratic Risk
```

### Common Risk Factor Taxonomies

#### Barra / MSCI Factor Model

```
Style Factors:
  - Value (book-to-price, earnings yield, dividend yield)
  - Growth (earnings growth, sales growth)
  - Momentum (12-month return minus 1-month return)
  - Size (log market cap)
  - Volatility (historical and predicted beta, daily return vol)
  - Leverage (debt-to-equity, book leverage)
  - Liquidity (share turnover, trading volume)
  - Quality (ROE, earnings stability, balance sheet accruals)

Industry/Sector Factors:
  - GICS Level 2 (24 Industry Groups) or Level 3 (69 Industries)

Country Factors:
  - Country of domicile or country of risk

Currency Factors:
  - Currency denomination of asset
```

#### Fixed Income Factor Model

```
Factors:
  - Level (parallel shift in yield curve)
  - Slope (steepening/flattening: 2s10s spread)
  - Curvature (butterfly: 2s vs 5s vs 10s)
  - Credit spread (IG, HY, by rating)
  - Sector spread (financials, industrials, utilities, etc.)
  - Liquidity premium
  - Inflation expectations (breakeven inflation rate)
  - Prepayment factor (MBS-specific)
```

### Sector Risk Decomposition

```
Portfolio Risk by GICS Sector:

Sector              Weight   Beta   Contrib to VaR   % of Total VaR
Technology          28%      1.25   $3.2M            32%
Financials          18%      1.10   $1.8M            18%
Healthcare          15%      0.85   $1.1M            11%
Consumer Disc.      12%      1.20   $1.4M            14%
Industrials         10%      1.05   $0.9M            9%
Energy               8%      1.30   $1.0M            10%
Other                9%      0.90   $0.6M            6%
                   -----                             -----
Total              100%              $10.0M           100%

Note: Contributions sum to total due to correlation effects.
The contribution-to-VaR calculation accounts for inter-sector correlations.
```

### Country/Geography Risk Decomposition

```
Risk by Country of Risk:

Country          Weight   Contrib to VaR   % of Total VaR   Country VaR
US               55%      $4.5M            45%              $8.2M
UK               12%      $1.3M            13%              $1.9M
Japan            10%      $0.8M            8%               $1.5M
Germany           8%      $0.9M            9%               $1.4M
China             5%      $1.2M            12%              $3.0M
Brazil            3%      $0.8M            8%               $2.8M
Other             7%      $0.5M            5%               $1.0M
                 -----    ------           -----
Total           100%      $10.0M           100%
```

### Style/Factor Risk Decomposition

```
Factor Risk Decomposition:

Factor          Exposure   Factor Vol   Contrib to Risk   % of Systematic
Market          1.05       15.0%        $5.2M             52%
Value          -0.30       4.5%         $0.8M             8%
Momentum        0.45       5.2%         $1.1M             11%
Size           -0.15       3.8%         $0.4M             4%
Volatility      0.20       6.1%         $0.7M             7%
Quality         0.35       3.2%         $0.5M             5%
Sector effects  ---        ---          $0.8M             8%
Currency        ---        ---          $0.5M             5%
                                        ------            -----
Systematic Risk                         $10.0M            100%
Idiosyncratic Risk                      $3.2M
                                        ------
Total Risk                              $13.2M
```
