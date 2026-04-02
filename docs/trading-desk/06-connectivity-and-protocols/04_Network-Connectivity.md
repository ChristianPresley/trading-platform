## Network Connectivity

### Dedicated Lines and Cross-Connects

Trading firms connect to exchanges and counterparties through dedicated, private network links rather than the public internet.

**Cross-connects**: Physical cable (fiber or copper) running directly between a trading firm's rack and an exchange's matching engine within the same data center. Shortest possible path; sub-microsecond additional latency.

**Leased lines / Private circuits**:

| Type | Bandwidth | Typical Latency | Use Case |
|------|-----------|-----------------|----------|
| Dark fiber | 10-100 Gbps | Speed-of-light in fiber (~5 us/km) | Intra-city exchange connectivity |
| MPLS | 1-10 Gbps | Variable | Multi-site WAN connectivity |
| Ethernet Private Line | 1-100 Gbps | Low, SLA-backed | Exchange connectivity from proximity sites |
| Wavelength (DWDM) | 10-400 Gbps per wavelength | Speed-of-light | Long-haul low-latency links |

**Key network providers for financial markets**:

- **IPC/Connexus** (now Atos): Financial extranet; managed connectivity to exchanges globally
- **TNS (Transaction Network Services)**: Managed infrastructure; FIX and market data transport
- **BSO (Beeks Group)**: Ultra-low-latency global network
- **McKay Brothers / Quincy Data**: Microwave/millimeter-wave networks
- **Zayo**: Dark fiber and wavelength provider

### Co-location and Proximity Hosting

**Co-location**: Racking servers in the same data center as the exchange matching engine.

| Exchange | Data Center | Provider |
|----------|-------------|----------|
| NYSE | Mahwah, NJ | NYSE (ICE) managed |
| Nasdaq | Carteret, NJ | Equinix NY5 |
| CME | Aurora, IL | CME managed |
| BATS/Cboe | Secaucus, NJ | Equinix NY5/Cyxtera |
| LSE | Basildon, UK | Interxion (managed) |
| Eurex/Xetra | Frankfurt | Equinix FR2 |
| SGX | Singapore | Equinix SG1 |
| JPX | Tokyo | Kanto region DC |

**Proximity hosting**: When co-location space is unavailable or too expensive, firms deploy in nearby data centers with short cross-connects or dark fiber to the exchange DC.

**Equinix** is the dominant data center operator for financial markets, hosting matching engines or providing cross-connects to exchanges in major markets.

### Microwave and Laser Links

For latency-sensitive strategies (HFT, statistical arbitrage), the speed of light in fiber (~200,000 km/s due to refractive index) is too slow over long distances. Line-of-sight wireless links approach the vacuum speed of light (~300,000 km/s):

| Technology | Speed | Weather Sensitivity | Range | Providers |
|------------|-------|---------------------|-------|-----------|
| **Microwave** | ~300,000 km/s | Moderate (rain fade) | Up to 60 km per hop | McKay Brothers, Anova Financial Networks, New Line Networks |
| **Millimeter wave** | ~300,000 km/s | Higher (rain, fog) | Shorter per hop | Various proprietary |
| **Free-space laser** (FSO) | ~300,000 km/s | High (fog, precipitation) | Short range (< 5 km) | Anova, proprietary |

**Key routes**:

- **Carteret, NJ to Mahwah, NJ** (~35 miles): Nasdaq-to-NYSE arbitrage
- **Carteret, NJ to Aurora, IL** (~720 miles): Equities-to-futures arbitrage
- **Basildon to Frankfurt** (~400 miles): LSE-to-Eurex arbitrage
- **Slough (London) to Frankfurt**: Alternative UK-Europe route
