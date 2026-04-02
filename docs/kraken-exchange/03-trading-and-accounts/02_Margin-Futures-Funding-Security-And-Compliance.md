## Margin / Leverage Trading

### Available Leverage

| Pair Category | Typical Leverage |
|---------------|-----------------|
| Major pairs (BTC/USD, ETH/USD) | Up to 5x |
| Mid-cap altcoins | 2x – 3x |
| Smaller altcoins | 2x |

### Margin Model

- **Cross-margin** — entire account balance serves as collateral (no isolated margin on spot)
- Margin orders placed via the same `AddOrder` endpoint with the `leverage` parameter
- Position status queryable via `OpenPositions`

### Margin Levels

| Level | Margin Level | Action |
|-------|-------------|--------|
| Healthy | > 80% | Normal operation |
| Margin call | ~80% | Kraken may notify (no auto-close) |
| **Liquidation** | **~40%** | Force-close positions to restore margin |

Liquidation can result in **negative balance** — Kraken's terms hold users responsible.

### US Restriction

**Margin trading is not available to US residents** on Kraken's main platform.

---

## Futures Trading

### Overview

Kraken acquired Crypto Facilities (UK FCA-regulated) and offers futures as **Kraken Futures**.

### Separate API

| Attribute | Spot | Futures |
|-----------|------|---------|
| API Base | `api.kraken.com` | `futures.kraken.com` |
| API Keys | Separate | Separate |
| Leverage | Up to 5x | Up to 50x |
| Settlement | Immediate | Perpetual or fixed-maturity |
| Margin | Cross only | Cross and isolated |
| Fees | See spot schedule | Generally lower |

### Products

- **Perpetual contracts** (no expiry) — most popular
- **Fixed-maturity contracts** (quarterly) — BTC, ETH, select assets
- **Multi-collateral** — use multiple assets as collateral

### Demo Environment

Available at `https://demo-futures.kraken.com` with full trading functionality using fake funds.

### US Access

Limited or unavailable for US retail customers — evolving regulatory situation.

---

## Staking

### API Endpoints

| Endpoint | Purpose |
|----------|---------|
| `Stake` | Stake assets |
| `Unstake` | Unstake assets |
| `Staking/Assets` | List stakeable assets, terms, reward rates, minimums |
| `Staking/Pending` | View pending staking transactions |
| `Staking/Transactions` | View staking history |

### Notable Stakeable Assets

DOT (~3-7%), SOL, ADA, ATOM, MATIC, ETH, FLOW, MINA — reward rates vary.

### US Restriction

**Staking discontinued for US customers** (February 2023 SEC settlement for $30M). Non-US users retain full access.

---

## Funding — Deposits and Withdrawals

### API Endpoints

#### Deposits

| Endpoint | Purpose |
|----------|---------|
| `DepositMethods` | List available deposit methods per asset |
| `DepositAddresses` | Get/generate crypto deposit addresses |
| `DepositStatus` | Check status of recent deposits |

#### Withdrawals

| Endpoint | Purpose |
|----------|---------|
| `WithdrawInfo` | Get fee and limit info |
| `Withdraw` | Initiate withdrawal |
| `WithdrawStatus` | Check withdrawal status |
| `WithdrawCancel` | Cancel pending withdrawal |

### Fees

| Type | Fee |
|------|-----|
| Crypto deposits | Generally free (user pays network fee to send) |
| Crypto withdrawals | Fixed per asset (e.g., BTC ~0.00015, ETH ~0.0045) |
| Fiat deposits | Varies by method (SEPA often free, wire $5-$35) |
| Fiat withdrawals | Varies by method |

---

## Security Best Practices

### API Key Management

- **Principle of least privilege** — only enable needed permissions
- **Never enable withdrawal permissions** on trading-only keys
- **Separate keys** for different applications/strategies
- Store API secret in a secrets manager or encrypted vault — **never in source code**
- Rotate keys periodically

### Available Key Permissions

- Query Funds
- Query Open Orders & Trades
- Query Closed Orders & Trades
- Create & Modify Orders
- Cancel/Close Orders
- Deposit Funds
- Withdraw Funds
- Export Data
- Access WebSockets API

### IP Whitelisting

- Restrict each API key to specific IP addresses of your trading server
- If a key is compromised but IP-whitelisted, it cannot be used from other IPs

### Withdrawal Address Whitelisting

- Withdrawals can only go to pre-approved addresses when enabled
- New addresses have a **24-72 hour cooling-off period** before becoming active
- Even if an API key with withdrawal permission is compromised, funds can only go to whitelisted addresses

### Two-Factor Authentication (2FA)

- TOTP (Google Authenticator or similar) for account login, trading, and funding
- **API calls bypass 2FA by design** — this is why IP whitelisting and key restrictions are critical
- **Master Key**: Separate recovery password for 2FA device loss — store offline

### Additional Recommendations

| Practice | Details |
|----------|---------|
| Dedicated email | Use a separate email for the Kraken account |
| Global Settings Lock (GSL) | Prevents changes to account settings for a set period |
| Audit log | Monitor API key usage via Kraken's logs |
| HTTPS only | All Kraken API traffic is encrypted (enforced) |
| Dead man's switch | Use `CancelAllOrdersAfter` to protect against connectivity loss |

---

## Regulatory and Compliance

### Corporate Structure

- **Payward, Inc.** — US operations (San Francisco HQ)
- **Payward Ltd.** — UK/international
- **Crypto Facilities Ltd.** — UK FCA-regulated (Futures)

### Jurisdictions Served

190+ countries including US, EU/EEA, UK, Canada, Australia, Japan (via subsidiary).

### Countries NOT Served

Sanctioned countries: Cuba, Iran, North Korea, Syria, Crimea region.

### US-Specific Restrictions

| Restriction | Details |
|-------------|---------|
| **State availability** | Not available in all states. **New York** excluded (no BitLicense). Washington state has had restrictions. |
| **Margin trading** | Not available for US customers |
| **Futures** | Limited or unavailable for US retail |
| **Staking** | Discontinued for US (SEC settlement, Feb 2023) |
| **Certain tokens** | Some may be unavailable due to securities classification concerns |
| **KYC/AML** | Full verification required (Intermediate minimum). Complies with FinCEN, BSA, state money transmitter licenses. |

### Tax Reporting

- Kraken provides tax reporting tools
- May issue **1099 forms** to US customers
- API trade history export supports tax workflows
- Complies with IRS information-sharing requirements

### Regulatory Actions

- **February 2023**: SEC settlement ($30M) — discontinued staking for US users
- Kraken holds MSB registration with FinCEN and various state licenses
