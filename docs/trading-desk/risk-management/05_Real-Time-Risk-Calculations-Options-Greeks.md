## 6. Real-Time Risk Calculations

### Options Greeks

The Greeks measure the sensitivity of an option's price to various factors. Professional systems compute these in real-time for every option position.

#### Delta

Rate of change of option price with respect to underlying price:

```
Delta = dV / dS

Call delta: 0 to +1 (typically expressed as 0 to 100)
Put delta:  -1 to 0 (typically expressed as -100 to 0)

Black-Scholes:
  Call Delta = N(d1)
  Put Delta = N(d1) - 1

Where:
  d1 = [ln(S/K) + (r - q + sigma^2/2) * T] / (sigma * sqrt(T))
  N() = cumulative standard normal distribution
  S = spot price
  K = strike price
  r = risk-free rate
  q = dividend yield
  sigma = implied volatility
  T = time to expiration (in years)
```

**Portfolio delta** (delta-equivalent exposure):
```
PortfolioDelta = sum_i (Delta_i * Quantity_i * Multiplier_i * SpotPrice_i)
```

This expresses the option portfolio as an equivalent position in the underlying.

#### Gamma

Rate of change of delta with respect to underlying price (second derivative):

```
Gamma = d^2V / dS^2 = dDelta / dS

Black-Scholes:
  Gamma = N'(d1) / (S * sigma * sqrt(T))

Where N'(x) = (1/sqrt(2*pi)) * exp(-x^2/2)  [standard normal PDF]
```

Gamma is highest for at-the-money options near expiration. Dollar gamma:
```
DollarGamma = 0.5 * Gamma * (SpotPrice)^2 * Quantity * Multiplier / 100
```

This represents the P&L from a 1% move in the underlying (approximately).

**Gamma P&L** for a delta-hedged portfolio:
```
GammaPnL = 0.5 * Gamma * (dS)^2 * Quantity * Multiplier
```

#### Vega

Sensitivity of option price to implied volatility:

```
Vega = dV / d(sigma)

Black-Scholes:
  Vega = S * N'(d1) * sqrt(T) * exp(-q*T)
```

Convention: Vega is quoted per 1 percentage point change in volatility.

```
Example: Vega = $0.15 means a 1% increase in IV increases option price by $0.15

Portfolio Vega = sum_i (Vega_i * Quantity_i * Multiplier_i)
```

For volatility surface risk, desks track vega by tenor and strike:

```
Vega Matrix:
              ATM    25D Put   25D Call   10D Put   10D Call
  1 Month    $50K    $20K      $25K       $8K       $10K
  3 Month    $80K    $35K      $40K       $15K      $18K
  6 Month    $120K   $50K      $55K       $22K      $25K
  1 Year     $200K   $85K      $90K       $40K      $45K
```

#### Theta

Rate of change of option price with respect to time (time decay):

```
Theta = dV / dT

Black-Scholes (call):
  Theta = -(S * N'(d1) * sigma * exp(-q*T)) / (2 * sqrt(T))
          - r * K * exp(-r*T) * N(d2)
          + q * S * exp(-q*T) * N(d1)
```

Convention: Theta is quoted as the daily loss (negative value). Theta is highest for at-the-money options near expiration.

```
Portfolio Theta = sum_i (Theta_i * Quantity_i * Multiplier_i)

Example: Portfolio Theta = -$45,000 means the portfolio loses $45K per day from time decay
```

#### Rho

Sensitivity of option price to interest rates:

```
Rho = dV / dr

Black-Scholes:
  Call Rho = K * T * exp(-r*T) * N(d2)
  Put Rho = -K * T * exp(-r*T) * N(-d2)
```

Rho is generally less significant for short-dated options but matters for long-dated options and LEAPS.
