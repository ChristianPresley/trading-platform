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
