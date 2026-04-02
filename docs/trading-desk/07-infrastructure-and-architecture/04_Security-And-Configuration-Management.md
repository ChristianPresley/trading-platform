## Security Architecture

### Network Segmentation

Trading infrastructure requires strict network segmentation:

```
┌──────────────────────────────────────────────────┐
│                    Internet                        │
└───────────────────┬──────────────────────────────┘
                    │ (DMZ / WAF / Reverse Proxy)
┌───────────────────v──────────────────────────────┐
│              Corporate Zone                       │
│  (Email, Web, Office applications)                │
└───────────────────┬──────────────────────────────┘
                    │ (Firewall: strict rules)
┌───────────────────v──────────────────────────────┐
│            Trading DMZ                            │
│  (API gateways, FIX gateways, web UIs)           │
└───────────────────┬──────────────────────────────┘
                    │ (Firewall: application-aware)
┌───────────────────v──────────────────────────────┐
│           Trading Core Zone                       │
│  (OMS, EMS, Risk Engine, Matching)                │
│  (No direct internet access)                      │
└───────────────────┬──────────────────────────────┘
                    │ (Dedicated cross-connects)
┌───────────────────v──────────────────────────────┐
│          Exchange Connectivity Zone               │
│  (Exchange gateways, market data feed handlers)   │
│  (Most restricted; only exchange traffic)         │
└──────────────────────────────────────────────────┘
```

### Encryption

| Layer | Requirement | Implementation |
|-------|-------------|----------------|
| **FIX sessions** | TLS 1.2+ for all external FIX connections | Stunnel, native TLS in FIX engine, or exchange-mandated encryption |
| **Internal messaging** | TLS or mTLS for cross-zone communication | Certificate-based mutual authentication |
| **Database connections** | TLS for all database connections | Database-native TLS configuration |
| **Data at rest** | Encrypt sensitive data (PII, credentials, trade data) | Transparent Data Encryption (TDE) for SQL Server/Oracle; LUKS for disk encryption |
| **Key management** | Centralized key management | HashiCorp Vault, AWS KMS, Azure Key Vault, Thales HSM |

### Access Controls

- **Role-Based Access Control (RBAC)**: Traders, risk managers, compliance officers, operations staff, and developers have different permissions
- **Entitlement management**: Which users can trade which instruments on which venues with which order types
- **Four-eyes principle**: Critical changes (risk limits, algo parameters, user permissions) require approval from a second authorized person
- **Privileged Access Management (PAM)**: CyberArk, Delinea (Thycotic), BeyondTrust for administrative access to production systems
- **Service accounts**: Trading applications use service accounts with minimum necessary permissions; credentials rotated regularly

### Multi-Factor Authentication

- **Production access**: MFA required for all production system access (SSH, RDP, admin consoles)
- **Trading operations**: Traders authenticate to the trading platform with MFA
- **VPN**: MFA for all remote access
- **Methods**: Hardware tokens (YubiKey, RSA SecurID), TOTP authenticator apps, push-based (Duo, Okta Verify)

### Audit Logging

Regulatory requirements (SEC Rule 17a-4, MiFID II, MAR) mandate comprehensive audit logging:

- **All order events**: Every order submission, modification, cancellation, fill, and rejection
- **All user actions**: Login, logout, configuration changes, permission changes
- **All system events**: Application startup/shutdown, failover events, connectivity changes
- **Market data**: Timestamped record of received market data (for best execution and surveillance)
- **Retention**: Typically 5-7 years depending on jurisdiction; WORM (Write Once Read Many) storage required in some jurisdictions
- **Immutability**: Audit logs must be tamper-evident; append-only storage; cryptographic hashing chains
- **Time synchronization**: NTP or PTP (Precision Time Protocol, IEEE 1588) synchronization to UTC; sub-microsecond accuracy required for MiFID II clock synchronization

---

## Configuration Management

### Instrument Configuration

Every tradeable instrument requires configuration:

| Parameter | Description |
|-----------|-------------|
| **Symbol / Ticker** | Exchange-specific and internal identifiers |
| **Instrument type** | Equity, future, option, FX, bond, etc. |
| **Exchange / Venue** | Where the instrument trades |
| **Tick size** | Minimum price increment (may vary by price level) |
| **Lot size** | Minimum order quantity; round lot size |
| **Trading hours** | Open, close, auction periods, halts |
| **Currency** | Trading and settlement currencies |
| **Margin requirements** | Initial and maintenance margin (for derivatives) |
| **Short-sell restrictions** | Locate requirements, uptick rules |
| **Price bands** | Exchange-imposed price limits |
| **Contract specifications** | Expiry, delivery, multiplier (for derivatives) |

**Reference data sources**: Exchange reference data files (downloaded daily), Bloomberg per-security data, Refinitiv instrument data, SIX Financial Information, manual overrides.

### Algo Parameters

Algorithm configuration requires versioned, auditable management:

| Parameter Type | Examples |
|----------------|----------|
| **Strategy parameters** | Participation rate, aggression level, start/end time, limit price |
| **Execution parameters** | Minimum order size, maximum order size, dark pool inclusion, venue preferences |
| **Model parameters** | Alpha signals, volatility estimates, mean-reversion thresholds |
| **Risk parameters** | Maximum position, maximum order value, maximum loss before pause |

### Risk Limits

Layered risk limit framework:

| Level | Limit Types | Enforcement |
|-------|-------------|-------------|
| **Firm level** | Maximum gross/net exposure, maximum daily loss, maximum order rate | Hard limits; system shutdown if breached |
| **Desk level** | Desk-specific exposure limits, P&L limits | Hard limits; desk disabled |
| **Trader level** | Per-trader position limits, order size limits, instrument restrictions | Pre-trade checks |
| **Strategy level** | Per-algo limits, per-instrument limits within strategy | Pre-trade checks |
| **Instrument level** | Maximum position per instrument, maximum order size | Pre-trade checks |

### User Permissions

| Dimension | Granularity |
|-----------|-------------|
| **Instruments** | Which instruments a user can trade |
| **Venues** | Which exchanges/brokers a user can route to |
| **Order types** | Market, limit, stop, algo, etc. |
| **Actions** | View, submit, modify, cancel, force-cancel |
| **Accounts** | Which accounts a user can trade in |
| **Monetary limits** | Maximum notional per order, per day |

### Environment Management

| Environment | Purpose | Data |
|-------------|---------|------|
| **Production** | Live trading | Real market data, real exchange connections |
| **UAT / Staging** | Pre-release validation | Real or replayed market data; exchange simulators or certification environments |
| **QA** | Automated testing | Synthetic data; mock exchange simulators |
| **Development** | Developer workstations | Local simulators; synthetic data |
| **DR** | Disaster recovery | Replicated production data |

**Configuration storage**: Centralized configuration service (Consul, etcd, Spring Cloud Config, custom database-backed service); version-controlled in Git; environment-specific overrides via hierarchical configuration.
