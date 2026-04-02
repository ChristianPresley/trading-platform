## Market Event Handling

### 7.1 Trading Halts

Trading halts occur when an exchange suspends trading in a specific instrument, typically due to pending news, order imbalance, or regulatory concern.

**Halt handling workflow**:

1. **Detection**: The market data feed delivers a halt indicator for the instrument (typically via exchange-specific message types or the FIX SecurityTradingStatus field).
2. **System response**:
   - Mark the instrument as halted in the instrument master
   - Block new order submission for the halted instrument
   - Display halt status prominently on the trading UI
   - Alert traders who have open orders or positions in the instrument
3. **Open order handling**: Orders that were open when the halt was announced:
   - Exchange-held orders remain on the exchange order book (behavior varies by exchange)
   - The system tracks which orders are "frozen" and displays their status
4. **Resume handling**: When the halt lifts:
   - Update instrument status to active
   - Re-enable order entry
   - Notify traders that trading has resumed
   - Display the re-opening price and any indicative price published during the halt
5. **Audit**: All halt events, system responses, and user actions during halts are logged

**Halt types**:
| Halt Type | Typical Duration | Trigger |
|---|---|---|
| News pending (T1) | Minutes to hours | Material news imminent (earnings, M&A) |
| LULD (Limit Up/Limit Down) | 5-10 minutes | Price moves outside LULD bands |
| Volatility interruption | 2-5 minutes | Price moves exceed exchange threshold |
| Regulatory halt | Hours to days | SEC or exchange investigation |
| IPO halt | Until opening auction | New listing, pre-first-trade |
| Circuit breaker (market-wide) | 15 min to full day | Broad market decline (see 7.2) |

### 7.2 Circuit Breakers

Circuit breakers are market-wide trading halts triggered by a significant decline in a benchmark index.

**US market circuit breakers** (as of current rules):

| Level | Trigger | Halt Duration | Reference |
|---|---|---|---|
| Level 1 | S&P 500 declines 7% from prior close | 15-minute halt | Applies if triggered before 3:25 PM ET |
| Level 2 | S&P 500 declines 13% from prior close | 15-minute halt | Applies if triggered before 3:25 PM ET |
| Level 3 | S&P 500 declines 20% from prior close | Market closed for remainder of day | Applies at any time |

**System response to circuit breaker**:
1. Halt all equity order entry across all US venues
2. Notify all traders via system alert and squawk box
3. Cancel or freeze all pending algo orders (algos should not resume automatically)
4. Display circuit breaker status with countdown timer
5. Prepare for high volume when trading resumes (capacity planning)
6. Alert risk management (margin requirements may be recalculated)
7. Log all actions taken during the circuit breaker

### 7.3 Exchange Outages

Exchange outages are unplanned events where an exchange stops functioning.

**Outage response procedure**:

1. **Detection**: FIX session drops, market data stops, or exchange issues an official outage notification
2. **Immediate actions**:
   - Alert all traders who route to the affected exchange
   - Display outage status on the trading UI
   - Redirect the smart order router to alternative venues (if available and appropriate)
   - Track open orders that were on the affected exchange (status unknown)
3. **Order management during outage**:
   - New orders: Route to alternative venues or queue for the affected exchange
   - Open orders: Mark as "status uncertain" until exchange confirms
   - Filled orders: Validate fills received before the outage; be prepared for late fill reports when the exchange recovers
4. **Recovery**:
   - When the exchange comes back online, reconcile all order statuses
   - Resend any orders that were lost during the outage
   - Verify that all fills are accounted for
   - Check for duplicate fills (the exchange may replay messages)
5. **Post-incident review**: After resolution, operations reviews the impact:
   - Were any orders lost?
   - Were any fills missed?
   - What was the financial impact of routing to alternative venues?
   - How can the response be improved?

### 7.4 Market Closures and Early Closes

Markets close for holidays and sometimes close early (e.g., the day before a major holiday or during a national emergency).

**Early close handling**:
1. **Calendar management**: Trading calendars are maintained with regular close times and early close times for every market
2. **Advance notification**: The system alerts traders N days before an early close
3. **Order handling**: GTC orders remain; DAY orders are cancelled at early close time
4. **Algo management**: Algos with end-time parameters must be adjusted for early close (e.g., a VWAP algo set to run until 16:00 must be shortened to 13:00)
5. **Batch schedule**: The overnight batch may start earlier on early close days
6. **Cross-market coordination**: An early close in one market may affect cross-market strategies (e.g., FX hedging for equity positions in a market that closed early)
