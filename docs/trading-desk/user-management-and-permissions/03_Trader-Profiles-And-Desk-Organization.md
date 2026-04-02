## 3. Trader Profiles

### 3.1 Profile Structure

A trader profile encapsulates the user's preferences, defaults, and constraints. It is loaded at login and applied throughout the session. Changes to the profile take effect either immediately or at next login, depending on the setting.

**Profile categories**:

```
TraderProfile
  PersonalInfo
    UserId, DisplayName, Email, Phone, BloombergId, SymphonyId
  TradingDefaults
    DefaultDesk, DefaultBook, DefaultAccount
    DefaultOrderType (Limit/Market/Stop)
    DefaultTimeInForce (Day/GTC/IOC/FOK)
    DefaultCurrency
    DefaultSettlementInstructions
  DisplayPreferences
    DefaultWorkspaceLayout
    BlotterColumns and sort order
    Color themes and alert preferences
    Market data display format (fractional, decimal, 32nds)
    Timezone preference
  VenuePreferences
    PreferredVenues (ordered list per asset class)
    VenueExclusions (venues to never route to)
    DarkPoolOptIn/OptOut settings
    BrokerPreferences (for voice/RFQ workflows)
  AlgoPreferences
    DefaultAlgo per asset class
    DefaultAlgoParameters (urgency, participation rate, start/end time)
    CustomAlgoProfiles (named parameter sets for common strategies)
  RiskLimits (per-trader)
    MaxOrderSize (by instrument type)
    MaxDailyNotional
    MaxOpenOrders
    MaxPositionSize
    LossLimit (intraday stop-loss)
  Hotkeys
    Custom keyboard shortcuts for order entry
    One-click trading configuration
```

### 3.2 Default Settings

Default settings reduce the number of fields a trader must fill in for each order, improving speed and reducing errors.

**Order defaults hierarchy** (most specific wins):
1. Instrument-specific defaults (e.g., "for AAPL, always use VWAP algo")
2. Asset class defaults (e.g., "for all equities, default to Limit order")
3. Desk defaults (e.g., "on US Equities desk, default account is PROP-USEq-01")
4. Global defaults (e.g., "default TIF is Day")

**Smart defaults**: Advanced systems learn from a trader's behavior and suggest defaults based on recent patterns. For example, if a trader has been using a TWAP algo with 20% participation rate for the past hour, the system pre-fills those parameters for the next order.

### 3.3 Preferred Venues and Routing

Venue preferences control where orders are routed and how the smart order router (SOR) behaves for a given user.

**Configuration elements**:
- **Venue priority list**: Ordered list of execution venues per asset class. The SOR uses this as a starting preference, subject to best execution requirements.
- **Venue exclusions**: Venues the trader does not want to interact with (e.g., certain dark pools, specific ECNs).
- **Broker routing preferences**: For OTC instruments or RFQ workflows, the preferred set of dealers to quote.
- **Internalization preferences**: Whether to route to the firm's internal crossing engine before external venues.

**Best execution constraint**: Under MiFID II and SEC regulations, venue preferences are advisory. The SOR must still route to achieve best execution. If the trader's preferred venue does not offer the best price, the SOR should route elsewhere and log the reason.

### 3.4 Algorithmic Execution Preferences

Traders who use algos frequently build up a library of named configurations.

**Example algo profile**:
```
Profile Name: "Standard VWAP - Low Urgency"
Algorithm: VWAP
Parameters:
  Start Time: Market Open + 15 min
  End Time: Market Close - 30 min
  Participation Rate: 10%
  Max Spread: 5 bps
  Dark Pool Opt-In: Yes
  Anti-Gaming: Enabled
  Min Fill Size: 100 shares
```

A trader may have dozens of these profiles for different market conditions and order characteristics. The platform should support profile categories, search, and quick-select from the order entry widget.

### 3.5 Per-Trader Risk Limits

Per-trader limits are a layer of risk control below desk-level limits. They are typically set by the desk head or risk management and are not modifiable by the trader themselves.

**Common per-trader limits**:
| Limit Type | Example | Enforcement |
|---|---|---|
| Max single order size | 50,000 shares / $5M notional | Pre-trade hard block |
| Max daily notional | $100M | Pre-trade hard block when cumulative limit reached |
| Max open orders | 200 concurrent | Pre-trade hard block |
| Max position size | $25M per instrument | Pre-trade soft block (warning, then block) |
| Intraday loss limit | -$500K | Auto-cancel all open orders, disable new order entry |
| Fat finger check | Order > 10x ADV | Pre-trade soft block requiring confirmation |
| Price reasonability | Order price > 5% from last trade | Pre-trade soft block requiring confirmation |

**Limit escalation**: When a trader hits a limit, the standard workflow is:
1. System blocks the order and displays the specific limit violated
2. Trader requests a temporary limit increase from desk head or risk manager
3. Desk head/risk manager reviews and approves/denies (logged)
4. If approved, the limit is temporarily raised (with expiry time)
5. All temporary increases are reported in the EOD risk summary

---

## 4. Desk Organization

### 4.1 Trading Desk Structure

A trading desk is the fundamental organizational unit in a trading floor. It represents a group of traders who trade related instruments, share risk limits, and report to a common desk head.

**Desk attributes**:
```
TradingDesk
  DeskId
  DeskName (e.g., "US Equity Cash", "G10 Rates", "EM Credit")
  DeskHead (user reference)
  Division
  BusinessUnit
  LegalEntity
  BaseCurrency
  TradingHours (start, end, timezone)
  ActiveStatus (active, suspended, closed)
  RiskLimits (desk-level VaR, notional, Greeks)
  AssociatedBooks[]
  AssociatedTraders[]
  CostCenter
  RegulatoryReportingEntity
```

### 4.2 Book Hierarchy

Books (also called "trading books" or "risk books") are the fundamental unit of position and P&L accounting. Every trade must be booked to exactly one book.

**Book types**:
- **Trading book**: Actively traded positions. Subject to market risk capital requirements.
- **Banking book**: Hold-to-maturity positions. Subject to credit risk capital requirements.
- **Hedge book**: Positions held specifically to hedge other exposures.
- **Error book / Suspense book**: Temporary holding for trades that could not be booked to a proper book. Must be cleared daily.
- **House book**: Firm's own proprietary positions.
- **Client book**: Positions held on behalf of clients (agency trading).

**Book hierarchy example**:
```
Legal Entity: Trading Corp US LLC
  Desk: US Equity Cash
    Book: USEq-PropTrading-01 (prop)
    Book: USEq-PropTrading-02 (prop)
    Book: USEq-ClientFlow-01 (agency)
    Book: USEq-Hedge-01 (hedge)
    Book: USEq-Error-01 (suspense)
  Desk: US Equity Derivatives
    Book: USEqDeriv-MM-01 (market making)
    Book: USEqDeriv-Exotic-01 (exotic options)
    Book: USEqDeriv-Hedge-01 (hedge)
```

### 4.3 Strategy and Fund Hierarchies

Beyond desks and books, positions are often tagged with strategy and fund dimensions for performance attribution and reporting.

**Strategy hierarchy**:
```
Strategy: Relative Value
  Sub-strategy: Pairs Trading
    Signal: Mean Reversion - Tech Sector
  Sub-strategy: Index Arbitrage
    Signal: SPX vs ES Basis
```

**Fund hierarchy** (for asset managers):
```
Fund Family: Global Equity Funds
  Fund: Global Equity Growth Fund
    Share Class: Institutional
    Share Class: Retail
    Share Class: Offshore
  Fund: US Large Cap Fund
    Sleeve: Core
    Sleeve: Satellite
```

### 4.4 Legal Entity Structures

Trading firms operate through multiple legal entities for regulatory, tax, and risk isolation purposes. The trading platform must accurately model these structures because they affect:

- **Regulatory reporting**: Different entities report to different regulators
- **Netting**: Trades can only be netted within a legal entity (or across entities with netting agreements)
- **Capital allocation**: Each entity has its own capital base and regulatory capital requirements
- **Settlement**: Different entities have different settlement accounts and custodians
- **Tax treatment**: Different jurisdictions impose different tax obligations

**Example multi-entity structure**:
```
Holding Company
  Trading Corp US LLC (SEC/FINRA regulated, US trades)
  Trading Corp UK Ltd (FCA regulated, European trades)
  Trading Corp Singapore Pte Ltd (MAS regulated, APAC trades)
  Trading Corp Cayman Ltd (offshore fund vehicle)
```

Each entity must be selectable at order entry, and the system must enforce that a trade on a US exchange is booked to the correct US entity (or an entity with the appropriate exchange membership/access agreement).
