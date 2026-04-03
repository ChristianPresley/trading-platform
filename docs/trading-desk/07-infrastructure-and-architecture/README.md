# Infrastructure and Architecture

Comprehensive reference for infrastructure patterns, system architecture, deployment, and operational considerations in professional trading desk applications.

## Contents

1. [Low-Latency Architecture and Event-Driven Architecture](01_Low-Latency-Architecture-And-Event-Driven-Architecture.md) — Kernel bypass networking, lock-free data structures, memory-mapped IPC, and event sourcing with CQRS patterns
   - `sched_setaffinity()`, `mmap()`, `SPSCQueue`, `LMAXDisruptor`, `EventStore`, `CommandHandler`, `ReadModelProjection`

2. [High Availability and System Monitoring](02_High-Availability-And-System-Monitoring.md) — Active-active/passive failover topologies, RTO/RPO targets, and monitoring stacks for trading infrastructure
   - `FailoverManager`, `HealthCheck`, `FIXSessionFailover`, `AlertSeverity`, `SLATracker`, `RunbookEntry`

3. [Capacity Planning and Database Considerations](03_Capacity-Planning-And-Database-Considerations.md) — Throughput budgets, exchange rate limits, time-series databases (kdb+, QuestDB), relational stores, and in-memory caching layers
   - `LatencyBudget`, `RateLimiter`, `TokenBucket`, `TimeSeriesStore`, `InstrumentCache`, `PositionCache`, `PriceCache`

4. [Security and Configuration Management](04_Security-And-Configuration-Management.md) — Network segmentation zones, encryption layers, RBAC/entitlements, audit logging, and instrument/risk-limit configuration management
   - `NetworkZone`, `RBACPolicy`, `AuditLog`, `InstrumentConfig`, `RiskLimitFramework`, `AlgoParameterSet`, `UserPermission`

5. [Deployment and Scalability Patterns](05_Deployment-And-Scalability-Patterns.md) — Blue-green and canary deployment strategies, market-hours release windows, and horizontal scaling via instrument/exchange/desk partitioning
   - `BlueGreenDeploy`, `CanaryRelease`, `FeatureFlag`, `OrderRouter`, `PartitionByInstrument`, `MarketDataFanOut`

6. [Cloud vs On-Premise Considerations](06_Cloud-Vs-On-Premise-Considerations.md) — Latency trade-offs per workload, hybrid co-location/cloud architectures, regulatory constraints, and emerging trends (FPGA-as-a-Service, confidential computing)
   - `HybridArchitecture`, `CoLocationGateway`, `DirectConnect`, `DataResidencyPolicy`, `ConcentrationRiskAssessment`
