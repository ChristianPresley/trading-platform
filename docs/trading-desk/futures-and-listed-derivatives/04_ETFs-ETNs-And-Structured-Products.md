## Exchange-Traded Funds and Notes

### ETF Structure

An ETF is an investment fund traded on a stock exchange. Unlike mutual funds, ETFs trade continuously at market-determined prices.

#### Creation/Redemption Mechanism

The key innovation of ETFs: a process that keeps the ETF price close to its Net Asset Value (NAV).

**Creation (new shares):**
1. An **Authorized Participant (AP)** — typically a large broker-dealer (e.g., Jane Street, Virtu, Goldman Sachs) — assembles a basket of the underlying securities matching the ETF's holdings.
2. The AP delivers the basket to the ETF issuer (e.g., BlackRock for iShares, Vanguard, State Street for SPDRs).
3. The issuer creates new ETF shares (in large blocks called "creation units," typically 25,000 or 50,000 shares) and delivers them to the AP.
4. The AP sells the new ETF shares on the exchange.

**Redemption (remove shares):**
1. The AP delivers creation-unit-sized blocks of ETF shares to the issuer.
2. The issuer redeems them for the underlying basket of securities.
3. The AP sells the underlying securities in the open market.

**Why this works:** If the ETF trades at a premium to NAV, APs create new shares (buy cheap basket, sell expensive ETF). If the ETF trades at a discount, APs redeem shares (buy cheap ETF, sell expensive basket). This arbitrage mechanism keeps the ETF price within a tight band around NAV.

#### NAV Tracking

- **Indicative NAV (iNAV):** Calculated and published every 15 seconds during trading hours based on the real-time value of the underlying holdings.
- **NAV premium/discount:** The percentage difference between the ETF's market price and its NAV. For liquid, domestic equity ETFs (e.g., SPY), this is typically less than $0.01. For international or illiquid ETFs, premiums/discounts can be larger (especially when the underlying market is closed).

#### Authorized Participants

- Typically 20-50 APs per ETF, though most creation/redemption activity is concentrated among 3-5 active APs.
- APs are not obligated to create/redeem — they do so when it is profitable.
- During market stress, APs may widen their thresholds or temporarily stop creating/redeeming, causing premiums/discounts to widen (observed during March 2020 in corporate bond ETFs like LQD and HYG).

### Key ETF Products for Trading Desks

| ETF | Ticker | Underlying | AUM (approx.) | Avg Daily Volume |
|---|---|---|---|---|
| SPDR S&P 500 | SPY | S&P 500 | $500B+ | 80M+ shares/day |
| iShares Core S&P 500 | IVV | S&P 500 | $400B+ | 5M+ shares/day |
| Invesco QQQ | QQQ | NASDAQ 100 | $250B+ | 50M+ shares/day |
| iShares Russell 2000 | IWM | Russell 2000 | $65B+ | 30M+ shares/day |
| SPDR Gold Trust | GLD | Gold bullion | $60B+ | 8M+ shares/day |
| iShares 20+ Year Treasury | TLT | Long-term Treasuries | $40B+ | 20M+ shares/day |
| iShares iBoxx HY Corp | HYG | High-yield bonds | $15B+ | 15M+ shares/day |
| United States Oil Fund | USO | WTI futures | $3B+ | 5M+ shares/day |
| VIX Short-Term Futures | VIXY | VIX futures | $500M+ | 5M+ shares/day |

### ETN Structure

An ETN is an unsecured debt instrument issued by a bank. Unlike an ETF, an ETN does not hold any underlying assets. The issuer promises to pay the return of the tracked index.

**Key differences from ETFs:**

| Feature | ETF | ETN |
|---|---|---|
| **Structure** | Fund (holds assets) | Unsecured note (debt) |
| **Credit risk** | None (assets held in trust) | Issuer's credit risk (e.g., Lehman ETNs became worthless in 2008) |
| **Tracking** | May have tracking error | Perfect tracking (by design, barring fees) |
| **Tax** | Subject to fund-level capital gains distributions | No distributions until sale; potential for long-term capital gains |
| **Maturity** | Perpetual | Typically 20-30 year maturity; callable by issuer |

**ETN risks:**
- Issuer credit risk (concentration to one bank).
- Acceleration risk: The issuer can call the notes at any time, potentially at an unfavorable price.
- Premium/discount to indicative value: ETNs can trade at significant premiums when creation is suspended (as with TVIX in 2012 and 2018, or GBTC before its ETF conversion).

---

## Structured Products

### Warrants

Exchange-listed securities issued by financial institutions (primarily in Europe and Asia) that give the holder the right to buy or sell an underlying asset.

- **Call warrants** — Right to buy the underlying at the strike price.
- **Put warrants** — Right to sell.
- **Key differences from options:** Warrants are issued by banks (not created by market participants), have specific ISINs, and may have unique exercise styles. Dilution does not apply (unlike equity warrants issued by the company itself).
- **Leverage:** Warrants provide leveraged exposure to the underlying. A warrant with ratio 10:1 on a stock at EUR 100 with a strike of EUR 90 might cost EUR 1.20, providing roughly 8x leverage.
- **Major markets:** Hong Kong (HKEX — world's largest warrant market by turnover), Germany (Stuttgart, Frankfurt), Switzerland (SIX).

### Certificates (Structured Certificates)

Investment products listed on exchanges, primarily in Germany, Switzerland, and the Nordics. There are dozens of structures:

- **Tracker Certificates:** 1:1 participation in the underlying (similar to an ETN). No leverage.
- **Bonus Certificates:** Pay a guaranteed bonus at maturity if the underlying never falls below a barrier level. If the barrier is breached, the certificate converts to a tracker.
- **Discount Certificates:** Buy the underlying at a discount (embedded short call). Max payoff is capped.
- **Express Certificates:** Autocallable structures that pay a coupon and redeem early if the underlying is above a level on observation dates.
- **Capital Protection Certificates:** 100% principal protection with upside participation (embedded zero-coupon bond + call option).

**Issuer risk:** Certificates are debt of the issuing bank — like ETNs, they carry issuer credit risk.

### Turbo Warrants (Knock-Out Warrants)

Leveraged products with a knock-out barrier. If the underlying touches the barrier, the product is terminated (knocked out) and the holder receives a small residual value or nothing.

- **Turbo Long (Bull):** Leveraged long position. Knock-out below current price.
- **Turbo Short (Bear):** Leveraged short position. Knock-out above current price.
- **Pricing:** Turbo warrants have minimal time value because the barrier eliminates much of the optionality. Price ≈ (Underlying - Strike) / Ratio for a turbo long.
- **Leverage:** Can be 5x-50x depending on the distance between the current price and the strike/barrier.
- **Funding cost:** Embedded in a daily adjustment to the strike price. The strike drifts higher each day for turbo longs (costing the holder) and lower for turbo shorts.

**Markets:** Very popular in Germany (over 1 million listed products), Netherlands, and Scandinavia.

### Contracts for Difference (CFDs)

A CFD is an agreement between a buyer and seller to exchange the difference in price of an underlying asset from the time the contract is opened to the time it is closed.

**Characteristics:**
- No ownership of the underlying asset.
- Leveraged: Margin requirements typically 5-20% (FCA mandated 3.33%-50% for retail in UK/EU under ESMA rules).
- Overnight financing: Long positions pay a daily financing charge (typically interbank rate + spread). Short positions may receive a credit.
- No expiration (perpetual, in most cases).
- Available on equities, indices, FX, commodities, cryptocurrencies.

**Regulatory landscape:**
- **Banned in the US** — the SEC does not permit CFD trading for US residents.
- **Restricted in EU/UK** — ESMA and FCA imposed leverage limits (30:1 for major FX, 20:1 for indices, 10:1 for commodities, 5:1 for equities, 2:1 for crypto) and negative balance protection for retail.
- **Widely available** in Australia, Singapore, South Africa, and the Middle East (with varying regulation).

**CFD providers:** IG Group, CMC Markets, Plus500, Saxo Bank, Interactive Brokers (non-US).
