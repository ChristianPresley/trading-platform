## FX Options

### Vanilla Options

**Terminology:**
- **Call/Put**: a EUR call / USD put gives the right to buy EUR and sell USD. A EUR put / USD call gives the right to sell EUR and buy USD.
- **Strike**: the exchange rate at which the option can be exercised.
- **Expiry date**: the last date on which the option can be exercised.
- **Delivery date**: typically spot (T+2) from the expiry date.
- **Premium**: quoted as a percentage of the notional in the base or term currency, or in pips of the base currency.
- **Exercise style**: European (exercisable only at expiry) is standard in OTC FX. American (any time before expiry) is rare.

**Quoting conventions:**
FX options have a unique quoting convention based on delta and volatility:
- **ATM (At-the-Money)**: strike where delta = 50% (delta-neutral straddle). ATM volatility is the anchor of the vol surface.
- **Risk Reversal (RR)**: the difference in implied volatility between the call and put at symmetric deltas (e.g., 25-delta RR = vol of the 25-delta call minus vol of the 25-delta put). Measures skew.
- **Butterfly (BF)**: the average of the call and put vols minus the ATM vol at the same delta. Measures the "smile" (kurtosis premium). BF = 0.5 * (vol_call + vol_put) - vol_ATM.
- **Standard deltas**: 10-delta, 25-delta (most liquid), and ATM.
- **Vol surface**: defined by the matrix of (expiry, delta) points. Standard expiries: O/N, 1W, 2W, 1M, 2M, 3M, 6M, 9M, 1Y, 2Y, 3Y, 5Y.

**Common strategies:**
- **Straddle**: long call + long put at ATM strike. Profits from volatility (regardless of direction).
- **Strangle**: long OTM call + long OTM put. Cheaper than straddle but requires larger move.
- **Risk reversal**: long call + short put (or vice versa). Directional bet with zero or reduced premium.
- **Spread**: long call at one strike, short call at higher strike. Capped upside, reduced premium.

### Barrier Options

Options that are activated ("knock-in") or deactivated ("knock-out") when the spot rate reaches a specified barrier level.

**Types:**
- **Knock-out (KO)**: option ceases to exist if the barrier is breached.
  - **Up-and-out call**: call option that dies if spot rises above the barrier.
  - **Down-and-out put**: put option that dies if spot falls below the barrier.
- **Knock-in (KI)**: option comes into existence only if the barrier is breached.
  - **Down-and-in call**: call option that activates only if spot drops to the barrier first.
  - **Up-and-in put**: put option that activates only if spot rises to the barrier first.
- **Reverse barriers**: barrier is on the same side as the in-the-money region (e.g., down-and-out call - the call is in the money and the barrier knocks it out as it goes further in the money). These are cheaper because of the knock-out risk.

**Barrier observation:**
- **Continuous**: barrier monitored at every point in time during market hours.
- **Discrete (daily fixing)**: barrier only monitored at a specific daily fixing time.
- **Window barrier**: barrier active only during a specified period.

**Risk management considerations:**
- Delta and gamma can change abruptly near the barrier.
- **Pin risk**: when spot is near the barrier close to expiry, the option's Greeks oscillate wildly.
- Barrier hedging requires dynamic rebalancing and can be expensive in volatile markets.

### Digital (Binary) Options

- Pay a fixed amount if the spot rate is above (or below) a specified level at expiry.
- **European digital**: settlement based on spot at expiry.
- **American digital (one-touch / no-touch)**: pays if the spot rate touches (or never touches) a specified level during the life of the option.
- **Double no-touch (DNT)**: pays if spot stays within a range for the life of the option. Popular for range-bound views.
- **Risk**: digital options have discontinuous payoffs, making hedging challenging near the strike/barrier.

### Accumulators (Target Redemption Forwards)

Structured products that allow the client to buy (or sell) currency at a favorable rate, subject to conditions:

- **Daily accumulation**: on each business day, the client buys a fixed notional at the strike rate if spot is at or above a specified level, and potentially double the notional ("leverage") if spot is below.
- **Knock-out (target profit)**: the structure terminates once the accumulated profit reaches a specified target.
- **Risk**: if the market moves against the client, they are locked into buying at the strike (potentially at double the notional) with no knock-out mechanism in that direction. This creates a highly asymmetric risk profile.
- Often described as "I kill you later" products due to the potential for large losses.
- Popular in Asian FX markets (USD/CNH, AUD/USD).

---

## FX Market Structure

### Interbank Market

The FX market is decentralized (OTC). There is no single exchange. The interbank market consists of:

- **Tier 1 dealers**: the largest FX banks (JP Morgan, UBS, Deutsche Bank, Citi, HSBC, Barclays, Goldman Sachs, etc.). These banks make markets to clients and to each other.
- **Tier 2/3 banks**: smaller banks that access liquidity from tier 1 via the interbank market or through prime brokerage.
- **Central banks**: intervene in FX markets to manage their currency (direct intervention) or conduct monetary policy operations.

### Electronic Communication Networks (ECNs)

**EBS (now part of CME Group):**
- Primary interbank platform for EUR/USD, USD/JPY, EUR/JPY, USD/CHF, and other major pairs.
- Central limit order book (CLOB) model.
- Historically the benchmark for spot FX pricing in these pairs.
- EBS Market: the CLOB. EBS Direct: streaming/bilateral model.
- Minimum trade size: typically $1M for EBS Market.

**Refinitiv FX Matching (formerly Reuters Matching):**
- Primary interbank platform for GBP/USD, AUD/USD, NZD/USD, USD/CAD, and Scandinavian/EM pairs.
- Also a CLOB model.
- Complementary to EBS in terms of currency pair coverage.

**Currenex (Refinitiv):**
- Multi-dealer platform primarily for institutional clients.
- Supports streaming prices and RFQ.
- Used by asset managers, hedge funds, and corporations.

**FXall (Refinitiv):**
- Multi-dealer RFQ platform.
- Strong in institutional and corporate FX.
- Workflow tools for trade allocation, confirmation, and STP (straight-through processing).

**360T (Deutsche Boerse):**
- Multi-dealer platform popular in European corporate FX.
- RFQ and streaming protocols.

**Bloomberg FX:**
- FXGO: multi-dealer RFQ and execution platform.
- FXGO is widely used because of Bloomberg Terminal ubiquity.

**Hotspot (Cboe FX):**
- ECN for institutional FX.
- CLOB and streaming models.

**Euronext FX (formerly FastMatch):**
- ECN for spot FX.

**Single-Dealer Platforms (SDPs):**
- Major banks operate their own electronic trading platforms for clients.
- Examples: JP Morgan Execute, Barclays BARX, Deutsche Bank Autobahn, Citi Velocity, Goldman Sachs Marquee, UBS Neo.
- Benefits: tighter pricing (no platform fees), customized liquidity, direct relationship.
- The client trades bilaterally with the bank, not on a shared order book.

### Market Microstructure

**Last look:**
- A controversial practice where a liquidity provider (bank) has a short window (typically 50-200 milliseconds) after receiving a client order to accept or reject it.
- Allows the LP to check if the price is still valid (protects against latency arbitrage).
- Critics argue it disadvantages clients, especially in fast markets.
- FX Global Code of Conduct addresses last look: recommends transparency about its use and discourages using the window for proprietary information.

**Price aggregation:**
- Buy-side firms use aggregators (EMS - Execution Management Systems) to consolidate streaming prices from multiple LPs and ECNs into a single best-bid-best-offer (BBBO) display.
- Aggregators: FlexTrade, TradingScreen, Bloomberg FXGO, proprietary systems.

**Fragmentation:**
- Unlike equities, there is no consolidated tape for FX. No NBBO exists.
- This fragmentation creates opportunities for latency arbitrage and motivates the use of aggregation technology.
