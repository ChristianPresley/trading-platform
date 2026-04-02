# FX and Commodities Trading

Comprehensive reference for foreign exchange and commodities asset-class features on a professional trading desk. Covers spot, forwards, swaps, options, market structure, and commodity-specific considerations.

---

## Table of Contents

### FX Trading
1. [Spot FX Trading](#spot-fx-trading)
2. [FX Forwards and NDFs](#fx-forwards-and-ndfs)
3. [FX Swaps and Cross-Currency Swaps](#fx-swaps-and-cross-currency-swaps)
4. [FX Options](#fx-options)
5. [FX Market Structure](#fx-market-structure)
6. [FX Prime Brokerage and Credit Intermediation](#fx-prime-brokerage-and-credit-intermediation)
7. [FX Fixing Rates](#fx-fixing-rates)
8. [FX Algo Execution](#fx-algo-execution)

### Commodities Trading
9. [Energy Trading](#energy-trading)
10. [Metals Trading](#metals-trading)
11. [Agricultural Commodities](#agricultural-commodities)
12. [Commodity Futures and Options](#commodity-futures-and-options)
13. [Physical vs Financial Commodities Trading](#physical-vs-financial-commodities-trading)
14. [Commodity-Specific Risk](#commodity-specific-risk)

---

# FX Trading

## Spot FX Trading

### Market Overview

The foreign exchange market is the largest financial market in the world by daily turnover (~$7.5 trillion/day as of the 2022 BIS Triennial Survey). It operates 24 hours a day, 5.5 days a week, following the sun from Wellington/Sydney through Tokyo, Singapore, Hong Kong, London, and New York.

### Currency Pair Classification

**G10 Currencies:**
- USD (US Dollar), EUR (Euro), JPY (Japanese Yen), GBP (British Pound), CHF (Swiss Franc), CAD (Canadian Dollar), AUD (Australian Dollar), NZD (New Zealand Dollar), SEK (Swedish Krona), NOK (Norwegian Krone).
- These currencies are freely floating (or managed float), highly liquid, and form the basis of most FX trading.

**Major Pairs (all include USD):**

| Pair | Name | Characteristics |
|---|---|---|
| EUR/USD | "Euro" or "Fiber" | Most traded pair globally (~23% of turnover). Tight spreads (0.1-0.5 pips). |
| USD/JPY | "Dollar-Yen" | Second most traded. Sensitive to US-Japan rate differentials and risk sentiment. |
| GBP/USD | "Cable" | Named for the transatlantic telegraph cable. More volatile than EUR/USD. |
| USD/CHF | "Swissy" | Safe-haven flows. SNB intervention history. |
| AUD/USD | "Aussie" | Commodity-linked (iron ore, coal). Sensitive to China demand. |
| USD/CAD | "Loonie" | Correlated with crude oil prices. |
| NZD/USD | "Kiwi" | Dairy and agricultural commodity link. Smaller liquidity than AUD. |

**Cross Pairs (G10 vs G10, no USD):**
- EUR/GBP, EUR/JPY, GBP/JPY, AUD/JPY, EUR/CHF, AUD/NZD, etc.
- Liquidity is generally lower than majors but still substantial for the main crosses.
- Cross rates can be derived from the two constituent USD pairs (e.g., EUR/JPY = EUR/USD * USD/JPY), but they also trade directly.

**Minor Pairs:**
- G10 crosses with lower liquidity: NOK/SEK, AUD/CAD, GBP/CHF, etc.

**Exotic Pairs:**
- Involve one G10 currency and one emerging market currency: USD/TRY (Turkish Lira), USD/ZAR (South African Rand), USD/MXN (Mexican Peso), USD/BRL (Brazilian Real), USD/INR (Indian Rupee), USD/CNH (offshore Chinese Yuan), USD/SGD, USD/THB, USD/PLN, EUR/CZK, etc.
- Characteristics: wider spreads (5-50+ pips), lower liquidity, higher volatility, potential for gaps around political/economic events, some subject to capital controls.
- CNH vs CNY: CNH is the offshore yuan (freely traded); CNY is the onshore yuan (subject to PBOC daily fixing and band).

### Quoting Conventions

- **Base/Quote (or Base/Term)**: EUR/USD = 1.1050 means 1 EUR = 1.1050 USD. EUR is the base currency, USD is the quote currency.
- **Pip**: the fourth decimal place for most pairs (0.0001). For JPY pairs, the second decimal place (0.01). EUR/USD moving from 1.1050 to 1.1051 = 1 pip.
- **Pipette (fractional pip)**: the fifth decimal place (or third for JPY pairs). Modern electronic platforms quote to pipettes.
- **Bid/Ask (Offer)**: the bid is the price at which the market maker buys the base currency; the ask is the price at which they sell it.
- **Spread**: ask minus bid, quoted in pips. EUR/USD: 0.1-0.5 pips in normal conditions. Exotics: 5-100+ pips.
- **Big figure**: the first three digits of a quote (e.g., 1.10 in EUR/USD at 1.1050). Traders often quote only the last two digits ("50-51" meaning 1.1050-1.1051).

### Settlement

- **Spot value date**: T+2 business days (with exceptions: USD/CAD = T+1, USD/TRY = T+1, USD/RUB was T+1).
- **Value date determination**: must be a business day in both currencies' settlement centers. This requires holiday calendars for all relevant countries.
- **CLS (Continuous Linked Settlement)**: the primary settlement mechanism for FX. CLS Bank settles both legs of an FX trade simultaneously (payment-vs-payment, or PvP), eliminating Herstatt risk (settlement risk where one party pays but the other defaults before delivering).
- **CLS-eligible currencies**: 18 currencies as of 2024 (USD, EUR, GBP, JPY, CHF, CAD, AUD, NZD, SEK, NOK, DKK, SGD, HKD, KRW, ZAR, ILS, MXN, HUF).
- **Non-CLS settlement**: bilateral correspondent banking (each party instructs its nostro bank to pay the counterparty's account). Higher settlement risk.

### Spot FX Trading Workflow

1. **Price discovery**: trader observes streaming prices from multiple liquidity providers (banks, ECNs) or requests a quote.
2. **Execution**: click-to-trade on a streaming price, submit an RFQ, or place a limit order on an ECN.
3. **Trade capture**: booking the trade in the OMS/PMS with both legs (base and term currency amounts, value date, counterparty).
4. **Netting**: aggregate same-currency-pair, same-value-date, same-counterparty trades for net settlement.
5. **Settlement instruction**: generate SWIFT MT202/MT103 payment instructions to nostro banks.
6. **Confirmation**: match trade details with counterparty (electronic matching via SWIFT, FX Connect, or bilateral confirmation).
7. **Settlement**: PvP via CLS or bilateral correspondent banking on value date.

---

## FX Forwards and NDFs

### FX Forwards

An FX forward is an agreement to exchange currencies at a pre-agreed rate on a future value date (beyond spot).

**Forward rate calculation:**
- Forward rate = Spot rate * (1 + r_quote * t) / (1 + r_base * t), where r_quote and r_base are the interest rates in the respective currencies and t is the time to settlement in years.
- The difference between the forward rate and the spot rate is the **forward points** (or swap points).
- If the base currency has a higher interest rate, the forward points are negative (the base currency trades at a forward discount). If lower, the forward points are positive (forward premium).
- Forward points are quoted separately from the spot rate and added to derive the all-in forward rate.

**Quoting:**
- Forward points quoted in pips (or fractions of pips). Example: EUR/USD spot = 1.1050, 3-month forward points = -25.00. All-in forward rate = 1.1050 - 0.0025 = 1.1025.
- Standard tenors: O/N (overnight), T/N (tom-next), S/N (spot-next), 1W, 2W, 1M, 2M, 3M, 6M, 9M, 12M, 2Y, 3Y, 5Y.
- Broken dates (non-standard tenors): priced by interpolating between standard tenor forward points.

**Use cases:**
- Hedging known future FX exposures (e.g., a US company paying EUR invoices in 3 months).
- Speculating on interest rate differentials.
- Rolling spot positions (using tom-next swaps to extend value date daily).

### Non-Deliverable Forwards (NDFs)

NDFs are used for currencies that are not freely convertible or where offshore delivery is restricted.

**Mechanics:**
- Two parties agree on a notional amount, a reference currency pair, a fixing date, and a forward rate (NDF rate).
- On the fixing date, the prevailing spot rate is compared to the NDF rate.
- The difference is settled in cash in the convertible currency (typically USD). No physical exchange of the restricted currency occurs.
- Settlement amount = Notional * (NDF rate - Fixing rate) / Fixing rate (adjusted for the direction).

**Key NDF currencies:**
- CNY (Chinese Yuan onshore), KRW (Korean Won), TWD (Taiwan Dollar), INR (Indian Rupee), BRL (Brazilian Real), CLP (Chilean Peso), COP (Colombian Peso), PEN (Peruvian Sol), PHP (Philippine Peso), IDR (Indonesian Rupiah), MYR (Malaysian Ringgit), VND (Vietnamese Dong), EGP (Egyptian Pound), NGN (Nigerian Naira).

**NDF fixing sources:**
- EMTA (Emerging Markets Traders Association) defines standard fixing sources for each currency.
- Examples: USD/CNY uses the PBOC daily midpoint; USD/KRW uses the Seoul Money Brokerage (KFTC); USD/INR uses the RBI reference rate; USD/BRL uses the PTAX rate.

**NDF market characteristics:**
- Large and growing market (~$250 billion/day).
- Predominantly interbank, with growing electronification.
- NDF clearing is available through LCH and CME (mandatory for certain currency pairs in some jurisdictions).
- NDF-deliverable basis: the difference between the NDF rate and the deliverable forward rate reflects capital controls, convertibility risk, and market segmentation.

---

## FX Swaps and Cross-Currency Swaps

### FX Swaps

An FX swap consists of two simultaneous FX transactions: a spot (or near-date) trade and a forward (or far-date) trade in opposite directions.

**Structure:**
- **Near leg**: buy (sell) currency A vs currency B at the near-date rate.
- **Far leg**: sell (buy) currency A vs currency B at the far-date rate.
- The difference between the near-date and far-date rates is the swap points (same as forward points for the tenor).

**Use cases:**
- **Funding**: borrow one currency using another as collateral. An FX swap is economically equivalent to a collateralized loan.
- **Rolling forward positions**: instead of delivering on a maturing forward, roll it to a new date using a swap.
- **Hedging**: manage the interest rate differential exposure on forward hedges.
- **Central bank operations**: central banks use FX swaps to provide/drain foreign currency liquidity (e.g., Fed USD swap lines with other central banks).

**Market size:** FX swaps are the single largest FX instrument by turnover (~$3.8 trillion/day per BIS survey), larger than spot.

**Tom-next (T/N) swap:**
- A special case: the near leg settles tomorrow (T+1), the far leg on spot (T+2).
- Used daily to roll spot positions. The T/N rate reflects the overnight interest rate differential.
- For retail/CFD platforms, the "swap charge" or "rollover" is derived from the T/N rate.

### Cross-Currency Swaps (XCCY Swaps)

A cross-currency swap involves the exchange of interest payments (and sometimes principal) in two different currencies over a term.

**Structure:**
- **Initial exchange**: principals in two currencies are exchanged at the prevailing spot rate (or an agreed rate).
- **Periodic payments**: each party pays interest on the received principal. One leg is typically floating (e.g., SOFR); the other is floating in the second currency (e.g., EURIBOR) plus a basis spread.
- **Final exchange**: principals are re-exchanged at the same rate as the initial exchange (regardless of where the spot rate is at maturity).

**Cross-currency basis:**
- The spread added to (or subtracted from) one floating leg to equalize the swap value.
- A negative EUR/USD cross-currency basis means the EUR borrower pays less than EURIBOR flat (or equivalently, the USD borrower receives SOFR flat and pays EURIBOR minus basis).
- The basis reflects the relative supply/demand for funding in each currency, credit conditions, and regulatory effects.
- During stress periods (e.g., 2008, 2020), the basis can widen dramatically as demand for USD funding spikes.

**Use cases:**
- **Hedging foreign currency debt**: a EUR-based company that issues USD bonds swaps the USD interest/principal payments to EUR.
- **Accessing foreign currency funding**: borrow where funding is cheapest, swap to the desired currency.
- **Central bank swap lines**: the Fed's USD liquidity swap lines with foreign central banks are structured as cross-currency swaps.

**Cross-currency swap basis trading:**
- Basis widening/narrowing is driven by regulatory changes (Basel III, money market fund reform), quarter-end and year-end effects, and macro stress.
- Quarter/year-end spikes: European and Japanese banks face balance sheet constraints at reporting dates, reducing their willingness to lend USD, which widens the basis.

---

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

---

## FX Prime Brokerage and Credit Intermediation

### FX Prime Brokerage (FXPB)

FX prime brokerage allows a client (typically a hedge fund) to trade with multiple dealers using the prime broker's credit.

**Mechanics:**
1. The client negotiates a prime brokerage agreement (PBA) with the prime broker (PB), typically a large bank.
2. The PB establishes "give-up" agreements with executing dealers (EDs).
3. The client trades with an ED. The trade is then "given up" to the PB, who steps in as the counterparty to both the client and the ED.
4. The ED faces the PB (strong credit) rather than the client (potentially weaker credit).
5. The client faces only the PB, simplifying credit management.

**Benefits for clients:**
- Access to multiple liquidity providers without establishing bilateral credit lines with each.
- Netting: all trades with the PB net down, reducing margin requirements and settlement flows.
- Operational efficiency: single margining, single confirmation, single settlement relationship.

**Benefits for executing dealers:**
- Face the PB's credit, not the client's.
- No need to conduct individual client credit assessments.

**PB economics:**
- PBs charge fees (per-million-traded or fixed monthly fees) and earn on the credit spread between PB funding rates and margin posted by clients.
- Capital-intensive: PBs must allocate balance sheet and regulatory capital to support the give-up positions.
- Concentration risk: a few large PBs dominate (JP Morgan, Deutsche Bank, Barclays, UBS, Citi, Goldman Sachs).
- Post-SNB event (January 2015): the SNB's removal of the EUR/CHF floor caused massive client losses, leading PBs to tighten credit terms and raise minimum requirements.

### Credit Intermediation

Beyond prime brokerage, the FX market has developed additional credit intermediation mechanisms:

- **CLS settlement**: eliminates settlement risk (Herstatt risk) through payment-vs-payment.
- **FX clearing**: LCH ForexClear clears FX NDFs and options. Not yet widely adopted for spot FX.
- **Platform-based netting**: ECNs and multi-dealer platforms net trades at the platform level, reducing gross settlement obligations.
- **Bilateral CSAs (Credit Support Annexes)**: collateral agreements requiring daily margin exchange, similar to derivatives CSAs.

---

## FX Fixing Rates

### WM/Reuters (now Refinitiv WM/R) Fix

The most widely used FX benchmark rate.

**Methodology:**
- Calculated at 4:00 PM London time (the "London fix").
- Based on actual transactions and quotes observed in a 5-minute window centered on 4:00 PM (3:57:30 to 4:02:30).
- Administered by Refinitiv, calculated by WM Company.
- Published for ~150 currency pairs.

**Importance:**
- Used by index providers (MSCI, FTSE Russell) for currency conversion in multi-currency indices.
- Passive (index-tracking) funds must transact at or near the fix rate to minimize tracking error.
- This creates predictable flow at the fix time, which can move markets.

**Fix-related trading:**
- Large fix-related flows (from index rebalances, month-end portfolio adjustments, hedging programs) concentrate into the 5-minute window.
- Dealers hedge fix orders in advance, creating pre-fix positioning.
- Manipulation scandal (2013-2015): multiple banks were fined for colluding to manipulate fix rates. Led to significant regulatory and market structure reforms.
- Post-reform: wider fixing window (expanded from 1 minute to 5 minutes in 2015), enhanced surveillance, stricter dealer conduct requirements.

### ECB Reference Rates

- Published daily at 2:15 PM CET (1:15 PM GMT) by the European Central Bank.
- Based on a daily concertation procedure between central banks at 2:15 PM CET.
- Used as a reference for EU regulatory and contractual purposes.
- Not based on actual transactions; considered less robust than WM/R for trading purposes.

### Tokyo Fix

- Published at 9:55 AM Tokyo time by the Mitsubishi UFJ Bank (formerly Bank of Tokyo-Mitsubishi UFJ).
- The benchmark rate for JPY-based FX transactions.
- Used by Japanese corporates and institutional investors for trade settlement.
- Significant flow concentration, especially in USD/JPY.
- Similar pre-fix positioning dynamics as the London fix.

### Other Fixes

- **Bank of Canada daily rate**: noon ET fix for USD/CAD.
- **Reserve Bank of India reference rate**: published around 12:30 PM IST.
- **PBOC daily midpoint**: the People's Bank of China publishes a daily USD/CNY midpoint at 9:15 AM Beijing time, around which the onshore rate is allowed to trade within a +/- 2% band.
- **SFEMC (Singapore Foreign Exchange Market Committee) rates**: used as NDF fixing sources for several Asian currencies.

---

## FX Algo Execution

### Overview

FX algorithms have grown rapidly in adoption, particularly among institutional investors seeking to reduce market impact and achieve transparent execution.

### Common FX Algo Strategies

**TWAP (Time-Weighted Average Price):**
- Slices the parent order into equal-sized child orders executed at regular intervals over a specified time period.
- Minimal market impact but does not adapt to market conditions.
- Benchmark: TWAP of the market over the algo duration.

**VWAP (Volume-Weighted Average Price):**
- Slices orders according to historical volume profiles (by time of day).
- More concentrated execution during high-volume periods (London/NY overlap).
- Benchmark: VWAP of the market over the algo duration.
- Less meaningful in FX than equities because FX volume data is less transparent (no consolidated tape).

**Implementation Shortfall (IS) / Arrival Price:**
- Trades aggressively at the start to capture the current price, then slows down.
- Balances market impact against timing risk.
- Benchmark: mid-price at algo start (arrival price).
- Urgency parameter controls the trade-off between aggressiveness and passiveness.

**Pegged / Passive:**
- Posts orders at or near the best bid/offer on ECNs.
- Captures spread by filling passively.
- Lowest market impact but highest execution time uncertainty.
- Risk: adverse selection (getting filled when the market is moving against you).

**Iceberg / Stealth:**
- Shows only a small portion of the total order on any single venue.
- Rotates across venues to avoid detection.
- Designed to minimize information leakage.

**Fixing-Targeted:**
- Executes over a window surrounding a fixing time (typically the WM/R 4 PM London fix).
- Aims to achieve a rate close to the published fix rate.
- Adjusts execution speed based on estimated fix flow direction and magnitude.

### FX Algo Analytics and TCA

- **Pre-trade**: estimated impact and duration based on order size, currency pair, time of day, and market conditions.
- **Real-time**: algo monitors execution quality vs. benchmark and adjusts pacing.
- **Post-trade TCA**: compare achieved rate against:
  - Arrival price (mid at algo start).
  - TWAP/VWAP of the market during execution.
  - Fix rate (if fix-targeted).
  - Risk-adjusted metrics (Sharpe-like measures of implementation cost vs. timing risk).
- **Venue analysis**: breakdown of fills by venue (ECN, SDP, dark pool) to assess liquidity sourcing quality.
- **Spread capture**: analysis of how much of the bid-ask spread the algo captured (relevant for passive strategies).

---

# Commodities Trading

## Energy Trading

### Crude Oil

**Benchmarks:**
- **WTI (West Texas Intermediate)**: the US benchmark. Delivered at Cushing, Oklahoma. CME NYMEX CL contract.
- **Brent**: the international benchmark. Originally based on North Sea production; now a basket (Brent, Forties, Oseberg, Ekofisk, Troll - BFOET). ICE Brent Crude (CO1) contract is cash-settled against the ICE Brent Index.
- **Dubai/Oman**: the Asian benchmark. Used for pricing Middle Eastern crude exports to Asia.
- **WTI-Brent spread**: the differential between the two major benchmarks. Driven by logistics, supply/demand balances, and US export dynamics.

**Contract specifications (WTI):**
- Size: 1,000 barrels per contract.
- Tick size: $0.01/barrel = $10 per contract.
- Delivery months: monthly out to 9 years.
- Physical delivery at Cushing, Oklahoma (for the physically-settled CME contract). ICE WTI is cash-settled.
- Expiry: third business day prior to the 25th of the month preceding the delivery month.

**Trading considerations:**
- **Contango vs backwardation**: contango (futures price > spot) occurs when storage is abundant and carrying costs are high. Backwardation (futures < spot) occurs when near-term supply is tight.
- **Roll yield**: in contango, rolling long positions forward incurs a cost (selling cheap near-month, buying expensive far-month). In backwardation, rolling earns a positive yield.
- **Storage plays**: in deep contango, traders lease storage (Cushing tanks, offshore tankers) to store physical crude and sell forward, locking in the contango spread.
- **Crack spreads**: the price difference between crude oil and refined products (gasoline, diesel/heating oil). The 3-2-1 crack = (2 * gasoline price + 1 * heating oil price) / 3 - crude oil price. Refiners hedge using crack spreads.
- **OPEC+ dynamics**: cartel production decisions are a major driver of crude prices.

### Natural Gas

**Benchmarks:**
- **Henry Hub**: the US benchmark. CME NYMEX NG contract. Delivered at Henry Hub, Louisiana.
- **TTF (Title Transfer Facility)**: the European benchmark. ICE TTF Futures.
- **JKM (Japan Korea Marker)**: the Asian LNG benchmark. S&P Global Platts assessment.
- **NBP (National Balancing Point)**: UK gas benchmark. Being superseded by TTF.

**Characteristics:**
- Highly seasonal: heating demand in winter, power generation demand in summer (for cooling).
- **Storage**: underground storage levels are a critical fundamental indicator. EIA weekly storage report (US) moves prices.
- **Basis risk**: physical gas prices vary by location (pricing points). Basis = local price - Henry Hub. Basis differentials reflect pipeline capacity and local supply/demand.
- **Weather sensitivity**: degree days (heating degree days - HDD, cooling degree days - CDD) are closely tracked.
- **LNG (liquefied natural gas)**: the growing global LNG market is linking previously isolated regional gas markets.

### Power (Electricity)

- Electricity is non-storable at scale (though batteries are changing this). This creates extreme price volatility and unique market dynamics.
- **Regional markets**: PJM, ERCOT, CAISO, MISO, NYISO, SPP, ISO-NE (US); EPEX SPOT, Nord Pool (Europe); NEM (Australia).
- **Locational marginal pricing (LMP)**: price varies by node/zone on the grid. Congestion and loss components create basis risk.
- **Real-time vs day-ahead**: day-ahead auctions set prices for each hour of the following day. Real-time (balancing) markets clear every 5-15 minutes.
- **Capacity markets**: separate from energy markets; compensate generators for being available to produce.
- **Spark spread**: the difference between the electricity price and the cost of fuel (natural gas or coal) needed to generate it. Represents the margin for a power plant.
- **Clean spark/dark spread**: includes carbon emission costs.

### Emissions (Carbon Trading)

- **EU ETS (Emissions Trading System)**: the largest carbon market. European Union Allowances (EUAs) traded on ICE and EEX.
- **RGGI (Regional Greenhouse Gas Initiative)**: US northeast states.
- **California Cap-and-Trade**: linked with Quebec (WCI).
- **Compliance vs voluntary markets**: compliance markets are mandated by regulation; voluntary markets serve corporate ESG goals.
- **Price dynamics**: driven by regulatory supply (allowance issuance, market stability reserve), economic activity, fuel switching, and political risk.

---

## Metals Trading

### Precious Metals

**Gold (XAU):**
- Safe-haven asset, inflation hedge, central bank reserve.
- **Trading venues**: COMEX (CME) futures (GC contract, 100 troy ounces), LBMA (London Bullion Market Association) OTC spot/forward, Shanghai Gold Exchange.
- **LBMA Gold Price**: twice-daily electronic auction (10:30 AM and 3:00 PM London time) administered by ICE Benchmark Administration. Replaced the historic London Gold Fix.
- **Quoting**: USD per troy ounce. Other currencies quoted as XAU/USD, XAU/EUR, etc.
- **Physical**: London Good Delivery bars (approximately 400 troy ounces, 995+ fineness). Held in LBMA vaults (Bank of England, commercial vaults).
- **Loco London**: standard settlement location for OTC gold. "Loco London" gold is gold held in London vaults.
- **EFP (Exchange for Physical)**: mechanism to convert futures positions to/from OTC spot positions.
- **Lease rates**: the cost of borrowing physical gold. Gold Forward Offered Rate (GOFO) was historically published by the LBMA (discontinued; now derived from swap rates).

**Silver (XAG):**
- More volatile than gold, with significant industrial demand (electronics, solar panels).
- COMEX silver futures (SI contract, 5,000 troy ounces).
- LBMA Silver Price: daily electronic auction at 12:00 PM London time.

**Platinum (XPT) and Palladium (XPA):**
- Primarily industrial metals (automotive catalytic converters, hydrogen fuel cells for platinum, jewelry).
- NYMEX futures and LPPM (London Platinum and Palladium Market) OTC.
- Supply concentration: South Africa (platinum), Russia (palladium).

### Base Metals

**London Metal Exchange (LME):**
- The global center for base metals trading.
- **Metals**: Copper (Cu), Aluminum (Al), Zinc (Zn), Nickel (Ni), Lead (Pb), Tin (Sn), plus minor metals (cobalt, molybdenum) and steel.
- **Unique features**:
  - **Ring trading**: open-outcry trading in the Ring (though electronic trading is now dominant). Each metal has specific Ring sessions.
  - **Prompt date system**: instead of monthly expiration, the LME uses specific prompt dates. The standard contract is for delivery on a specific future date, with cash (spot for 2 business days) and monthly dates out to 63 months for copper/aluminum.
  - **3-month benchmark**: the most quoted benchmark is the 3-month forward price (cash + 3 months).
  - **Warehouse system**: the LME operates a global network of approved warehouses. Physical delivery occurs by delivery of LME warrants (warehouse receipts).
  - **Queues**: historically, warehouse queues (time to take delivery of metal) became very long, distorting physical premiums.
- **Settlement**: T+2 for cash; specific prompt date for forward.

**COMEX (CME Group) Copper:**
- The primary US copper futures contract (HG, 25,000 lbs per contract).
- Physically deliverable at COMEX-approved warehouses.
- Increasingly competitive with LME for global copper price discovery.

**SHFE (Shanghai Futures Exchange):**
- Major base metals exchange for Chinese-market metals.
- Growing influence on global pricing given China's dominance in metals consumption.

---

## Agricultural Commodities

### Major Agricultural Commodities

**Grains and Oilseeds (CME Group / CBOT):**
- **Corn (ZC)**: 5,000 bushels per contract. The most actively traded agricultural futures contract.
- **Soybeans (ZS)**: 5,000 bushels. Soybean complex includes soybean meal (ZM) and soybean oil (ZL).
- **Wheat**: multiple contracts - CBOT Wheat (ZW, soft red winter), KCBT Wheat (KE, hard red winter), MGEX Wheat (MWE, hard red spring).
- **Rice (ZR)**: rough rice futures.

**Softs (ICE Futures US):**
- **Coffee (KC)**: Arabica coffee, 37,500 lbs per contract.
- **Sugar (SB)**: raw sugar, 112,000 lbs per contract. Sugar No. 11 is the world benchmark.
- **Cocoa (CC)**: 10 metric tons per contract.
- **Cotton (CT)**: 50,000 lbs per contract.
- **Frozen Concentrated Orange Juice (OJ)**: 15,000 lbs per contract.

**Livestock (CME Group):**
- **Live Cattle (LE)**: 40,000 lbs per contract. Physically delivered.
- **Feeder Cattle (GF)**: 50,000 lbs per contract. Cash-settled.
- **Lean Hogs (HE)**: 40,000 lbs per contract. Cash-settled.

### Trading Characteristics

- **Seasonality**: planting, growing, and harvest seasons create predictable price patterns. Corn and soybeans: prices often rise during the "weather market" (June-August) when crop conditions are uncertain.
- **USDA reports**: WASDE (World Agricultural Supply and Demand Estimates, monthly), Crop Production reports, Planted Acreage reports, Grain Stocks reports. These releases can cause major price moves.
- **Global supply/demand**: weather events (droughts, floods, El Nino/La Nina), geopolitical disruptions (export bans, trade wars), and biofuel mandates all drive agricultural prices.
- **Contract expiry and delivery**: physical delivery contracts require understanding of delivery points, grades/quality specifications, and logistics (grain elevators, shipping).

---

## Commodity Futures and Options

### Futures Contract Mechanics

**Key terms:**
- **Contract size**: standardized quantity (e.g., 1,000 barrels for crude oil, 100 troy ounces for gold).
- **Tick size and value**: minimum price increment and its dollar value (e.g., $0.01/barrel = $10 per crude oil contract).
- **Delivery/expiry months**: vary by commodity (crude oil: every month; grains: March, May, July, September, December).
- **Margin**: initial margin (deposit to open a position) and maintenance margin (minimum balance). Margins are set by the exchange/clearinghouse and vary with volatility.
- **Mark-to-market**: daily settlement. P&L is realized daily through variation margin payments.
- **Position limits**: exchange and regulator-imposed limits on the number of contracts a single entity can hold (speculative position limits under CFTC regulations). Hedge exemptions available for bona fide hedgers.
- **Reportable positions**: large positions must be reported to regulators. The CFTC publishes the Commitments of Traders (COT) report weekly, showing positions by category (commercial, non-commercial, non-reportable).

**Settlement types:**
- **Physical delivery**: the seller delivers the physical commodity; the buyer takes delivery. Requires logistics infrastructure (warehouses, pipelines, terminals).
- **Cash settlement**: the position is settled in cash based on a final settlement price (typically an index or spot price). No physical delivery.
- **Exchange for Physical (EFP)**: off-exchange transaction converting a futures position to/from a physical commodity position. Common in energy and metals.
- **Exchange for Risk (EFR)**: similar, but converting between a futures position and an OTC derivative position.

### Commodity Options

- Options on commodity futures (not the physical commodity itself).
- **American style**: exercisable at any time before expiry (standard for US commodity options).
- **European style**: exercisable only at expiry.
- **Quoting**: premium in dollars per unit (e.g., $1.50/barrel for a crude oil option = $1,500 per contract).
- **Volatility smile/skew**: commodity options often exhibit significant skew (OTM puts more expensive than OTM calls for upside-biased commodities like crude oil, reflecting crash risk).
- **Seasonal volatility**: options premiums reflect seasonal patterns (e.g., natural gas options for winter months are more expensive than summer months).
- **Asian options**: payoff based on the average price over a period (common in commodity OTC markets for hedging average price exposures).
- **Spread options**: options on the price differential between two commodities (e.g., crack spread options, calendar spread options).

### Commodity Swaps

- OTC contracts exchanging a fixed price for a floating price on a commodity.
- **Fixed-for-floating swap**: the most common. One party pays a fixed price per unit; the other pays the average floating price (based on a published index) over each calculation period.
- **Basis swaps**: exchange of one floating price for another (e.g., WTI vs Brent, or Henry Hub vs a regional gas index).
- **Calendar swaps**: exchange of floating prices for different periods.
- **Used by**: producers (lock in a selling price), consumers (lock in a purchase price), traders (express relative value views).
- **Clearing**: many commodity swaps are cleared through CME, ICE, or LCH under Dodd-Frank / EMIR mandates.

---

## Physical vs Financial Commodities Trading

### Physical Trading

Physical commodity trading involves the actual purchase, transportation, storage, and sale of the physical commodity.

**Key activities:**
- **Procurement**: buying physical commodities from producers (mines, farms, wells) or on the spot market.
- **Logistics**: arranging transportation (ships, pipelines, rail, trucks), storage (tank farms, grain elevators, warehouses), and blending/processing.
- **Quality management**: commodities are not perfectly fungible. Quality specifications (API gravity and sulfur content for crude, moisture and protein for grains, purity for metals) affect pricing.
- **Documentation**: bills of lading, warehouse receipts, letters of credit, inspection certificates, certificates of origin.
- **Counterparty risk**: physical trades often involve extended credit terms (30-90 days). Credit insurance and letters of credit are common.

**Major physical trading firms:**
- Vitol, Trafigura, Glencore, Gunvor, Mercuria (energy).
- Cargill, ADM, Bunge, Louis Dreyfus (agriculture - the "ABCD" firms).
- Trafigura, Glencore (metals).

### Financial Trading

Financial commodity trading involves derivatives (futures, options, swaps) without physical delivery.

**Key characteristics:**
- Standardized contracts on regulated exchanges.
- Cleared through CCPs (no bilateral counterparty risk).
- Mark-to-market daily.
- Predominantly cash-settled (especially for financial players).
- No logistics or storage requirements.
- Position limits apply to speculators.

### Convergence Between Physical and Financial

- Physical traders use financial derivatives to hedge their physical positions.
- Financial traders occasionally take physical positions (especially at contract expiry) but generally avoid it.
- **Basis risk**: the difference between the specific physical commodity being hedged and the standardized futures contract. Example: a refiner hedging Gulf Coast crude with WTI futures at Cushing faces Cushing-Gulf Coast basis risk.
- **EFP (Exchange for Physical)**: the mechanism that links physical and financial markets. A physical trader and a financial trader simultaneously exchange a futures position for a physical position at an agreed basis.

---

## Commodity-Specific Risk

### Storage and Carry

- **Cost of carry**: storage costs + insurance + financing - convenience yield.
- **Convenience yield**: the implicit benefit of holding the physical commodity (e.g., ability to meet unexpected demand, keep a refinery running). High convenience yield drives backwardation.
- **Storage capacity constraints**: when storage is full, contango can collapse or even invert (see negative oil prices in April 2020 when WTI front-month went to -$37.63 because Cushing storage was nearly full and there was no place to deliver the oil).
- **Degradation**: some commodities degrade over time (agricultural products, certain chemicals). Storage must account for quality deterioration.

### Delivery and Logistics

- **Delivery points**: futures contracts specify where delivery occurs. The delivery point becomes a focal point for supply/demand dynamics.
- **Delivery optionality**: the short (seller) often has options regarding timing and grade of delivery (cheapest-to-deliver logic, similar to bond futures).
- **Transportation costs**: the cost of moving commodities from production to consumption points creates geographic price differentials (basis).
- **Infrastructure constraints**: pipeline capacity, port capacity, rail availability, and trucking logistics all affect physical flows and pricing.
- **Incoterms**: international commercial terms (FOB, CIF, CFR, DES, DAP, etc.) define the point at which risk and cost transfer between buyer and seller.

### Weather Risk

- **Agricultural commodities**: directly affected by precipitation, temperature, frost, drought. Crop condition ratings and weather forecasts drive prices.
- **Energy**: heating demand (winter cold snaps) and cooling demand (summer heat waves) affect natural gas and power prices.
- **Weather derivatives**: contracts whose payoff depends on weather outcomes (heating degree days, cooling degree days, rainfall). CME trades weather futures. OTC weather swaps are negotiated bilaterally.
- **El Nino / La Nina**: Pacific Ocean temperature patterns that affect global weather. El Nino tends to cause drought in Australia/Asia and warmer winters in the US. La Nina brings cooler, wetter conditions to the Pacific region.

### Seasonality

- **Crop cycles**: planting (spring), growing (summer), harvest (fall) create predictable price patterns for agricultural commodities.
- **Energy**: natural gas has a seasonal pattern (withdrawal season Oct-Mar, injection season Apr-Sep). Crude oil has a summer driving season pattern (gasoline demand) and a winter heating oil pattern.
- **Metals**: less seasonal, but construction activity (spring/summer) drives some cyclicality in base metals demand.
- **Calendar spreads**: seasonality creates predictable term structure patterns. Trading calendar spreads (long one month, short another) is a common way to express seasonal views.
- **Seasonal storage economics**: natural gas storage operators inject gas in summer (cheap) and withdraw in winter (expensive), earning the seasonal spread. The economics of this trade drive the natural gas term structure.

### Geopolitical and Regulatory Risk

- **Supply disruptions**: wars, sanctions, political instability in producing countries (Middle East for oil, Russia for gas/wheat/palladium, Chile for copper, DRC for cobalt).
- **Export controls**: government restrictions on commodity exports (Indonesia nickel export ban, India wheat export ban, Russia gas supply curtailment to Europe).
- **Sanctions**: US/EU sanctions on Russian oil required the development of price cap mechanisms and created complex compliance requirements for traders.
- **Environmental regulations**: emissions regulations, mining restrictions, deforestation rules (affecting palm oil, soy) all impact commodity supply and cost structures.
- **CFTC position limits**: speculative position limits on US commodity futures, with accountability levels for OTC instruments.
- **EU regulatory framework**: REMIT (energy markets), MiFID II (commodity derivatives classification), position limits and reporting.

---

## Key Data Requirements for an FX and Commodities Trading Platform

| Data Type | Sources | Update Frequency |
|---|---|---|
| FX spot rates (streaming) | EBS, Reuters Matching, bank LPs, ECNs | Real-time (sub-millisecond) |
| FX forward points | Bloomberg, Refinitiv, dealer streams | Real-time |
| FX option volatilities | Bloomberg OVML, Refinitiv, broker quotes | Intraday |
| FX fixing rates | WM/Reuters, ECB, PBOC, BOJ | Daily at fix times |
| Commodity futures prices | CME, ICE, LME, SHFE direct feeds | Real-time |
| Physical commodity prices | Platts, Argus, ICIS, Metal Bulletin | Daily assessments |
| Commodity storage and inventory | EIA, API, LME warehouse stocks, USDA | Weekly/daily |
| Weather data | NOAA, ECMWF, private weather services | Continuous |
| CFTC COT reports | CFTC | Weekly (Friday) |
| OPEC production data | OPEC Monthly Oil Market Report, IEA | Monthly |
| Shipping/freight rates | Baltic Exchange (BDI, BCI), Platts | Daily |
| Central bank rates and decisions | Fed, ECB, BOJ, BOE, RBA, etc. | Event-driven |
| Economic calendar | Bloomberg, Refinitiv | Daily/event-driven |
| Sanctions and compliance lists | OFAC, EU Sanctions, UN | Event-driven |
