## Manual Intervention Workflows

### 8.1 Manual Trade Entry

Despite the drive toward electronic execution, manual trade entry remains necessary for certain workflows.

**Scenarios requiring manual entry**:
- Voice-traded OTC instruments (bespoke derivatives, illiquid bonds, block trades negotiated by phone)
- Trades executed on platforms not integrated with the OMS
- Historical trade corrections or adjustments
- Inter-entity transfers (moving positions between legal entities)
- Cash bookings (fee payments, margin calls, corporate action proceeds)

**Manual trade entry workflow**:

1. **Entry**: The authorized user enters the trade details via a dedicated manual trade entry form. All fields that are normally auto-populated from electronic execution must be manually entered.
2. **Validation**: The same validation rules apply as for electronic trades (price reasonability, limit checks, compliance checks). However, certain checks may be relaxed for specific manual entry types (e.g., off-market price check for an inter-entity transfer at carrying value).
3. **Four-eyes approval**: All manual trades require approval from a second authorized user before booking. The approver reviews the trade details and confirms they are correct and legitimate.
4. **Booking**: Once approved, the trade is booked and flows through the normal downstream processes.
5. **Documentation**: Manual trades must have supporting documentation attached:
   - For voice trades: Recording reference, counterparty confirmation (email, fax, SWIFT)
   - For corrections: Original trade reference, reason for correction, approval
   - For transfers: Transfer request form, approval from both desks

**Audit requirements**: Manual trades receive heightened scrutiny in compliance surveillance because they bypass the electronic audit trail of normal order flow. The system should flag all manual entries for compliance review.

### 8.2 Trade Amendments

Trade amendments change the economic or non-economic terms of an existing trade after it has been booked.

**Amendment types**:

| Type | Examples | Approval Required |
|---|---|---|
| **Economic amendment** | Price, quantity, notional, settlement date | Four-eyes, desk head, counterparty agreement |
| **Non-economic amendment** | Account, book, strategy tag, trader ID | Four-eyes |
| **SSI amendment** | Settlement instructions | Four-eyes, operations manager |
| **Regulatory amendment** | Reporting flags, LEI, trading capacity | Compliance |

**Amendment workflow**:
1. User requests the amendment, specifying the field(s) to change
2. System displays old value and new value side-by-side
3. System validates the amendment (same rules as new trade entry)
4. Approver reviews and approves
5. System creates a new version of the trade (original version preserved for audit)
6. If the trade has already been confirmed, a cancellation and re-confirmation are sent to the counterparty
7. If the trade has already settled, a correction may require a cash adjustment
8. All amendments are logged with full before/after detail

**Amendment cut-off**: Amendments have time-based restrictions:
- Before confirmation: Relatively straightforward
- After confirmation but before settlement: Requires counterparty agreement
- After settlement: Requires cash adjustment, counterparty agreement, and potentially custodian coordination

### 8.3 Off-Market Trades

Off-market trades are trades executed at a price that is significantly different from the prevailing market price. They are legitimate in certain contexts but are also a red flag for compliance.

**Legitimate off-market scenarios**:
- Inter-entity transfers at carrying value (no market execution, just moving between books)
- Closing out OTC derivatives at a negotiated price (accounting for CVA/DVA, CSA terms)
- Portfolio transfers at a negotiated package price
- Give-up/take-up trades where the give-up price differs from the original execution price

**Off-market trade handling**:
1. System detects that the trade price is outside the configurable tolerance (e.g., >1% from mid-market)
2. System blocks the trade and requires additional justification
3. User provides a reason code (inter-entity transfer, portfolio transfer, etc.) and supporting narrative
4. Compliance is automatically notified for all off-market trades
5. Desk head and operations manager must approve
6. The trade is booked with an "off-market" flag for ongoing surveillance

### 8.4 Voice Trades

Voice trades (phone-negotiated trades) are still common in OTC markets, block trading, and less liquid instruments.

**Voice trade workflow**:
1. **Negotiation**: Trader negotiates with counterparty by phone (all calls recorded on turret system)
2. **Verbal agreement**: Both parties verbally agree on terms (read-back of key terms is standard practice)
3. **Manual entry**: Trader or operations enters the trade into the system
4. **Confirmation**: System generates a confirmation sent to the counterparty's operations team
5. **Matching**: Counterparty confirms the terms, creating a matched trade
6. **Recording link**: The call recording reference is attached to the trade record
7. **Compliance review**: Voice trade activity is sampled for compliance review

**Voice trade risks**:
- Human error in translating verbal terms to system entry
- Delayed entry (trade executed but not entered for hours)
- Dispute risk (different recollection of agreed terms)

**Mitigation**: Read-back procedures, immediate entry SLAs (must be entered within 15 minutes of execution), automatic flagging of voice trades for compliance review.
