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
