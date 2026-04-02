# Kraken Trading, Accounts, and Operations

## Account Tiers and Verification

### Verification Levels

| Level | Requirements | Capabilities |
|-------|-------------|-------------|
| **Starter** | Email, name, DOB, country, phone | Crypto deposit/withdraw/trade only. Limited fiat. |
| **Intermediate** | Government photo ID, proof of residence, SSN (US) | Full fiat funding, higher limits, margin eligibility |
| **Pro** | Additional documentation, proof of income/wealth | Highest limits, OTC desk, dedicated account management |

US residents must be **Intermediate-verified minimum** to trade due to regulatory requirements.

### Limits by Tier

| Tier | Crypto Deposits | Crypto Withdrawals | Fiat |
|------|----------------|-------------------|------|
| Starter | Unlimited | Up to $100K/day | None |
| Intermediate | Unlimited | Up to $100K/day (increasable) | Full access |
| Pro | Unlimited | Custom | Custom |

### API Rate Limits by Tier

| Tier | Max Counter | Decay Rate |
|------|-------------|------------|
| Starter | 15 | 1 per 3 seconds |
| Intermediate | 20 | 1 per 2 seconds |
| Pro | 20 | 1 per second |

Kraken recommends **WebSocket v2** for real-time data and order management to avoid REST rate-limit issues.

---

## Fee Structure

### Spot Trading Fees (30-Day Volume Tiers)

| 30-Day Volume (USD) | Maker Fee | Taker Fee |
|---------------------|-----------|-----------|
| $0 – $50,000 | 0.16% | 0.26% |
| $50,001 – $100,000 | 0.14% | 0.24% |
| $100,001 – $250,000 | 0.12% | 0.22% |
| $250,001 – $500,000 | 0.10% | 0.20% |
| $500,001 – $1,000,000 | 0.08% | 0.18% |
| $1,000,001 – $5,000,000 | 0.06% | 0.16% |
| $5,000,001 – $10,000,000 | 0.04% | 0.14% |
| $10,000,001+ | **0.00%** | 0.10% |

### Fee Calculation Rules

- **Maker**: Order adds liquidity (sits on the book) — charged maker fee
- **Taker**: Order removes liquidity (matches immediately) — charged taker fee
- **Market orders**: Always taker
- **Limit orders**: Maker if they don't fill immediately; taker if they cross the spread
- **Post-only orders** (`oflags=post`): Guaranteed maker fee — rejected if would be taker
- Fees are calculated on the **quote currency** value of the trade

### Fee Discounts

| Mechanism | Details |
|-----------|---------|
| **Volume discounts** | Higher 30-day volume = lower fees (see table above) |
| **KFEE credits** | KFEE tokens offset fees automatically if held in account |
| **Stablecoin pairs** | Some stablecoin-to-stablecoin pairs have reduced fees |

Kraken does **not** have a native exchange token for fee reduction (unlike Binance's BNB).

### Margin Fees

| Fee Type | Amount |
|----------|--------|
| Position opening fee | ~0.02% |
| Rollover fee | ~0.02% per 4-hour period |
| Plus regular trading fee | Per tier above |

### Futures Fees

| Type | Fee |
|------|-----|
| Maker | 0.02% |
| Taker | 0.05% |

Volume-based discounts apply.

---

## Supported Assets and Pairs

| Category | Count |
|----------|-------|
| Cryptocurrencies | 200+ |
| Trading pairs | 600+ (spot) |

### Major Assets

BTC, ETH, SOL, ADA, DOT, XRP, DOGE, AVAX, MATIC, LINK, UNI, AAVE, COMP, MKR, SNX, CRV, ARB, OP, SHIB, PEPE, and many more.

### Fiat Currencies

| Currency | Pairs | Deposit Methods |
|----------|-------|----------------|
| **USD** | Most extensive | Fedwire, SWIFT, ACH |
| **EUR** | Extensive | SEPA, SWIFT |
| **GBP** | Major assets | BACS, SWIFT, FPS |
| **CAD** | Select assets | Wire transfer |
| **AUD** | Select assets | SWIFT, BPAY |
| **JPY** | Select assets | Wire transfer |
| **CHF** | Select assets | Wire transfer |

### Stablecoin Support

USDT, USDC, DAI pairs widely available. Stablecoin-to-stablecoin pairs exist (e.g., USDT/USDC).

### API Pair Naming

Kraken uses non-standard naming: `XXBTZUSD` for BTC/USD, `XETHZEUR` for ETH/EUR. The `X`/`Z` prefixes are legacy. Use the `AssetPairs` endpoint for the full mapping. WebSocket v2 uses cleaner names (`BTC/USD`).

---

## Order Types

### Basic Orders

| Type | Description |
|------|-------------|
| **Market** | Execute immediately at best available price. Always taker. Subject to slippage. |
| **Limit** | Execute at specified price or better. Can be maker or taker. |

### Stop Orders

| Type | Trigger | Execution |
|------|---------|-----------|
| **Stop-Loss** | Price reaches stop level | Market order |
| **Take-Profit** | Price reaches profit target | Market order |
| **Stop-Loss-Limit** | Price reaches stop level | Limit order (avoids slippage, risks non-fill) |
| **Take-Profit-Limit** | Price reaches profit target | Limit order |

### Advanced Orders

| Type | Description |
|------|-------------|
| **Trailing Stop** | Stop-loss that moves with the market. Specify offset as absolute (`+100`) or percentage (`10%`). Locks when market reverses. |
| **Trailing Stop-Limit** | Same as trailing stop, but places a limit order instead of market when triggered. |
| **Settle-Position** | Close/settle an open margin position. |
| **Iceberg** | Large order with only partial visibility on the book. Specify `displayvol` for visible quantity. As visible portion fills, more is revealed. Minimizes market impact. |

### Order Modifiers

| Modifier | Description |
|----------|-------------|
| **Post-Only** (`oflags=post`) | Guaranteed maker. Rejected if would cross spread. |
| **Reduce-Only** | Only reduces existing position — never opens new one. |
| **IOC** (Immediate or Cancel) | Fill what's available immediately, cancel remainder. |
| **GTD** (Good Till Date) | Expires at specified time. |
| **Conditional Close** | Attach a stop-loss or take-profit that activates when primary order fills. |
| **Deadline** | RFC3339 timestamp — reject if not processed by this time (latency-sensitive). |
| **Self-Trade Prevention** | `cancel-newest`, `cancel-oldest`, or `cancel-both`. |

---

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
