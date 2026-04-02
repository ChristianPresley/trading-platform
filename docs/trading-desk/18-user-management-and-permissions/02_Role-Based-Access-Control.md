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
