## Appendix A: VaR Backtesting

Backtesting validates VaR model accuracy by comparing predicted VaR to actual P&L:

```
For each day t:
  If ActualLoss(t) > VaR(t):  count as an "exception"

Expected exceptions at 99% confidence over 250 days: 2.5

Basel Traffic Light System:
  Green zone:  0-4 exceptions  (no penalty)
  Yellow zone: 5-9 exceptions  (multiplier increased 0.4-0.85)
  Red zone:    10+ exceptions  (multiplier = 1.0 penalty; model review required)
```

Formal statistical tests:

**Kupiec POF Test:**
```
LR_POF = -2 * ln[(1-p)^(N-x) * p^x] + 2 * ln[(1-x/N)^(N-x) * (x/N)^x]

Where:
  p = expected exception rate (e.g., 0.01 for 99% VaR)
  N = number of observations
  x = number of exceptions

LR_POF ~ chi-squared(1) under H0
```

**Christoffersen Independence Test:**
Tests whether exceptions are independently distributed (not clustered).

## Appendix B: Key Formulas Reference

| Measure | Formula |
|---|---|
| Parametric VaR | `z * sigma_p * sqrt(T)` |
| Expected Shortfall | `E[Loss \| Loss > VaR]` |
| Delta | `dV/dS` or `N(d1)` for BS |
| Gamma | `d^2V/dS^2` |
| Vega | `dV/d(sigma)` |
| Theta | `dV/dT` |
| DV01 | `ModDuration * Price * 0.0001` |
| CS01 | `SpreadDuration * Price * 0.0001` |
| Component VaR | `w_i * dVaR/dw_i` |
| CVA | `(1-R) * integral[DF(t) * EPE(t) * dPD(t)]` |
| SIMM IM | `sqrt(sum[IM_rc^2] + 2*sum[psi*IM_rc1*IM_rc2])` |
| Market Impact | `sigma * sqrt(Q/V) * k` |
| LVaR | `VaR * sqrt(LiqHorizon) + LiquidationCost` |
| Portfolio Beta | `sum(w_i * Beta_i)` |
| HHI | `sum(w_i^2)` |
