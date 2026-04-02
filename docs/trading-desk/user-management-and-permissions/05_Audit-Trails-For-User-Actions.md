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
