## High Availability and Disaster Recovery

Trading systems have stringent availability requirements. Unplanned downtime during market hours has direct financial impact and regulatory consequences.

### Deployment Topologies

#### Active-Active

Both sites process traffic simultaneously; load is distributed across sites:

```
            ┌─────────┐     ┌─────────┐
            │  Site A  │<--->│  Site B  │
            │(Primary) │sync │(Primary)│
            └─────────┘     └─────────┘
                 │               │
            Exchange A      Exchange B
```

- **Strengths**: No wasted capacity; lower latency for geographically distributed venues; no failover delay
- **Challenges**: State synchronization between sites; split-brain prevention; more complex operationally
- **Usage**: Multi-region trading (e.g., US and European operations); market data distribution

#### Active-Passive (Hot Standby)

Primary site handles all traffic; standby site maintains synchronized state but does not process orders:

- **State replication**: Synchronous or asynchronous replication of order state, positions, and configuration
- **Failover trigger**: Manual (operator decision) or automated (health check failure)
- **Failover time**: Target < 30 seconds for warm standby; < 5 minutes for cold standby
- **Usage**: Most common DR pattern for trading systems; simpler to reason about

#### Active-Passive (Warm Standby)

Standby site is running and receiving replicated state but requires manual activation:

- Applications are running but not connected to exchanges
- FIX sessions are pre-configured but not initiated
- On failover: establish exchange sessions, verify state, begin processing

### RTO and RPO Requirements

| Component | RTO (Recovery Time Objective) | RPO (Recovery Point Objective) |
|-----------|------------------------------|-------------------------------|
| Order management | < 2 minutes | Zero (no order loss) |
| Market data | < 30 seconds | N/A (stateless stream) |
| Risk engine | < 1 minute | Zero (positions must be accurate) |
| Post-trade / STP | < 15 minutes | < 1 minute |
| Analytics / Reporting | < 1 hour | < 5 minutes |

### Failover Mechanisms

- **FIX session failover**: Secondary FIX sessions pre-configured at the exchange; activate on primary failure. Exchange supports session migration or firm initiates new session with sequence reset.
- **Database failover**: SQL Server Always On AG, Oracle Data Guard, PostgreSQL streaming replication with Patroni
- **Application failover**: Kubernetes pod rescheduling, VM live migration, or dedicated failover scripts
- **Network failover**: Dual-homed connectivity; BGP-based failover; redundant cross-connects
- **DNS-based failover**: Weighted or health-check-based DNS routing (less common for latency-sensitive paths)

### Geo-Redundant Sites

Typical trading firm site strategy:

| Site | Location | Role |
|------|----------|------|
| Primary | Co-located at exchange (e.g., Equinix NY5) | Production trading |
| DR | Nearby but separate facility (e.g., Equinix NY4/NY9) | Hot/warm standby |
| Tertiary | Different region (e.g., Chicago, London) | Cold standby; covers regional catastrophe |
| Office | Corporate headquarters | Development, monitoring, non-latency-sensitive operations |

### Testing DR

- **DR drills**: Mandatory periodic failover tests (at minimum quarterly)
- **Chaos engineering**: Inject failures to test resilience (Netflix-style)
- **Weekend DR tests**: Full site failover during non-market hours
- **Regulatory expectation**: SEC, FCA, MAS, and other regulators expect documented DR procedures and test results

---

## System Monitoring and Alerting

### Application Monitoring

| Category | What to Monitor | Tools |
|----------|-----------------|-------|
| **Order flow** | Order rates, fill rates, reject rates, cancel rates, order-to-trade ratio | Custom dashboards; Grafana |
| **Latency** | Tick-to-trade, order-to-ack, internal processing time per component | Histogram metrics; Prometheus; custom instrumentation |
| **FIX sessions** | Connection status, sequence numbers, heartbeat status, message rates | FIX engine admin interface; custom monitors |
| **Market data** | Feed status, gap count, stale tick detection, message rates per feed | Feed handler metrics; comparison across redundant feeds |
| **Risk** | Position vs. limits, P&L vs. thresholds, margin utilization | Risk engine dashboards; real-time alerts |
| **Business logic** | Strategy performance, algo completion rates, SOR routing statistics | Custom analytics |

### Infrastructure Monitoring

| Category | What to Monitor | Tools |
|----------|-----------------|-------|
| **Servers** | CPU, memory, disk I/O, network I/O, GC pauses | Prometheus + node_exporter, Datadog, Zabbix |
| **Network** | Packet loss, jitter, latency (one-way and round-trip), NIC statistics | Corvil, ExtraHop, DPDK stats, ethtool counters |
| **Storage** | Disk utilization, I/O latency, replication lag | Storage vendor tools; OS metrics |
| **Middleware** | Queue depths, message rates, consumer lag, broker health | Solace admin, Kafka consumer lag (Burrow), TIBCO admin |
| **Database** | Query latency, connection pool, replication lag, lock contention | Database-specific tools; Prometheus exporters |

### Monitoring Stack

Common monitoring architecture for trading:

```
Application Metrics ──> Prometheus/InfluxDB ──> Grafana (dashboards)
                                                      │
Application Logs ────> ELK Stack (Elasticsearch,      v
                       Logstash, Kibana) or Splunk   Alertmanager/
                                                     PagerDuty/
Network Packets ─────> Corvil/Pico Analytics         OpsGenie
                                                      │
Infrastructure ──────> Datadog/Zabbix/Nagios    ──>  On-call
```

**Trading-specific monitoring products**:

| Product | Vendor | Capability |
|---------|--------|------------|
| **Corvil** | Cisco (Corvil) | Wire-level network analytics; nanosecond timestamping; protocol-aware (FIX, ITCH, etc.) |
| **Pico** (now Corvil) | Acquired by Cisco | Similar to Corvil; network monitoring for financial markets |
| **ExtraHop** | ExtraHop Networks | Wire data analytics; real-time protocol analysis |
| **Geneos** | ITRS Group | Trading infrastructure monitoring; widely used in banks |
| **AppDynamics / Dynatrace** | Cisco / Dynatrace | Application performance monitoring; less common in ultra-low-latency |
| **Splunk** | Cisco (Splunk) | Log analytics; very common in trading firms for operational intelligence |
| **Elastic Stack (ELK)** | Elastic | Open-source log and event analytics |

### SLA Tracking

Key SLAs for a trading platform:

| SLA | Target | Measurement |
|-----|--------|-------------|
| System availability (market hours) | 99.99% (< 52 min downtime/year) | Uptime monitors |
| Order acknowledgment latency | < 500 microseconds (p99) | Internal instrumentation |
| Market data freshness | < 100 microseconds from exchange (co-located) | Hardware timestamping |
| Risk check latency | < 50 microseconds (pre-trade) | Internal instrumentation |
| Failover time | < 2 minutes | DR drill measurement |
| Trade report delivery | < 15 minutes from execution | Post-trade pipeline monitoring |

### Alerting Best Practices

- **Severity tiers**: P1 (immediate page: system down, data loss), P2 (urgent: degraded performance, single component failure), P3 (warning: approaching thresholds), P4 (informational)
- **Runbooks**: Every alert has an associated runbook with diagnosis and remediation steps
- **Escalation**: Automated escalation if acknowledgment is not received within defined windows
- **Suppression**: During known maintenance windows or exchange outages, suppress related alerts
- **Market-hours awareness**: Higher sensitivity during market hours; different on-call rotation
