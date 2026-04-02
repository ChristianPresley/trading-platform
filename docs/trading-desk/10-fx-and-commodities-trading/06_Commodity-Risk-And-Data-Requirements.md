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
