## Exotic Options

### Path-Independent Exotics

#### Digital (Binary) Options

Pay a fixed amount if the underlying is above (digital call) or below (digital put) the strike at expiration.

- **Cash-or-nothing:** Pays a fixed cash amount (e.g., $100) if ITM. Zero otherwise.
- **Asset-or-nothing:** Pays the value of the underlying if ITM.
- **One-touch:** Pays if the underlying touches the barrier at any time before expiration (American digital).
- **No-touch:** Pays if the underlying never touches the barrier.

**Hedging challenge:** Digital options have discontinuous payoffs, creating infinite gamma at the strike near expiration. Market makers hedge with tight call/put spreads (overhedge) rather than delta hedging.

#### Compound Options

An option on an option. Four types: call on call, call on put, put on call, put on put.

- **Use case:** Bidding on an acquisition — the bidder has the right but not the obligation to acquire the target, which itself is exposed to the option-like payoff of equity.
- **Installment options:** A series of compound options where the holder pays premium in installments and can stop paying (let the option lapse) at any installment date.

#### Chooser Options

The holder decides at a specified future date whether the option becomes a call or a put.

- **Simple chooser:** Uses put-call parity to value; equivalent to a call plus a put with adjusted terms.
- **Complex chooser:** The call and put have different strikes and expirations.

### Path-Dependent Exotics

#### Asian Options

Payoff depends on the average price of the underlying over a period.

- **Average price (fixed strike):** Payoff = max(Average - K, 0). Common in commodity markets to hedge average exposure over a month or quarter.
- **Average strike (floating strike):** Payoff = max(S_T - Average, 0). Less common.
- **Arithmetic average:** No closed-form solution; priced via Monte Carlo or moment-matching approximation.
- **Geometric average:** Has a closed-form solution (used as a control variate for arithmetic Asian options).

**Use case:** A refiner hedges the average price of crude oil over the next quarter. An Asian option is cheaper than a vanilla option because averaging reduces volatility.

#### Lookback Options

Payoff depends on the maximum or minimum underlying price during the option's life.

- **Fixed strike lookback call:** max(S_max - K, 0). The holder benefits from the highest price reached.
- **Floating strike lookback call:** max(S_T - S_min, 0). The strike is set to the minimum price observed.
- **Partial lookback:** The lookback period is a subset of the option's life.

Expensive due to the path dependency. Priced via Monte Carlo or PDE methods.

#### Barrier Options

Vanilla options that are activated (knocked in) or deactivated (knocked out) when the underlying hits a barrier level.

**Knock-out options:**
- **Down-and-out call:** Standard call that ceases to exist if the underlying falls below the barrier.
- **Up-and-out call:** Call that ceases to exist if the underlying rises above the barrier.
- **Down-and-out put, Up-and-out put:** Analogous put versions.

**Knock-in options:**
- **Down-and-in call:** Only comes into existence if the underlying falls to the barrier.
- **Up-and-in call, Down-and-in put, Up-and-in put:** Analogous.

**Key relationship:** Knock-in + Knock-out = Vanilla (for the same barrier and otherwise identical terms).

**Barrier monitoring:** Continuous (any time during market hours) vs discrete (daily close only). Continuous barriers are cheaper to monitor but more likely to be triggered.

**Rebate:** Some barrier options pay a fixed rebate if knocked out.

**Hedging:** Barrier options have discontinuous delta at the barrier, making hedging difficult. Market makers often use barrier-shifted replication (hedge with a spread of vanillas near the barrier).

#### Quanto Options

Options denominated in a different currency than the underlying.

- Example: A European investor buys a call on the S&P 500 (denominated in USD) with a payoff converted at a fixed exchange rate into EUR (the quanto adjustment).
- Eliminates currency risk for the investor.
- Requires modeling the correlation between the underlying asset returns and the exchange rate.

**Quanto adjustment:** The risk-neutral drift of the underlying is adjusted by -rho * sigma_S * sigma_FX, where rho is the correlation between the asset and the exchange rate.

#### Rainbow Options

Options on multiple underlyings.

- **Best-of:** Payoff based on the maximum of N underlyings. max(S1, S2, ..., SN) - K.
- **Worst-of:** Payoff based on the minimum. More common in structured products. Cheaper than best-of because the worst performer is always less than or equal to any individual.
- **Spread option:** Payoff based on the difference between two underlyings. max(S1 - S2 - K, 0). Kirk's approximation provides a closed-form price.
- **Outperformance option:** Pays if one asset outperforms another.

#### Basket Options

Options on a weighted portfolio of underlyings.

- Payoff: max(weighted_sum(S_i) - K, 0).
- Common in equity-linked structured products.
- No closed-form solution. Priced via Monte Carlo, moment-matching (treating the basket as a single lognormal or shifted lognormal), or copula methods.
- Correlation between basket components is the key pricing driver.
