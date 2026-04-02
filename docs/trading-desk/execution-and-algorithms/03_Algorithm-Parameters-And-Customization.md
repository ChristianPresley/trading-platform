## Algorithm Parameters and Customization

### 2.1 Universal Parameters

These parameters are common across most execution algorithms:

| Parameter | Type | Description |
|-----------|------|-------------|
| `Side` | Enum | BUY or SELL |
| `Symbol` | String | Instrument identifier (ticker, ISIN, SEDOL, RIC) |
| `Quantity` | Integer | Total order quantity |
| `OrderType` | Enum | MARKET, LIMIT, PEGGED, etc. |
| `LimitPrice` | Decimal | Limit price (if applicable) |
| `Currency` | String | ISO currency code |
| `Account` | String | Execution account |
| `Strategy` | Enum | Algorithm name (VWAP, TWAP, IS, etc.) |
| `StartTime` | Timestamp | Execution window start |
| `EndTime` | Timestamp | Execution window end |
| `Urgency` | Enum | LOW, MEDIUM, HIGH, AGGRESSIVE, HYPER |
| `DisplayQty` | Integer | Displayed quantity for iceberg behavior |

### 2.2 Urgency Levels

Urgency is the most commonly used parameter to control the speed/impact trade-off. Typical mapping:

| Urgency | Participation Rate | Spread Crossing | Dark Pool Dwell | Typical IS Lambda |
|---------|--------------------|-----------------|-----------------|-------------------|
| PASSIVE | 3-5% of volume | Never | Long (minutes) | 0.01 |
| LOW | 5-10% | Rarely | Moderate | 0.05 |
| MEDIUM | 10-20% | When behind schedule | Moderate | 0.1 |
| HIGH | 20-35% | Frequently | Short (seconds) | 0.5 |
| AGGRESSIVE | 35-50% | Almost always | Minimal | 1.0 |
| HYPER | 50%+ / immediate | Always | None | 10.0 |

### 2.3 Price Limits and Conditional Triggers

| Parameter | Description |
|-----------|-------------|
| `LimitPrice` | Hard price limit; no fills worse than this price |
| `WouldPrice` | "I Would" price; become more aggressive at this level |
| `DiscretionPrice` | Price range within which the algorithm can exercise discretion |
| `TriggerPrice` | Price that activates the algorithm (similar to stop-trigger) |
| `PegType` | PRIMARY_PEG, MIDPOINT_PEG, MARKET_PEG |
| `PegOffset` | Offset from peg reference price (in ticks) |

### 2.4 Venue and Dark Pool Controls

| Parameter | Description |
|-----------|-------------|
| `DarkPoolInclusion` | INCLUDE_ALL, EXCLUDE_ALL, INCLUDE_LIST, EXCLUDE_LIST |
| `DarkPoolList` | Explicit list of dark pool MICs to include/exclude |
| `LitVenueList` | Preferred lit venues |
| `VenueExclusion` | Specific venues to exclude |
| `MinDarkFillSize` | Minimum fill size in dark pools |
| `MidpointOnly` | Only accept dark fills at midpoint or better |
| `BlockOnly` | Only route to block-crossing venues (e.g., BIDS, Liquidnet) |

### 2.5 Sizing Controls

| Parameter | Description |
|-----------|-------------|
| `MinSliceSize` | Minimum child order quantity |
| `MaxSliceSize` | Maximum child order quantity |
| `MaxPctADV` | Maximum order size as percentage of average daily volume |
| `RoundLotOnly` | Only trade in round lots (100 shares) |
| `OddLotAllowed` | Allow odd-lot child orders |
| `MaxNotional` | Maximum notional value per child order |

### 2.6 FIX Protocol Strategy Parameters

Algorithm parameters are transmitted via FIX protocol using tag 847 (StrategyParametersGrp). Common approach:

```
Tag 847 (NoStrategyParameters) = N
  Tag 958 (StrategyParameterName) = "Urgency"
  Tag 959 (StrategyParameterType) = 14 (String)
  Tag 960 (StrategyParameterValue) = "HIGH"
```

Some brokers use custom FIX tags in the 7000+ range or use a single free-text tag (e.g., tag 7600) with a delimited parameter string.

**FIXatdl (Algorithmic Trading Definition Language)**: An industry standard (FIX Protocol Ltd.) that provides XML schema for defining algorithm parameters, validation rules, and GUI rendering hints. Allows OMS/EMS platforms to dynamically render algorithm parameter entry forms based on broker-provided FIXatdl files.
