## 1. Pre-Trade Compliance

Pre-trade compliance checks are enforced before an order reaches the market. They operate as synchronous gatekeepers in the order flow, typically adding microseconds to single-digit milliseconds of latency depending on complexity.

### 1.1 Restricted Lists

A restricted list contains securities that the firm is prohibited from trading, typically because the firm possesses material nonpublic information (MNPI) about the issuer or has a conflict of interest.

**Operational details:**

- The compliance department maintains one or more restricted lists in a centralized compliance engine (e.g., Bloomberg VAULT, Compliance Science ComplySci, NICE Actimize).
- Lists are keyed by security identifier (ISIN, CUSIP, SEDOL, FIGI, ticker) and may apply at the issuer level (covering all securities of a given issuer: equity, debt, derivatives).
- Restrictions can be absolute (no trading permitted) or conditional (e.g., trading permitted only for index rebalance, hedging existing positions, or client-directed unsolicited orders).
- Each entry has an effective date, expiration date (or open-ended), reason code, and the name of the information barrier group that imposed it.
- Order management systems (OMS) check every incoming order against the restricted list before routing. A hard block prevents the order from proceeding; a soft block requires compliance officer override with documented justification.
- When a security is added to the restricted list, the system should also flag any existing open orders or outstanding limit orders in that security for review and potential cancellation.

**Implementation considerations:**

- Near-real-time list updates via event bus or polling (sub-second refresh).
- Support for hierarchy-based restrictions: restricting a parent issuer restricts all subsidiaries.
- Audit trail of every check performed, including timestamp, user, security, result, and override (if any).

### 1.2 Watch Lists (Grey Lists)

A watch list (also called a grey list) contains securities that are under heightened monitoring but not necessarily restricted. The existence of a security on the watch list is itself confidential.

**Operational details:**

- Watch list entries trigger enhanced monitoring rather than trade blocking. Trades in watch list securities are flagged for post-trade review by compliance.
- The watch list is visible only to senior compliance personnel, not to traders or sales staff, to prevent information leakage.
- Typical triggers for watch list addition: the firm is advising on a potential M&A transaction, the research department is about to change a rating, or the firm has received confidential information through its lending desk.
- Monitoring includes tracking unusual position build-ups, timing of trades relative to announcement dates, and communication patterns around the security.

### 1.3 Insider Trading Prevention

Trading desk applications implement multiple layers of insider trading prevention aligned with SEC Rule 10b-5 (US), EU Market Abuse Regulation (MAR) Article 8/14, and equivalent rules in other jurisdictions.

**Information barriers (Chinese Walls):**

- Logical and physical separation between departments that may possess MNPI (investment banking, M&A advisory, principal trading) and those that execute client orders or proprietary trades.
- The OMS enforces barriers by associating users with barrier groups and restricting order flow across groups.
- Wall-crossing events are logged when an individual from a non-restricted side is brought "over the wall" for a specific transaction. The system tracks: who was crossed, when, by whom, for which transaction, and when they were brought back.
- Personal devices and communication channels are monitored during wall-crossing periods.

**Insider lists:**

- Under MAR Article 18, firms must maintain insider lists identifying all persons with access to inside information, with precise timestamps of when access was granted and revoked.
- Insider lists must be provided to the relevant national competent authority (NCA) upon request.
- The system must support both deal-specific insider lists and permanent insider lists (for individuals who routinely have access to inside information by virtue of their role).

### 1.4 Personal Account Dealing (PA Dealing) Rules

Regulations require firms to monitor and restrict the personal trading of employees, particularly those with access to client information or MNPI.

**Typical controls:**

- **Pre-clearance:** Employees must submit personal trade requests through a compliance portal before executing. The system checks the proposed trade against restricted lists, watch lists, recent client order flow, and pending research publications.
- **Holding periods:** Minimum holding periods (commonly 30-60 days) are enforced for approved personal trades to prevent short-term speculation based on firm information.
- **Blackout periods:** Trading windows may be closed around earnings announcements, research publication dates, or when the employee's team is working on a sensitive transaction.
- **Duplicate brokerage statements:** Employees are required to route personal brokerage accounts through designated brokers that send duplicate confirmations and statements directly to the compliance department.
- **Disclosure requirements:** Annual and quarterly holdings reports (required under SEC Rule 204A-1 for US investment advisers, and under MiFID II Article 29 for EU firms).
- **Gift and entertainment tracking:** Integrated tracking of gifts, entertainment, and political contributions that may create conflicts of interest.

**Standards:** FCA SYSC 10.2 (UK), SEC Rule 204A-1 (US), FINRA Rule 3210, MiFID II Delegated Regulation Article 29.
