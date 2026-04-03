# User Management and Permissions

Covers user roles, personas, role-based access control, trader profiles, desk organization, multi-tenancy, session management, audit trails, delegation, proxy trading, onboarding/offboarding, and communication tools integration in professional trading desk applications.

## Contents

1. [User Roles and Personas](01_User-Roles-And-Personas.md) — Defines eight user personas (trader, PM, risk manager, compliance, ops, IT, management, quant) with permissions and workflows
   - `Trader`, `PortfolioManager`, `RiskManager`, `ComplianceOfficer`, `OperationsStaff`, `ITSupport`, `QuantAnalyst`, `SeparationOfDuties`

2. [Role-Based Access Control](02_Role-Based-Access-Control.md) — Four-dimensional RBAC: desk, instrument, function, and data entitlements with permission evaluation pipeline
   - `desk.view`, `desk.trade`, `order.create`, `order.cancel_all`, `risk.kill_switch`, `PermissionEvaluationPipeline`, `FourEyesPrinciple`, `RestrictedList`, `DataEntitlement`

3. [Trader Profiles and Desk Organization](03_Trader-Profiles-And-Desk-Organization.md) — Trader profile structure, order defaults hierarchy, venue/algo preferences, per-trader risk limits, and desk structure
   - `TraderProfile`, `TradingDefaults`, `VenuePreferences`, `AlgoPreferences`, `PerTraderRiskLimits`, `TradingDesk`, `SmartOrderRouter`, `LimitEscalation`

4. [Multi-Tenancy and User Session Management](04_Multi-Tenancy-And-User-Session-Management.md) — Multi-fund/client tenancy models, information barriers (Chinese walls), SSO, session timeouts, and device management
   - `TenancyModel`, `InformationBarrier`, `WallCrossingProcedure`, `ClientSegregation`, `AllocationPolicy`, `SSO`, `SessionTimeout`, `ConcurrentSessionPolicy`, `DeviceManagement`

5. [Audit Trails for User Actions](05_Audit-Trails-For-User-Actions.md) — Regulatory audit requirements, login/order/config change logging, WORM storage, and tamper-evident retrieval
   - `LoginEvent`, `OrderEvent`, `ConfigChangeEvent`, `LimitChangeEvent`, `WORMStorage`, `AuditTrailRetrieval`, `AnomalyDetection`, `ImmutableRecord`

6. [Onboarding and Offboarding Workflows](06_Onboarding-And-Offboarding-Workflows.md) — Multi-step new user provisioning, immediate/planned offboarding, and internal role transfer procedures
   - `OnboardingWorkflow`, `IdentityProvisioning`, `RiskLimitConfiguration`, `ComplianceSetup`, `ImmediateOffboarding`, `PlannedOffboarding`, `RoleTransfer`, `LitigationHold`

7. [Delegation, Proxy Trading, and Communication Tools](07_Delegation-Proxy-Trading-And-Communication-Tools.md) — Trading-on-behalf-of delegation, vacation coverage, escalation procedures, and Bloomberg/Symphony/Eikon integration
   - `DelegationRecord`, `VacationCoverage`, `EscalationWorkflow`, `BloombergIBIntegration`, `SymphonyBot`, `EikonMessenger`, `SquawkBox`, `CommunicationArchival`
