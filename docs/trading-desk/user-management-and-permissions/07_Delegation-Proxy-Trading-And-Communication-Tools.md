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
