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
