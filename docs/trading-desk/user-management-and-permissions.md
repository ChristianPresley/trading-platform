# User Management and Permissions in Professional Trading Desk Applications

## Table of Contents

1. [User Roles and Personas](#1-user-roles-and-personas)
2. [Role-Based Access Control (RBAC)](#2-role-based-access-control-rbac)
3. [Trader Profiles](#3-trader-profiles)
4. [Desk Organization](#4-desk-organization)
5. [Multi-Tenancy](#5-multi-tenancy)
6. [User Session Management](#6-user-session-management)
7. [Audit Trails for User Actions](#7-audit-trails-for-user-actions)
8. [Delegation and Proxy Trading](#8-delegation-and-proxy-trading)
9. [Onboarding and Offboarding Workflows](#9-onboarding-and-offboarding-workflows)
10. [Communication Tools Integration](#10-communication-tools-integration)

---

## 1. User Roles and Personas

Professional trading platforms serve a diverse set of users, each with distinct responsibilities, workflows, and access requirements. A well-designed system models these personas explicitly rather than relying on ad-hoc permissions.

### 1.1 Trader (Execution Trader / Sales Trader)

**Primary function**: Execute orders in the market, manage intraday positions, and interact with broker/dealer counterparties.

**Typical permissions**:
- Full read/write access to order entry, order modification, and order cancellation
- View and interact with market data (Level I/II/III depending on seniority)
- Access to execution algorithms and smart order routing
- View real-time P&L for their own book or assigned books
- Access to trade blotter and execution reports

**Workflow context**: Traders are the most latency-sensitive users. Their interface must prioritize speed of order entry, rapid position awareness, and minimal friction in correcting errors. A senior trader may manage multiple books or act as a desk head, requiring elevated visibility across the desk.

**Subtypes**:
- **Flow trader**: Executes client orders, needs access to client order flow and allocation tools
- **Prop trader**: Trades the firm's capital, needs access to risk limits and strategy-level P&L
- **Sales trader**: Intermediary between sales and execution, needs access to client communication and order negotiation tools
- **Algo trader**: Monitors and adjusts algorithmic execution, needs access to algo parameter tuning and execution analytics

### 1.2 Portfolio Manager (PM)

**Primary function**: Make investment decisions, set portfolio strategy, and oversee asset allocation.

**Typical permissions**:
- Read/write access to portfolio construction and rebalancing tools
- Order initiation (pre-trade) but may not have direct market execution access
- Full visibility of portfolio-level P&L, attribution, and risk metrics
- Access to research, analytics, and model outputs
- Approval authority for trades above certain thresholds

**Workflow context**: PMs often work at a higher level of abstraction than traders. They generate trade ideas or model portfolios that are then routed to the execution desk. The system must support a clear handoff between PM intent and trader execution, with full audit trail of the decision chain.

**Key distinction from trader**: A PM's "order" is an instruction to the desk; it is not a market-facing order until the execution trader routes it. Some platforms model this as a two-phase commit: PM creates an "order ticket" or "indication," and the trader converts it to a live order.

### 1.3 Risk Manager

**Primary function**: Monitor, measure, and control risk exposure across desks, portfolios, and the firm.

**Typical permissions**:
- Read-only access to all positions, orders, and trades across all desks (cross-desk visibility)
- Read/write access to risk limit configuration (VaR limits, Greeks limits, concentration limits, notional limits)
- Authority to issue kill switches, force-close positions, or disable trading for a desk or user
- Access to stress testing and scenario analysis tools
- Access to historical risk reports and trend analysis

**Workflow context**: Risk managers require a "god view" of the firm's exposure, but almost never need to enter orders directly. Their interventions are typically limit modifications, escalations, or emergency position reductions. The system must support both pre-trade risk checks (blocking orders that would breach limits) and post-trade monitoring (alerting on accumulated exposure).

**Critical capability**: The risk manager must be able to override trader permissions in emergency situations (e.g., disabling a trader's ability to enter orders, reducing position limits in real-time during volatile markets).

### 1.4 Compliance Officer

**Primary function**: Ensure regulatory adherence, monitor for market abuse, and enforce internal policies.

**Typical permissions**:
- Read-only access to all trading activity, communications, and audit logs
- Read/write access to compliance rule configuration (restricted lists, pre-trade compliance checks, position limits mandated by regulation)
- Authority to place instruments or counterparties on restricted/watch lists
- Access to surveillance dashboards and alert management
- Ability to flag, investigate, and close compliance cases

**Workflow context**: Compliance operates on a different time horizon than trading. While some checks are real-time (pre-trade compliance), many compliance workflows are T+1 or periodic (trade surveillance, best execution review, transaction reporting). The system must support both modes.

**Regulatory context**: MiFID II, Dodd-Frank, MAR (Market Abuse Regulation), and SEC regulations mandate specific record-keeping, reporting, and surveillance capabilities. The compliance module must generate regulatory reports (EMIR, MiFIR transaction reports, Form PF, 13F filings) and maintain records for the required retention period (typically 5-7 years).

### 1.5 Operations / Middle Office

**Primary function**: Trade lifecycle management from execution through settlement.

**Typical permissions**:
- Read/write access to trade booking, confirmation, allocation, and settlement workflows
- Access to break management and reconciliation tools
- Authority to amend trade details (economic terms corrections, SSI changes, allocation modifications)
- Access to corporate actions processing
- Access to collateral management and margin call workflows

**Workflow context**: Operations staff process the "back end" of every trade. Their workflows are largely exception-driven: most trades flow straight through (STP), and ops intervenes only when something breaks. The system must surface exceptions prominently and provide efficient resolution workflows.

**Key metrics**: STP rate (target: >95% for liquid products), break aging, settlement fail rate.

### 1.6 IT / Support

**Primary function**: System administration, infrastructure management, and user support.

**Typical permissions**:
- Administrative access to user management (create/modify/disable accounts, reset passwords, assign roles)
- Access to system monitoring dashboards (latency, throughput, error rates, connectivity status)
- Configuration access for market data feeds, FIX connections, and external system integrations
- Access to application logs and diagnostic tools
- No access to trading functionality or position data (separation of duties)

**Workflow context**: IT/Support must be able to diagnose and resolve production issues rapidly without being able to see or modify trading data. This is a critical separation-of-duties requirement. A support engineer should be able to restart a FIX session or clear a message queue without seeing the orders in that queue.

### 1.7 Management / Senior Leadership

**Primary function**: Strategic oversight, performance monitoring, and resource allocation.

**Typical permissions**:
- Read-only access to aggregated P&L, risk, and performance dashboards
- Access to desk-level and firm-level reporting
- Approval authority for limit changes above certain thresholds
- Access to headcount and resource planning tools
- No direct trading capabilities

**Workflow context**: Management typically interacts with the trading platform through reporting and dashboard interfaces rather than the core trading UI. Their view is aggregated and historical rather than real-time and granular.

### 1.8 Quantitative Analyst / Researcher

**Primary function**: Develop trading models, pricing models, and analytics.

**Typical permissions**:
- Read access to historical market data and trade data
- Access to backtesting and simulation environments
- Read/write access to model development and deployment tools
- Limited or sandboxed access to production systems (for model deployment)
- Access to data warehouses and analytics databases

**Workflow context**: Quants need broad data access for research but must be carefully controlled when deploying models to production. A common pattern is a promotion pipeline: develop in sandbox, test in UAT, deploy to production with change management approval.

---

## 2. Role-Based Access Control (RBAC)

### 2.1 RBAC Architecture Overview

Professional trading platforms implement multi-dimensional RBAC that goes far beyond simple role assignment. Access control operates across four orthogonal dimensions that are evaluated conjunctively (all must pass):

```
Access Decision = Desk Permissions AND Instrument Permissions AND Function Permissions AND Data Entitlements
```

A user must satisfy all four dimensions to perform an action. This means a trader who has desk access to "US Equities" and instrument access to "Listed Equities" and function access to "Order Entry" can enter equity orders on that desk, but cannot enter fixed income orders even if they have the Order Entry function, because their instrument permission does not cover fixed income.

### 2.2 Desk-Level Permissions

Desk-level permissions control which organizational units a user can interact with.

**Permission model**:
| Permission | Description |
|---|---|
| `desk.view` | See that the desk exists, view aggregated desk-level data |
| `desk.trade` | Enter orders on behalf of the desk |
| `desk.manage` | Modify desk configuration, assign users, set desk-level limits |
| `desk.risk` | View and modify risk parameters for the desk |
| `desk.report` | Generate and view reports for the desk |

**Hierarchy**: Desks are typically organized hierarchically:
```
Firm
  Division (e.g., Global Markets)
    Business Unit (e.g., FICC)
      Desk (e.g., US Rates)
        Book (e.g., Swap Trading Book 1)
```

Permissions can be assigned at any level and inherit downward. A user with `desk.trade` at the "FICC" level can trade on all desks within FICC unless explicitly restricted.

**Cross-desk visibility**: Risk managers and compliance officers typically receive `desk.view` at the Firm level, giving them cross-desk visibility without trading capability. This is critical for detecting cross-desk risk accumulation.

### 2.3 Instrument-Level Permissions

Instrument-level permissions control which asset classes, products, and specific instruments a user can trade.

**Permission granularity** (from broad to narrow):
1. **Asset class**: Equities, Fixed Income, FX, Commodities, Derivatives
2. **Product type**: Listed options, OTC swaps, futures, bonds, repos
3. **Instrument group**: S&P 500 constituents, G10 FX pairs, investment grade bonds
4. **Specific instrument**: AAPL, EUR/USD, US 10Y Treasury

**Common restriction patterns**:
- **Restricted list**: Instruments the firm cannot trade (e.g., due to material non-public information). Maintained by compliance; enforced as a hard pre-trade block.
- **Watch list**: Instruments under compliance scrutiny. Trading is permitted but all activity is flagged for review.
- **Approved instrument list**: Only instruments on this list can be traded. Common for regulated funds with defined investment mandates.
- **Size restrictions**: A user can trade an instrument but only up to a certain notional/quantity per order or per day.

**Implementation consideration**: Instrument permissions must be evaluated at order entry time (pre-trade) and must not introduce measurable latency. A common approach is to load the user's instrument permissions into memory at login and evaluate them locally rather than making a database call per order.

### 2.4 Function-Level Permissions

Function-level permissions control what actions a user can perform, independent of desk or instrument.

**Core trading functions**:
| Function | Description |
|---|---|
| `order.create` | Submit new orders |
| `order.modify` | Amend existing orders (price, quantity, parameters) |
| `order.cancel` | Cancel open orders |
| `order.cancel_all` | Mass cancel (kill switch) |
| `order.view` | View order blotter |
| `execution.algo` | Access algorithmic execution |
| `execution.dma` | Direct market access |
| `allocation.create` | Create post-trade allocations |
| `allocation.approve` | Approve allocations |

**Risk functions**:
| Function | Description |
|---|---|
| `risk.limit.view` | View risk limits |
| `risk.limit.modify` | Modify risk limits |
| `risk.override` | Override pre-trade risk checks |
| `risk.kill_switch` | Activate emergency kill switch |

**Administrative functions**:
| Function | Description |
|---|---|
| `user.create` | Create new user accounts |
| `user.modify` | Modify user accounts and roles |
| `user.disable` | Disable user accounts |
| `config.system` | Modify system configuration |
| `config.market_data` | Configure market data feeds |
| `config.connectivity` | Manage FIX and API connections |

**Four-eyes principle**: Certain functions require approval from a second authorized user. Common four-eyes functions include: risk limit increases above a threshold, adding instruments to/from restricted lists, modifying settlement instructions, and onboarding new counterparties.

### 2.5 Data Entitlements

Data entitlements control what information a user can see, independent of what actions they can take.

**Market data entitlements**:
- Level I (top of book) vs. Level II (depth of book) vs. Level III (full order book)
- Real-time vs. delayed (15/20 minute delay)
- Exchange-specific data agreements (NYSE, NASDAQ, CME, ICE, etc.)
- Derived data permissions (indices, analytics built from licensed data)

**Position and P&L data**:
- Own book only vs. desk-level vs. cross-desk
- Real-time P&L vs. official (COB) P&L
- Attribution data (detailed factor decomposition may be restricted)

**Client data** (for sell-side):
- Client identity and order flow (Chinese wall considerations)
- Aggregated vs. individual client positions

**Implementation consideration**: Market data entitlements often carry significant licensing costs. The system must accurately track and report per-user data consumption to comply with exchange data agreements and manage costs. Unauthorized redistribution of market data can result in substantial exchange penalties.

### 2.6 Permission Evaluation Pipeline

When a user attempts an action (e.g., submit an order), the platform evaluates permissions in a defined pipeline:

```
1. Authentication  - Is the user's session valid?
2. Session state   - Is the session within its permitted hours/devices?
3. Role check      - Does the user's role include the requested function?
4. Desk check      - Is the user authorized for the target desk/book?
5. Instrument check - Is the user authorized for this instrument?
6. Data entitlement - Can the user see the data required for this action?
7. Pre-trade risk   - Does the order pass risk limits?
8. Compliance check - Does the order pass compliance rules (restricted list, concentration, etc.)?
9. Execution        - Order is submitted to market
```

Each step can produce a hard block (reject) or a soft block (warn, require override, require approval). The system must log the outcome of every evaluation step for audit purposes, including the specific rule that triggered a block.

---

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

---

## 5. Multi-Tenancy

### 5.1 Multiple Funds and Desks

Multi-tenancy in trading platforms means supporting multiple independent business units, funds, or even external clients on a shared infrastructure while maintaining strict data and risk separation.

**Tenancy models**:

| Model | Description | Use Case |
|---|---|---|
| **Shared platform, separate desks** | All users on one platform, segregated by desk permissions | Single firm with multiple desks |
| **Shared platform, separate funds** | Platform supports multiple funds with different mandates | Asset manager with fund family |
| **Shared platform, separate clients** | Platform-as-a-service for multiple external clients | Prime broker or outsourced trading |
| **Separate instances** | Fully independent deployments | Maximum isolation (e.g., different regulatory jurisdictions) |

**Data segregation requirements**:
- Position data must be segregated by fund/client
- P&L must be calculated and attributed per fund/client
- Risk limits must be independent per fund/client
- Audit trails must be separable per fund/client for regulatory examination
- Market data entitlements may differ by tenant

### 5.2 Information Barriers (Chinese Walls)

Information barriers are mandatory controls that prevent the flow of material non-public information (MNPI) between different business units within a firm. They are legally required under securities regulations.

**Common barrier configurations**:
- **Investment banking vs. trading**: Bankers with knowledge of pending M&A deals must not share that information with traders
- **Research vs. proprietary trading**: Research analysts with upcoming rating changes must not tip prop traders
- **Different client mandates**: An asset manager running a long fund and a short fund must not use information from one to benefit the other
- **Market making vs. proprietary trading**: Market makers seeing client flow must not use that information for prop trades

**Implementation requirements**:

1. **Access control enforcement**: Users on one side of a barrier cannot view positions, orders, or communications from the other side, even if they have the same role. This is a logical overlay on top of RBAC.

2. **Physical separation**: In many firms, barrier-separated teams are on different floors or in different offices. The system must enforce that login from a barrier-side workstation only grants barrier-appropriate access.

3. **Wall-crossing procedures**: When an individual must be temporarily "brought over the wall" (e.g., a trader consulted on a potential deal), the system must:
   - Log the wall-crossing event with timestamp, reason, and authorizer
   - Restrict the crossed user from trading affected instruments
   - Add affected instruments to the user's restricted list
   - Maintain the restriction until the information becomes public or stale
   - Notify compliance of the wall-crossing

4. **Communication monitoring**: All electronic communications (email, chat, voice) between barrier-separated users must be monitored and/or blocked by default.

5. **Shared services**: Certain functions (IT, operations, risk) may operate across barriers but with restricted information access. These "above the wall" functions must be carefully permissioned to see only what is necessary (e.g., operations can see trade details for settlement but not the trading strategy).

### 5.3 Client Segregation

For firms that manage client assets (asset managers, prime brokers, outsourced trading desks), client segregation is both a regulatory requirement and a fiduciary obligation.

**Segregation requirements**:
- **Asset segregation**: Client assets must be held in segregated accounts, separate from the firm's proprietary assets
- **Order segregation**: Client orders must be identified and handled in accordance with the client's instructions and best execution obligations
- **Fair allocation**: When a block order is executed for multiple clients, the allocation must be fair and pre-determined (not cherry-picked after execution)
- **Confidentiality**: One client's trading activity and positions must not be visible to another client or to the firm's proprietary desk (unless explicitly agreed)

**Allocation policies**:
- **Pro-rata**: Each client gets a proportional share of fills based on their order size
- **Average price**: All clients receive the average execution price across all fills
- **Rotational**: Clients take turns receiving priority allocation
- **Specific**: Allocations are pre-determined before execution

---

## 6. User Session Management

### 6.1 Single Sign-On (SSO)

Trading platforms typically integrate with enterprise identity providers for authentication.

**Common SSO implementations**:
- **SAML 2.0**: Enterprise standard, integrates with Active Directory Federation Services (ADFS), Okta, Ping Identity
- **OAuth 2.0 / OIDC**: Used for API access and modern web interfaces
- **Kerberos**: Used in on-premises environments for seamless Windows authentication
- **Certificate-based authentication**: Hardware tokens or smart cards for high-security environments

**Trading-specific SSO considerations**:
- **Latency**: SSO token validation must not add perceptible latency to the login process. Token caching is essential.
- **Availability**: SSO infrastructure must be as available as the trading platform itself. A failover authentication mechanism (e.g., local credentials) must exist for scenarios where the identity provider is down.
- **Market hours**: Login storms at market open (hundreds of traders logging in within minutes) must be handled without degradation.
- **Multi-application SSO**: A trader may use the OMS, EMS, risk system, and market data terminal simultaneously. SSO should authenticate once and propagate to all applications.

### 6.2 Session Timeouts

Session management in trading has unique requirements because a trader may need their session to remain active throughout market hours but the session must also be secure.

**Timeout policies**:
| Policy | Typical Setting | Rationale |
|---|---|---|
| Idle timeout | 15-30 minutes (non-trading), 2-4 hours (trading) | Prevent unauthorized access on unattended terminals |
| Absolute timeout | 12-16 hours | Force re-authentication daily |
| Market hours override | No idle timeout during market hours | Prevent disruption during active trading |
| Post-market auto-lock | Lock 30 min after market close | Secure terminals after trading day |

**Grace period for orders**: If a session times out, open orders should NOT be automatically cancelled (this could cause market impact). Instead, the session locks (preventing new actions) but existing orders remain live. A separate workflow handles orphaned orders.

### 6.3 Concurrent Session Handling

Traders often work across multiple monitors and applications. The platform must define clear policies for concurrent sessions.

**Concurrent session policies**:
- **Single session per user**: Strictest policy. New login kills the existing session. Prevents unauthorized sharing of credentials but can be disruptive (e.g., if a session did not terminate cleanly).
- **Multiple sessions, same device**: Allow multiple application windows on the same workstation. Most common for trading.
- **Multiple sessions, different devices**: Allow login from multiple devices (e.g., desk terminal and mobile). Required for traders who need mobile access for monitoring.
- **Session transfer**: Allow a user to seamlessly move their session from one device to another (e.g., from desk to disaster recovery site).

**Implementation consideration**: When a user has multiple sessions, order state must be consistent across all sessions in real-time. A fill received on one session must immediately appear on all other sessions.

### 6.4 Device Management

Trading platforms often restrict which devices can access the system, especially for order entry.

**Device controls**:
- **Registered workstations**: Order entry is only permitted from registered and approved workstations on the trading floor. These machines are hardened, monitored, and physically secured.
- **Mobile access**: Read-only position and P&L monitoring may be available on approved mobile devices. Order entry from mobile is typically restricted to emergency scenarios.
- **Remote access**: VPN-based access with additional authentication factors (e.g., hardware token + biometric). Common since COVID-era remote trading.
- **Terminal identification**: Each workstation has a unique identifier that is logged with every action. This is critical for regulatory investigations ("which terminal was that order entered from?").
- **Peripheral controls**: USB ports may be disabled, screenshot capabilities restricted, and printing limited to comply with information security policies.

---

## 7. Audit Trails for User Actions

### 7.1 Regulatory Requirements

Financial regulations mandate comprehensive audit trails. The trading platform must capture, store, and make searchable a complete record of all user actions.

**Key regulations**:
- **SEC Rule 17a-4**: Requires broker-dealers to retain records for 3-6 years in non-rewritable, non-erasable format (WORM storage)
- **MiFID II (RTS 25)**: Requires recording of all communications relating to transactions, retained for 5 years (7 in some cases)
- **MAR**: Requires maintaining order and transaction data for market abuse detection
- **Dodd-Frank**: Requires comprehensive trade reporting and record-keeping for swaps
- **GDPR**: Imposes constraints on how long personal data can be retained, creating tension with regulatory retention requirements

### 7.2 Login/Logout Auditing

Every authentication event must be logged with sufficient detail for forensic investigation.

**Login event record**:
```
LoginEvent
  Timestamp (microsecond precision, UTC)
  UserId
  AuthenticationMethod (SSO, password, certificate, MFA)
  SourceIP
  DeviceId / WorkstationId
  Geolocation (derived from IP)
  Result (success, failure, locked_out)
  FailureReason (if applicable: wrong_password, expired_token, revoked_certificate)
  SessionId (assigned on success)
  ApplicationVersion
```

**Anomaly detection**: The system should flag unusual login patterns:
- Login from new device or location
- Login outside normal hours
- Multiple failed attempts
- Concurrent logins from geographically distant locations
- Login immediately after account modification

### 7.3 Order Entry Auditing

Every order lifecycle event must be logged with full context.

**Order audit record**:
```
OrderEvent
  Timestamp (microsecond precision, UTC)
  EventType (new, modify, cancel, fill, partial_fill, reject, expire)
  OrderId (internal, immutable)
  ClOrdId (client order ID)
  ExchangeOrderId (if routed)
  UserId (who initiated the event)
  Desk, Book, Account
  Instrument (symbol, ISIN, CUSIP, SEDOL)
  Side (buy, sell, short_sell)
  Quantity (ordered, filled, remaining)
  Price (limit price, stop price)
  OrderType, TimeInForce
  Venue (where routed)
  AlgorithmId (if algo order)
  AlgoParameters
  RiskCheckResults (which checks passed/failed)
  ComplianceCheckResults
  SourceApplication
  SourceWorkstationId
  LatencyMetrics (order entry to ack, ack to fill)
```

**Immutability**: Order audit records must be immutable. A trade amendment does not modify the original record; it creates a new record referencing the original. The full chain of amendments must be preservable and reconstructible.

### 7.4 Configuration Change Auditing

Changes to system configuration, risk limits, and user permissions must be logged with before/after state.

**Configuration change record**:
```
ConfigChangeEvent
  Timestamp
  UserId (who made the change)
  ApproverId (if four-eyes required)
  ChangeType (risk_limit, user_permission, system_config, instrument_config)
  EntityAffected (desk, user, instrument, system component)
  FieldName
  OldValue
  NewValue
  Reason (free text, may be required)
  EffectiveFrom
  EffectiveUntil (for temporary changes)
```

### 7.5 Limit Modification Auditing

Risk limit changes are particularly sensitive and require detailed audit trails because they directly affect the firm's risk exposure.

**Limit change audit record**:
```
LimitChangeEvent
  Timestamp
  RequesterId
  ApproverId
  LimitType (VaR, notional, Greeks, loss, position)
  Entity (desk, trader, book, portfolio)
  OldLimit
  NewLimit
  TemporaryFlag (true/false)
  ExpiryTime (if temporary)
  Reason
  MarketContext (what was happening in the market at the time)
  RiskManagerComment
```

### 7.6 Audit Trail Storage and Retrieval

**Storage requirements**:
- Write-once, read-many (WORM) storage for regulatory compliance
- Minimum retention: 7 years (to satisfy the most stringent applicable regulation)
- Tamper-evident (cryptographic hashing of records)
- High-availability for recent data (hot storage for current year)
- Cost-effective archival for historical data (cold storage for older years)

**Retrieval capabilities**:
- Full-text search across all audit fields
- Time-range queries with sub-second response for recent data
- Export to standard formats (CSV, XML, JSON) for regulatory examination
- Correlation across audit types (e.g., "show me all actions by user X on date Y, including logins, orders, and config changes")
- Reconstruction of system state at any historical point in time

---

## 8. Delegation and Proxy Trading

### 8.1 Trading on Behalf Of

Delegation allows one trader to enter orders on behalf of another. This is common during lunch breaks, when a trader is in meetings, or when covering for an absent colleague.

**Delegation model**:
```
DelegationRecord
  DelegatorUserId (the trader whose behalf is being acted on)
  DelegateUserId (the trader who is acting)
  StartTime
  EndTime
  Scope (all_desks, specific_desk, specific_book)
  Permissions (full, read_only, order_entry_only)
  ApprovedBy (desk head or manager)
  Reason
```

**Key requirements**:
- All orders entered under delegation must be tagged with BOTH the delegator and delegate user IDs
- The delegate's own risk limits still apply (they cannot bypass their own limits by acting on behalf of someone with higher limits)
- The delegator's risk limits also apply (the combined activity of the delegator and all their delegates must not exceed the delegator's limits)
- Audit trail clearly shows who actually entered the order and on whose behalf
- Delegation must be explicitly approved (not self-service for the delegate)

### 8.2 Vacation Coverage

When a trader is on extended leave, a more formal coverage arrangement is needed.

**Coverage workflow**:
1. Trader submits vacation request through HR system
2. Desk head assigns a covering trader
3. System creates a delegation record for the coverage period
4. Covering trader receives access to the absent trader's books and positions
5. Daily P&L attribution continues under the absent trader's book but is flagged as "under coverage"
6. On the absent trader's return, the delegation is automatically revoked
7. A handoff report is generated showing all activity during the coverage period

**Position responsibility**: The covering trader has a duty to manage the absent trader's positions responsibly. The system should highlight any positions approaching risk limits and alert the desk head if limits are breached during coverage.

### 8.3 Escalation Procedures

Escalation is the process of elevating a decision to a more senior person when the current user lacks authority.

**Common escalation triggers**:
- Order exceeds the trader's size limit
- Risk limit breach requires temporary increase
- Compliance pre-trade check failure requires override
- System error requires IT intervention
- Client dispute requires management decision
- Unusual market conditions require desk head approval

**Escalation workflow**:
1. System detects the condition requiring escalation
2. System identifies the appropriate escalation target based on:
   - Type of escalation (risk, compliance, operational, management)
   - Current user's reporting line
   - Availability of escalation targets (if primary is unavailable, go to secondary)
3. Notification is sent to the escalation target (in-app alert, SMS, phone call)
4. Escalation target reviews the request with full context
5. Decision is recorded (approve, deny, modify) with reason
6. Original user is notified of the decision
7. If approved, the action proceeds with the escalation logged as the approval

**Escalation SLA**: Each escalation type should have a defined response time SLA. For example, a pre-trade risk limit escalation during market hours should have a 5-minute SLA, while a compliance override might have a 15-minute SLA.

---

## 9. Onboarding and Offboarding Workflows

### 9.1 New User Onboarding

Onboarding a new user to a trading platform is a multi-step process involving IT, compliance, risk management, and the user's business line.

**Onboarding workflow**:

**Step 1: Request and Approval** (Day -5 to Day -3)
- Hiring manager submits a new user request through the user administration portal
- Request specifies: name, role, desk assignment, start date, required system access
- Approval chain: desk head -> risk manager -> compliance -> IT security

**Step 2: Identity and Access Provisioning** (Day -3 to Day -1)
- IT creates accounts in: Active Directory, trading platform, email, chat systems
- Role-based permissions template is applied based on the user's role
- Desk-specific permissions are configured (desk assignment, book access, instrument permissions)
- Market data entitlements are provisioned (exchange agreements signed if needed)
- Hardware is provisioned (workstation, monitors, phone, Bloomberg terminal)

**Step 3: Risk Limit Configuration** (Day -2 to Day -1)
- Risk management sets per-trader limits based on role and seniority
- Limits are typically conservative for new joiners and increased over time as the trader proves competent
- New trader limits: 50% of standard limits for the first 30 days
- Intraday loss limit set at a level appropriate for the expected trading activity

**Step 4: Compliance Setup** (Day -2 to Day -1)
- Personal account trading disclosure forms completed
- Compliance training completed and recorded
- Restricted list acknowledgment signed
- If applicable, information barrier side assignment confirmed
- Regulatory registration (e.g., Series 7, FCA approved person) verified

**Step 5: Training and Certification** (Day 1 to Day 5)
- Platform training (order entry, risk monitoring, settlement workflow)
- Compliance training (market abuse, best execution, record-keeping)
- Emergency procedure training (kill switch, failover, communication protocols)
- Supervised trading period (all orders reviewed by desk head for first N days)

**Step 6: Go-Live** (Day 5+)
- Restrictions gradually lifted as the user demonstrates competence
- Risk limits increased to standard levels after the probation period
- Full independent trading access granted

### 9.2 User Offboarding

Offboarding is equally critical and often more urgent (especially in cases of termination for cause).

**Immediate offboarding** (for involuntary termination or compliance concern):
1. Disable all trading access immediately (zero-delay, IT on standby)
2. Cancel all open orders belonging to the user
3. Lock the user's workstation
4. Revoke VPN and remote access
5. Disable chat and communication access
6. Assign all open positions to a covering trader
7. Preserve all data and communications (litigation hold if applicable)
8. Change any shared passwords or service accounts the user had access to
9. Revoke access to third-party systems (Bloomberg, exchange portals)
10. Collect hardware (laptop, phone, access badge, hardware tokens)

**Planned offboarding** (for resignation or transfer):

**Week -2: Notification**
- User's departure is communicated to relevant teams
- Position transfer plan is developed (which positions to close, which to transfer)
- Knowledge transfer scheduled

**Week -1: Transition**
- User begins transferring positions and responsibilities to successors
- Open orders are reviewed and reassigned where needed
- Client relationships are formally transitioned
- Outstanding breaks or exceptions are resolved or transferred

**Day 0: Access Termination**
- All system access is disabled at a specified time (typically after market close)
- Email auto-reply is configured
- Delegation records pointing to this user are terminated
- Final P&L and position report generated for the user's books

**Post-departure**:
- Account remains in the system in "disabled" state (not deleted) for audit trail continuity
- Data retention per regulatory requirements
- Any outstanding compliance reviews for the user's activity are completed
- Personal account trading declarations are finalized

### 9.3 Role Changes and Internal Transfers

When a user changes roles (e.g., from trader to risk manager, or transfers to a different desk), the system must handle this as a combined offboard/onboard.

**Transfer workflow**:
1. Remove old desk/book/instrument permissions
2. Apply new role template
3. Configure new desk/book/instrument permissions
4. Adjust risk limits for new role
5. Update information barrier assignment if applicable
6. Retain audit history from previous role (linked to same user ID)
7. Apply any mandatory training requirements for the new role

---

## 10. Communication Tools Integration

### 10.1 Bloomberg Terminal and Bloomberg Chat (IB)

Bloomberg is the dominant market data and communication platform in financial services. Integration with the trading platform is essential.

**Bloomberg IB (Instant Bloomberg) integration**:
- **Order sharing**: Traders can send trade ideas or order tickets via Bloomberg chat. The trading platform can parse these messages and pre-populate order entry fields.
- **Execution confirmation**: Automated messages sent to clients or counterparties confirming trade execution details.
- **Price requests**: For OTC instruments, RFQ workflows may use Bloomberg MSG or IB to solicit quotes from dealers.
- **Compliance capture**: All Bloomberg IB communications must be captured and stored for compliance (typically via Bloomberg Vault or a third-party archival solution).

**Bloomberg EMSX/TSOX integration**:
- EMSX (Execution Management System) can be used as the execution layer, with the OMS sending orders to EMSX for routing
- TSOX (Trade Order Management Solutions) provides order management capabilities
- The trading platform may integrate with Bloomberg for FIX connectivity, using Bloomberg as a FIX hub

### 10.2 Symphony

Symphony is the financial industry's purpose-built secure communications platform, designed as a compliant alternative to consumer messaging apps.

**Symphony integration features**:
- **Chatbots**: The trading platform can deploy Symphony bots that allow traders to query positions, P&L, and order status via chat commands
- **Structured messages**: Symphony supports structured data messages (cards) that can display trade details, risk alerts, and approval requests in a rich format
- **Workflow integration**: Approval requests (e.g., limit increases, compliance overrides) can be sent as Symphony messages with approve/deny buttons
- **Room-based collaboration**: Trading desks can have dedicated Symphony rooms where system alerts, P&L summaries, and market events are automatically posted
- **End-to-end encryption**: Symphony provides E2EE, which is important for sensitive trading communications but can complicate compliance archival

### 10.3 Refinitiv Eikon Messenger (now LSEG)

Refinitiv Eikon Messenger (formerly Reuters Messenger) is the primary communication tool for firms in the Refinitiv ecosystem.

**Integration capabilities**:
- **Contextual communication**: Send instrument-specific messages with embedded market data and charts
- **Directory services**: Access to the Refinitiv directory for counterparty contact information
- **Trade negotiation**: Support for voice/chat-based trade negotiation with audit trail
- **Data sharing**: Share Eikon-sourced analytics, charts, and news via messenger

### 10.4 Internal Chat and Alerting

Beyond external communication platforms, trading systems need internal communication for operational coordination.

**Internal communication requirements**:
- **System alerts**: Real-time notifications for risk limit breaches, system errors, market events, and compliance alerts. These must be delivered via in-app notification, desktop alert, and optionally mobile push.
- **Desk squawk box**: Digital equivalent of the traditional squawk box. A broadcast channel where important market information and desk instructions are communicated to all desk members simultaneously.
- **Escalation notifications**: Automated routing of escalation requests to the appropriate person via the most effective channel (in-app, chat, SMS, phone call) based on urgency and the target's availability.
- **End-of-day summaries**: Automated generation and distribution of daily P&L, position, and risk summaries to relevant stakeholders.

**Communication compliance requirements**:
- All electronic communications related to trading must be captured and archived
- Communications must be searchable and producible for regulatory examination
- Personal device communications about trading activity must be captured (this is a growing regulatory focus area)
- Voice communications on trading turrets must be recorded and retained
- Cross-channel correlation: The ability to link a chat message discussing a trade idea with the actual order that was subsequently entered

### 10.5 Integration Architecture

Communication tool integrations should follow a hub-and-spoke architecture:

```
Trading Platform Core
  Communication Integration Hub
    Bloomberg IB Adapter
    Symphony Adapter
    Eikon Messenger Adapter
    Email Adapter (SMTP/Exchange)
    SMS/Voice Adapter (Twilio, Bandwidth)
    Internal Alert Engine
  
  Message Archive
    All messages captured in canonical format
    Full-text indexed and searchable
    Linked to user sessions and trading activity
    Retained per regulatory requirements
```

**Key architectural principles**:
- All communication adapters write to a common message archive
- Outbound messages are templated and auditable
- Inbound messages can trigger workflows (e.g., a parsed RFQ response auto-populates a trade ticket)
- Communication failures are logged and retried with alerting
- The system must handle communication platform outages gracefully (queue and retry, or fallback to alternate channel)
