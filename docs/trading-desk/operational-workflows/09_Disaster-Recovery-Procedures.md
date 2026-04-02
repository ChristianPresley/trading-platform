## Disaster Recovery Procedures

### 10.1 Disaster Recovery Architecture

A trading platform's disaster recovery (DR) architecture must ensure business continuity during partial or complete failure of the primary site.

**Recovery objectives**:
| Metric | Definition | Target |
|---|---|---|
| **RTO** (Recovery Time Objective) | Maximum acceptable time to restore trading | < 30 minutes for critical functions, < 4 hours for all functions |
| **RPO** (Recovery Point Objective) | Maximum acceptable data loss | < 1 minute (near-zero for order/position data) |
| **MTPD** (Maximum Tolerable Period of Disruption) | Maximum time the business can survive without the system | < 24 hours |

**DR configurations**:

| Configuration | Description | RTO | RPO | Cost |
|---|---|---|---|---|
| **Active-Active** | Both sites handle live traffic simultaneously | Near zero | Zero | Highest |
| **Active-Warm** | DR site has systems running and data replicated, but not serving traffic | 15-30 min | < 1 min | High |
| **Active-Cold** | DR site has hardware but systems are not running | 2-4 hours | Hours (last backup) | Medium |
| **Cloud DR** | DR infrastructure in cloud (AWS, Azure), scaled on demand | 30-60 min | < 5 min | Variable |

**For trading platforms**: Active-Active or Active-Warm is the standard. Active-Cold is insufficient for firms that need to resume trading during the same session.

### 10.2 Failover Testing

Failover testing verifies that the DR site can assume production responsibilities within the defined RTO.

**Test types**:

| Test Type | Frequency | Scope | Impact on Production |
|---|---|---|---|
| **Tabletop exercise** | Quarterly | Review procedures, identify gaps | None |
| **Component failover** | Monthly | Fail over individual components (database, app server) | Minimal |
| **Full site failover** | Semi-annually | Fail over all systems to DR site | Production runs on DR for the test period |
| **Unannounced test** | Annually | DR team is not warned in advance | Measures actual response time |

**Full site failover test procedure**:

1. **Pre-test** (T-1 week):
   - Notify all stakeholders (trading, operations, risk, compliance, IT)
   - Verify DR site readiness (hardware, network, data replication)
   - Document current state (positions, open orders, system configuration)
   - Brief all participants on the test plan and escalation procedures

2. **Failover execution** (Test day):
   - Announce failover start time
   - Stop production systems at primary site (simulate site loss)
   - Activate DR site systems
   - Verify data consistency (positions, orders, reference data match pre-failover state)
   - Verify external connectivity (FIX sessions to exchanges and brokers, market data feeds)
   - Execute test trades on DR site
   - Run P&L and risk calculations on DR site
   - Verify client-facing services (web portal, API, reporting)

3. **Validation checklist**:
   - All trading desks can enter and execute orders
   - Market data is live and accurate
   - Positions match pre-failover positions
   - Risk limits are enforced
   - Compliance checks are active
   - Settlement processing functions
   - Regulatory reporting can be generated
   - Communications (phone, chat, email) are functional

4. **Failback**:
   - Migrate back to primary site
   - Verify data consistency after failback
   - Confirm all systems are nominal on primary site

5. **Post-test review**:
   - Document actual RTO achieved
   - Document any data discrepancies
   - Document any system failures during the test
   - Update procedures based on lessons learned
   - Report results to management and regulators (if required)

### 10.3 Backup Site Activation

When a real disaster occurs (not a test), the activation procedure follows a more urgent path.

**Activation triggers**:
- Physical site loss (fire, flood, power failure, building access denied)
- Network failure (complete loss of connectivity from primary site)
- System failure (cascading failure that cannot be resolved within the RTO)
- Cybersecurity incident (ransomware, data breach requiring system isolation)

**Activation decision chain**:
1. Incident is detected and reported to the on-call operations team
2. Operations assesses severity and estimated time to resolve
3. If estimated resolution time exceeds RTO, operations recommends DR activation
4. DR activation authority (typically CTO, COO, or designated DR coordinator) makes the go/no-go decision
5. DR activation is announced to all stakeholders via the emergency communication system

**During DR operations**:
- Reduced functionality may be acceptable (e.g., only core trading, not all analytics)
- Headcount at DR site may be limited (prioritize critical roles: traders, operations, IT support)
- Communication with counterparties, exchanges, and regulators about the DR event
- Enhanced monitoring of DR site performance
- Regular status updates to management

### 10.4 Communication Protocols

Clear communication during a disaster is as important as the technical failover.

**Communication plan**:

| Audience | Channel | Responsible | Timing |
|---|---|---|---|
| Trading desks | Squawk box, SMS, phone tree | Desk heads | Immediate |
| Operations | SMS, phone tree | Operations manager | Immediate |
| IT team | Incident management system (PagerDuty, ServiceNow) | On-call engineer | Immediate |
| Senior management | SMS, phone call | CTO/COO | Within 5 minutes |
| Exchanges/CCPs | Designated contact, email | Operations | Within 15 minutes |
| Regulators | Designated regulatory contact | Compliance | Within 30 minutes (or per regulatory requirement) |
| Clients | Email, client portal notice | Client services | Within 1 hour |
| Counterparties | Email, phone | Operations | Within 1 hour |
| Media (if applicable) | Press statement | Communications/PR | As needed |

**Communication template** (for counterparties/clients):
```
Subject: [FIRM NAME] - Business Continuity Event Notification

We are writing to inform you that [FIRM NAME] has activated its business 
continuity plan due to [brief description].

Trading operations: [Active / Suspended / Limited]
Expected resolution: [Time estimate]
Settlement processing: [Normal / Delayed]
Contact for urgent matters: [Name, phone, email]

We will provide updates every [frequency]. Please direct any questions 
to [contact details].
```
