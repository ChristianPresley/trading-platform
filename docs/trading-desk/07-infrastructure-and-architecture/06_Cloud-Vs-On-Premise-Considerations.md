## Cloud vs On-Premise Considerations

### The Latency Question

The fundamental tension: cloud provides operational efficiency, but introduces network latency that is unacceptable for latency-sensitive trading.

| Workload | Cloud Suitability | Reason |
|----------|-------------------|--------|
| **HFT / Market Making** | Not suitable | Requires co-location; every microsecond matters |
| **Algo execution (DMA)** | Marginal | Sub-millisecond latency requirements; proximity matters |
| **Agency algo / SOR** | Possible | Millisecond latency acceptable for some strategies |
| **Portfolio trading** | Suitable | Seconds-to-minutes timeframe; latency less critical |
| **Post-trade processing** | Well-suited | No real-time latency requirement |
| **Risk analytics** | Well-suited | Batch and near-real-time; benefits from elastic compute |
| **Back-testing / Research** | Ideal | Elastic compute; burst capacity; cost-effective |
| **Compliance / Surveillance** | Well-suited | Event-driven processing; storage-intensive |
| **Disaster recovery** | Well-suited | Cost-effective warm/cold standby |

### Cloud Adoption in Trading

Major cloud providers have financial services offerings:

#### AWS

- **AWS Outposts**: On-premise AWS infrastructure; co-located at exchange data centers
- **AWS Direct Connect**: Dedicated network connection to AWS; low-latency access
- **Amazon FinSpace**: Managed analytics for financial data
- **AWS Graviton**: ARM-based instances; cost-effective for non-latency-critical workloads
- **Exchange connectivity**: AWS has presence in Equinix NY5, LD4 (London), TY3 (Tokyo)

#### Microsoft Azure

- **Azure ExpressRoute**: Dedicated circuits to Azure; financial services peering
- **Azure Confidential Computing**: Hardware-based TEE for sensitive workloads
- **Azure for Financial Services**: Compliance frameworks, reference architectures
- **.NET optimization**: Natural fit for .NET trading platforms; Azure Functions, Azure Kubernetes Service

#### Google Cloud

- **Google Cloud Dedicated Interconnect**: Low-latency dedicated connections
- **BigQuery**: Petabyte-scale analytics for historical data
- **Anthos**: Hybrid cloud management across on-premise and cloud

### Regulatory Considerations

| Jurisdiction | Key Requirements |
|-------------|------------------|
| **US (SEC/FINRA)** | Books and records requirements; cloud outsourcing guidance; vendor risk management |
| **EU (ESMA/EBA)** | DORA (Digital Operational Resilience Act): strict ICT third-party risk management; data residency requirements |
| **UK (FCA)** | Operational resilience requirements; material outsourcing notification |
| **Singapore (MAS)** | Technology Risk Management guidelines; cloud outsourcing guidelines |
| **Australia (ASIC/APRA)** | CPS 234 (Information Security); outsourcing requirements |

**Common regulatory requirements for cloud adoption**:

- **Data residency**: Some jurisdictions require data to remain within national borders
- **Audit access**: Regulators must be able to inspect cloud infrastructure and data
- **Exit strategy**: Documented plan for migrating away from cloud provider
- **Concentration risk**: Regulators concerned about systemic risk if too many firms use the same cloud provider
- **Encryption**: Data must be encrypted in transit and at rest; key management under firm control

### Hybrid Architecture

The most common pattern for trading firms is a hybrid architecture:

```
┌──────────────────────────────────────────────────────┐
│                Co-Location (On-Premise)                │
│                                                        │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │ Exchange  │  │ Market   │  │ Low-Latency       │   │
│  │ Gateways  │  │ Data Feed│  │ Order Management  │   │
│  │           │  │ Handlers │  │ & Risk            │   │
│  └──────────┘  └──────────┘  └───────────────────┘   │
│                       │                                │
│              Dedicated Link / VPN                      │
└───────────────────────┼──────────────────────────────┘
                        │
┌───────────────────────v──────────────────────────────┐
│                   Cloud                               │
│                                                        │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │ Back-    │  │ Analytics │  │ Disaster          │   │
│  │ Testing  │  │ & Research│  │ Recovery          │   │
│  │ Cluster  │  │           │  │                   │   │
│  └──────────┘  └──────────┘  └───────────────────┘   │
│                                                        │
│  ┌──────────┐  ┌──────────┐  ┌───────────────────┐   │
│  │ Post-    │  │ Compliance│  │ Client            │   │
│  │ Trade    │  │ & Surveil.│  │ Portals           │   │
│  └──────────┘  └──────────┘  └───────────────────┘   │
└──────────────────────────────────────────────────────┘
```

**Key hybrid architecture decisions**:

- **Network connectivity**: Dedicated circuits (AWS Direct Connect, Azure ExpressRoute) between co-location and cloud; redundant paths
- **Data replication**: Real-time replication of order/position data from co-lo to cloud for analytics and DR
- **Security boundary**: Treat the cloud-to-colo link as an untrusted network; encrypt everything; mutual TLS
- **Latency budget**: Understand and accept the added latency for non-critical-path workloads
- **Cost model**: Co-location is CapEx-heavy (hardware, space, power); cloud is OpEx (pay-as-you-go); hybrid optimizes total cost

### Emerging Trends

- **Exchange co-located cloud**: AWS Outposts and Azure Stack deployed in exchange data centers; firms get cloud APIs with co-located latency
- **FPGA-as-a-Service**: Cloud providers offering FPGA instances (AWS F1) for trading workloads; latency not competitive with dedicated co-lo FPGA but useful for development
- **Confidential computing**: Hardware-based trusted execution environments (Intel SGX, AMD SEV) for running trading logic in cloud without trusting the provider
- **Multi-cloud**: Avoiding single-provider lock-in; distributing across AWS, Azure, and GCP; adds complexity but reduces concentration risk
- **Kubernetes for trading**: Increasingly used for non-latency-sensitive components; not yet suitable for the critical order path due to networking overhead
