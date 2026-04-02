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
