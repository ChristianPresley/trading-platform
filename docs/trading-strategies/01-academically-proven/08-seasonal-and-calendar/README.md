# 08 - Seasonal and Calendar Strategies

Strategies exploiting recurring calendar-based patterns in asset returns. These anomalies arise from institutional cash flow cycles, behavioral biases around specific dates, and structural features of market microstructure tied to the calendar.

## Strategies

| # | Strategy | Efficacy | Complexity | Crypto Applicable |
|---|----------|----------|------------|-------------------|
| 01 | [Turn of the Month](01_Turn-Of-The-Month.md) | 4/5 | Simple | Adaptable |
| 02 | [Options Expiration Week](02_Options-Expiration-Week.md) | 3/5 | Moderate | Adaptable |
| 03 | [January Barometer](03_January-Barometer.md) | 3/5 | Simple | Adaptable |
| 04 | [12-Month Cycle Cross-Section](04_12-Month-Cycle-Cross-Section.md) | 3/5 | Complex | No |
| 05 | [Payday Anomaly](05_Payday-Anomaly.md) | 2/5 | Simple | No |
| 06 | [Turnaround Tuesday](06_Turnaround-Tuesday.md) | 3/5 | Simple | Adaptable |
| 07 | [Holiday Effects](07_Holiday-Effects.md) | 3/5 | Simple | Adaptable |

## Key Themes

- **Institutional cash flows**: Turn-of-month and payday effects are driven by pension fund contributions and paycheck investment cycles
- **Options market structure**: Expiration-week dynamics create predictable hedging flows from market makers
- **Behavioral patterns**: Weekend pessimism and pre-holiday optimism produce systematic return asymmetries
- **Cross-sectional seasonality**: Individual stocks exhibit persistent same-month return patterns across years

## General Considerations

Calendar effects are among the most studied anomalies in finance. Many have weakened since their initial publication but remain statistically detectable. Transaction costs and slippage must be carefully modeled, as the per-trade alpha is often small. Combining multiple calendar signals can improve robustness.
