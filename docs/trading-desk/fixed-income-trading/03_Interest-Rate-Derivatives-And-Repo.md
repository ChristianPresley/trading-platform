## Interest Rate Derivatives

### Interest Rate Swaps (IRS)

The most traded OTC derivative globally by notional outstanding.

**Vanilla (fixed-for-floating) swap:**
- One party pays a fixed rate; the other pays a floating rate (SOFR, EURIBOR, SONIA, TONAR, etc.) on the same notional amount.
- **Tenors**: 1 year to 50+ years. Most liquid: 2, 5, 10, 20, 30 years.
- **Day count conventions**: fixed leg typically 30/360 (USD) or ACT/365F; floating leg typically ACT/360 (USD SOFR).
- **Payment frequency**: fixed leg semi-annual (USD) or annual (EUR); floating leg quarterly or semi-annual depending on the reference rate.
- **Swap spread**: the difference between the swap rate and the corresponding government bond yield. Reflects credit/funding basis of the banking system.

**SOFR transition:**
- LIBOR cessation (June 2023 for USD LIBOR) moved the market to SOFR (Secured Overnight Financing Rate) as the primary USD benchmark.
- SOFR is an overnight rate; term SOFR (CME Term SOFR) provides 1M, 3M, 6M forward-looking rates.
- SOFR swaps use compounded SOFR-in-arrears (observation period with a lookback or payment delay to allow calculation before payment date).
- Legacy LIBOR swaps use ISDA fallback provisions (SOFR + fixed spread adjustment).

**Basis swaps:**
- Exchange of two floating rates (e.g., 1M SOFR vs 3M SOFR, or SOFR vs Fed Funds, or USD SOFR vs EUR EURIBOR in a cross-currency basis swap).
- Basis swap spreads reflect supply/demand imbalances and credit/liquidity differences between the two rates.

**Clearing:**
- Mandated central clearing for standardized IRS through CCPs: LCH SwapClear (dominant globally), CME Clearing, JSCC (Japan).
- Initial margin (IM) and variation margin (VM) posted to the CCP.
- Uncleared swaps require bilateral IM and VM (ISDA SIMM model for IM calculation).

### Swaptions

Options on interest rate swaps. The holder has the right (but not obligation) to enter a swap at a specified rate on the expiry date.

**Types:**
- **Payer swaption**: right to pay fixed (profit if rates rise). Equivalent to a put on a bond.
- **Receiver swaption**: right to receive fixed (profit if rates fall). Equivalent to a call on a bond.

**Quoting:**
- Expiry x Tenor format: "3m10y" = option expiring in 3 months on a 10-year swap.
- Quoted in basis points of annualized volatility (normal/basis point vol) or in price (premium as % of notional).
- The swaption vol surface (expiry vs tenor) is a key risk management input.

**Settlement:**
- Physical: upon exercise, the parties enter the underlying swap.
- Cash: payment based on the difference between the strike rate and the prevailing swap rate, using a standard annuity factor.

**Exotic variations:**
- **Bermudan swaptions**: exercisable on multiple dates (typically each coupon date). Common in callable bond hedging.
- **Mid-curve swaptions**: option on a forward-starting swap (e.g., 1-year option on a swap starting in 1 year for 10 years).

### Caps, Floors, and Collars

- **Cap**: a series of European call options (caplets) on a floating rate. Each caplet pays max(floating rate - strike, 0) on the payment date. Used to hedge floating-rate borrowing costs.
- **Floor**: a series of European put options (floorlets) on a floating rate. Each floorlet pays max(strike - floating rate, 0). Used to protect floating-rate investment income.
- **Collar**: long a cap, short a floor (or vice versa). Limits both upside and downside rate exposure. Zero-cost collar: cap and floor premiums offset.

### Forward Rate Agreements (FRAs)

- OTC contract that locks in a borrowing/lending rate for a future period.
- Notation: 3x6 FRA = agreement on a 3-month rate starting in 3 months.
- Cash-settled at the start of the forward period (payment = discounted difference between FRA rate and actual reference rate).
- Largely replaced by SOFR futures and short-dated swaps in the post-LIBOR world, but the concept remains central to curve construction.

---

## Repo and Securities Lending

### Repurchase Agreements (Repo)

A repo is economically a collateralized loan. The security seller (cash borrower) agrees to sell a security and repurchase it at a later date at a higher price (the difference being the repo interest).

**Structure:**
- **Opening leg**: seller delivers security to buyer, receives cash.
- **Closing leg**: seller repurchases security, returns cash plus repo interest.
- **Repo rate**: the implicit interest rate on the cash leg. Quoted as an annualized rate.
- **Haircut**: the difference between the security's market value and the cash exchanged. Protects the cash lender against collateral depreciation. Typical haircuts: 0.5-2% for Treasuries, 2-5% for IG corporates, 5-10%+ for equities or lower-quality collateral.

### Repo Variations

**Overnight repo:**
- Matures the next business day. Most liquid segment.
- Overnight Treasury repo rates typically trade near the Federal Funds rate / SOFR.

**Term repo:**
- Fixed maturity beyond overnight (1 week, 1 month, 3 months, etc.).
- Slightly higher rates than overnight to compensate for tenor risk.
- Used for planned funding needs and carry trades.

**Open repo:**
- No fixed maturity; rolls daily until either party terminates.
- Rate resets daily. Common for ongoing financing needs.

**Tri-party repo:**
- A custodian bank (Bank of New York Mellon or JP Morgan in the US) acts as an intermediary.
- The custodian holds the collateral, manages margining, and ensures delivery-vs-payment.
- Simplifies operations: the collateral can be substituted (within agreed eligibility criteria) without unwinding the trade.
- Used heavily by money market funds, central banks, and large institutional investors.

**Reverse repo:**
- The mirror image of a repo: the party lending cash and receiving collateral is doing a reverse repo.
- The Federal Reserve uses reverse repo operations (RRP facility) to set a floor on short-term rates.

**GC (General Collateral) vs Special:**
- **GC**: any eligible security in a defined basket (e.g., any Treasury security) can serve as collateral. The rate reflects general funding conditions.
- **Special**: a specific security is demanded as collateral (e.g., the on-the-run 10-year Treasury). The repo rate is lower than GC (sometimes zero or negative) because the cash lender accepts a lower return in exchange for obtaining the specific security.
- **Specialness**: the spread between GC and special repo rates. High specialness indicates strong demand to borrow a particular security (e.g., for short selling or delivery obligations).

### Repo in Practice

**Financing long positions:**
- A trader who owns a bond finances it in the repo market: repo out the bond (deliver it as collateral) to borrow cash at the repo rate.
- The cost of carry = coupon income minus repo financing cost.

**Facilitating short positions:**
- A trader who wants to short a bond does a reverse repo: lends cash and receives the bond as collateral. Then sells the bond in the market.
- To close the short, the trader buys the bond back and returns it to the reverse repo counterparty.

**Central bank operations:**
- Open market operations are conducted via repo/reverse repo.
- The Fed's Standing Repo Facility (SRF) provides overnight repo at a set rate, serving as a backstop.
- The Fed's RRP facility absorbs excess liquidity.

**Regulatory considerations:**
- Repo exposure counts toward leverage ratios (SLR - Supplementary Leverage Ratio for US G-SIBs).
- Netting rules under GAAP vs IFRS affect balance sheet treatment.
- SFTR (Securities Financing Transactions Regulation) in the EU requires reporting of repo transactions to trade repositories.
