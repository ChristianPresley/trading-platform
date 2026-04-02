## Options Order Types and Strategies

### Single-Leg Orders

The most basic options trade involves a single contract — one call or one put. Order types applicable to single-leg options include:

- **Market** — filled at the best available price; dangerous in illiquid options where the bid-ask spread can be several dollars wide.
- **Limit** — specify maximum buy price or minimum sell price. The standard for options trading.
- **Stop** — triggers a market order when the option's last trade or mark hits the stop price.
- **Stop-Limit** — triggers a limit order at the stop price; avoids adverse fills but risks non-execution.
- **Trailing Stop** — adjusts dynamically by a fixed amount or percentage from the option's high/low.
- **Market-on-Close (MOC)** — executed during the closing rotation; used for expiration-day management.
- **Fill-or-Kill (FOK)** — entire order must fill immediately or is cancelled; used in large block trades.
- **Immediate-or-Cancel (IOC)** — fills as much as possible immediately, cancels the rest.
- **Good-Til-Cancelled (GTC)** — persists across sessions until filled or explicitly cancelled.
- **All-or-None (AON)** — must fill the entire quantity, but does not require immediate execution.

### Multi-Leg Strategies

Professional desks route multi-leg orders as a single package (complex order) to exchanges that support complex order books (COB). This avoids leg risk — the danger that one leg fills and the other does not.

#### Vertical Spreads

Vertical spreads use the same expiration, different strikes.

| Strategy | Construction | Max Profit | Max Loss | Outlook |
|---|---|---|---|---|
| **Bull Call Spread** | Buy lower-strike call, sell higher-strike call | Width minus debit | Net debit | Moderately bullish |
| **Bear Put Spread** | Buy higher-strike put, sell lower-strike put | Width minus debit | Net debit | Moderately bearish |
| **Bull Put Spread** | Sell higher-strike put, buy lower-strike put | Net credit | Width minus credit | Neutral to bullish |
| **Bear Call Spread** | Sell lower-strike call, buy higher-strike call | Net credit | Width minus credit | Neutral to bearish |

Width = difference between strikes. For example, a 100/105 bull call spread on SPY with a $2.00 debit has max profit of $3.00 and max loss of $2.00.

#### Horizontal (Calendar) Spreads

Same strike, different expirations. The trader buys the longer-dated option and sells the shorter-dated option.

- **Long Calendar Call Spread** — Buy far-month call, sell near-month call at same strike. Profits from time decay differential and volatility expansion in the back month.
- **Long Calendar Put Spread** — Same structure with puts.
- **Double Calendar** — Calendar spreads at two different strikes, bracketing the current price.

Key risk: if the underlying moves sharply away from the strike, both options lose value. Vega exposure is net long (back month has higher vega). Theta exposure is net positive near the short expiration.

#### Diagonal Spreads

Different strikes AND different expirations. Combines vertical and calendar characteristics.

- **Poor Man's Covered Call** — Buy a deep ITM LEAPS call (delta ~0.80), sell a short-term OTM call. Mimics covered call with less capital.
- **Diagonal Put Spread** — Buy a longer-dated put, sell a shorter-dated put at a different strike.

Diagonals require careful management because the short option expires first, and the remaining long position may need to be rolled or closed.

#### Straddles

Buy (or sell) both a call and a put at the same strike and expiration.

- **Long Straddle** — Pays when the underlying moves sharply in either direction. Breakevens are strike +/- total premium paid. Expensive because you buy two at-the-money options.
- **Short Straddle** — Collects premium; profits if the underlying stays near the strike. Theoretically unlimited risk on the call side, risk to zero on the put side.

Typical use: earnings plays (long), income generation on indices (short).

#### Strangles

Buy (or sell) an OTM call and an OTM put at different strikes, same expiration.

- **Long Strangle** — Cheaper than a straddle but requires a larger move to profit. Wider breakeven range.
- **Short Strangle** — Wider profit zone than a short straddle, but still significant risk.

Professional desks frequently sell index strangles (e.g., SPX 1-standard-deviation strangle) and delta-hedge dynamically.

#### Butterflies

Three strikes, same expiration. The position is constructed with a 1:2:1 ratio.

- **Long Call Butterfly** — Buy 1 lower call, sell 2 middle calls, buy 1 upper call. Max profit at middle strike. Very low cost. Used for pinning plays near expiration.
- **Long Put Butterfly** — Buy 1 upper put, sell 2 middle puts, buy 1 lower put.
- **Broken Wing Butterfly** — Uneven strike spacing (e.g., 95/100/110). Introduces directional bias and may result in a credit instead of a debit.
- **Iron Butterfly** — Sell ATM call and put (straddle), buy OTM call and put (strangle) as wings. Equivalent payoff to a long butterfly but constructed with all four options. Always entered for a credit.

#### Condors

Four strikes, same expiration.

- **Long Call Condor** — Buy lowest call, sell second call, sell third call, buy highest call. Profits in a range between the two middle strikes.
- **Long Put Condor** — Same structure with puts.

#### Iron Condors

The most popular income strategy among professional and retail traders.

- **Iron Condor** — Sell an OTM put spread and an OTM call spread simultaneously. Collect premium from both sides. Max profit = net credit. Max loss = width of wider spread minus credit.
- Typical setup: sell 1-SD strangle, buy 1.5-SD wings. Example on SPX: sell 4200 put / buy 4150 put / sell 4400 call / buy 4450 call for $5.00 credit.
- Management rules: close at 50% of max profit, adjust tested side at 25-delta, roll untested side for additional credit.

#### Ratio Spreads

Unequal numbers of long and short options.

- **Call Ratio Spread** — Buy 1 ATM call, sell 2 OTM calls. Creates a free or credit trade with unlimited upside risk. Also called a "1x2."
- **Put Ratio Spread** — Buy 1 ATM put, sell 2 OTM puts. Risk to the downside if the underlying drops sharply past the lower breakeven.
- **Ratio Backspread** — Reverse of the above (buy more than you sell). Long volatility play with defined risk on one side, unlimited profit on the other.

Ratio spreads are characterized by a point of maximum profit at the short strike, with risk accelerating beyond the breakeven.

#### Collar

- **Standard Collar** — Own the underlying, buy a protective put, sell a covered call. Often zero-cost or near-zero-cost. Limits both upside and downside.
- **Costless Collar** — The call premium exactly offsets the put premium. Common in corporate hedging (executives hedging concentrated stock positions, often under Rule 10b5-1 plans).
- **Variable Collar** — Different quantities of calls and puts, or different expiration dates.

---

## Options Chain Display

### Strike Ladder

The standard options chain display is a table organized by strike price with calls on the left and puts on the right (or vice versa). Professional platforms display:

| Column | Description |
|---|---|
| **Bid** | Best available bid price |
| **Ask** | Best available ask price |
| **Last** | Last trade price |
| **Volume** | Number of contracts traded today |
| **Open Interest** | Total outstanding contracts |
| **Implied Volatility** | Market-implied volatility for that specific strike |
| **Delta** | Rate of change of option price with respect to underlying |
| **Gamma** | Rate of change of delta |
| **Theta** | Daily time decay in dollars |
| **Vega** | Sensitivity to 1% change in implied volatility |

### Color Coding

- **In-the-money (ITM)** strikes are shaded (typically light blue or yellow) to distinguish from OTM.
- The **ATM** (at-the-money) strike is highlighted or bordered.
- Strikes with high open interest or unusual volume are flagged.
- Bid-ask spreads wider than a threshold (e.g., >10% of mid) are highlighted in red.

### Expiration Grid

A matrix view with expirations across the top and strikes down the side. Each cell shows the option price (or Greeks). This is particularly useful for:

- Identifying relative value across expirations (term structure)
- Spotting calendar spread opportunities
- Visualizing the volatility surface

Professional systems (Bloomberg OMON, Refinitiv Eikon, CQG) allow pivoting the grid between price, IV, delta, or any Greek.

### Greeks Display Modes

- **Per-contract** — Greeks for one contract (e.g., delta = 0.45).
- **Position-level** — Greeks multiplied by position size and contract multiplier (e.g., 100 shares per equity option). A position of 10 contracts with delta 0.45 shows position delta = 450.
- **Dollar Greeks** — Greeks expressed in dollar terms. Dollar delta = delta x underlying price x multiplier x quantity. Dollar gamma = gamma x underlying price^2 x multiplier / 100.
- **Percentage Greeks** — Useful for comparing options on different underlyings.

### Implied Volatility Display

- **Per-strike IV** — Shown in the chain for each individual option.
- **ATM IV** — The implied volatility at the at-the-money strike, often interpolated between the two nearest strikes.
- **IV Rank** — Current IV relative to its 52-week range: (Current IV - 52w Low) / (52w High - 52w Low). An IV rank of 80% means current IV is near the top of its annual range.
- **IV Percentile** — The percentage of days in the past year where IV was below the current level. More robust than IV rank because it accounts for the distribution of historical IV.
- **Skew indicator** — 25-delta put IV minus 25-delta call IV (risk reversal). Positive skew (the norm for equity indices) means OTM puts are more expensive than OTM calls.
