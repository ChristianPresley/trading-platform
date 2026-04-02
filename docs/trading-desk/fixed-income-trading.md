# Fixed Income Trading

Comprehensive reference for fixed income asset-class features on a professional trading desk. Covers bonds, rates derivatives, credit, repo, money markets, securitized products, analytics, and electronic trading workflows.

---

## Table of Contents

1. [Bond Trading](#bond-trading)
2. [Fixed Income Market Structure](#fixed-income-market-structure)
3. [Yield Curve Analysis and Trading](#yield-curve-analysis-and-trading)
4. [Credit Trading](#credit-trading)
5. [Interest Rate Derivatives](#interest-rate-derivatives)
6. [Repo and Securities Lending](#repo-and-securities-lending)
7. [Money Markets](#money-markets)
8. [Mortgage-Backed Securities](#mortgage-backed-securities)
9. [Fixed Income Analytics](#fixed-income-analytics)
10. [RFQ (Request for Quote) Workflows](#rfq-request-for-quote-workflows)
11. [Electronic Bond Trading Evolution and Protocols](#electronic-bond-trading-evolution-and-protocols)

---

## Bond Trading

### Government Bonds

Government bonds are the foundation of fixed income markets, serving as risk-free (or near-risk-free) benchmarks and primary collateral.

**US Treasury Securities:**
- **Treasury Bills (T-bills)**: zero-coupon, maturities of 4, 8, 13, 17, 26, and 52 weeks. Quoted on a discount yield basis.
- **Treasury Notes (T-notes)**: semi-annual coupon, maturities of 2, 3, 5, 7, and 10 years.
- **Treasury Bonds (T-bonds)**: semi-annual coupon, 20-year and 30-year maturities.
- **Treasury Inflation-Protected Securities (TIPS)**: principal adjusts with CPI. Real yield quoted; breakeven inflation = nominal yield minus TIPS yield.
- **Floating Rate Notes (FRNs)**: coupon indexed to the 13-week T-bill auction rate.
- **STRIPS**: Separately traded interest and principal components of Treasury securities. Zero-coupon instruments created by stripping coupon bonds.

**Quoting conventions:**
- Price quoted in 32nds (e.g., 99-16 = 99 and 16/32 = 99.50). Further precision: 99-16+ = 99 and 16.5/32, or 99-163 = 99 and 16.375/32.
- Yield to maturity is the primary analytical measure.
- When-issued (WI) trading: trading on a yield basis before auction settlement.
- On-the-run vs off-the-run: the most recently auctioned security at each maturity is "on-the-run" and carries a liquidity premium. Previous issues are "off-the-run."
- Benchmark status: the on-the-run 10-year Treasury is the most referenced benchmark globally.

**Auction process:**
- Primary dealers are obligated to participate in every Treasury auction.
- Competitive bids specify yield; non-competitive bids accept the auction yield.
- Single-price (Dutch) auction: all accepted bids receive the same yield (the highest accepted yield).
- Auction metrics: bid-to-cover ratio, tail (difference between highest accepted yield and when-issued yield), allocation to primary dealers vs direct/indirect bidders.

**Other sovereign bonds:**
- **UK Gilts**: semi-annual coupon, quoted in decimal (e.g., 98.50). Conventional gilts and index-linked gilts (linked to RPI).
- **German Bunds/Bobls/Schatze**: Bunds (10-30yr), Bobls (5yr), Schatze (2yr). Annual coupon, quoted in decimal.
- **JGBs (Japanese Government Bonds)**: semi-annual coupon. Massive market (~$9 trillion equivalent) with Bank of Japan as dominant holder.
- **BTPs (Italian)**, **OATs (French)**, **Bonos (Spanish)**: Eurozone sovereign bonds, denominated in EUR, annual coupon.
- **Emerging market sovereign bonds**: issued in local currency or hard currency (USD, EUR). Hard currency EM bonds often benchmarked to JP Morgan EMBI/GBI indices.

### Corporate Bonds

- **Investment grade (IG)**: rated BBB-/Baa3 or above by S&P/Moody's. Lower yields, higher liquidity for large benchmark issues.
- **High yield (HY)**: rated below BBB-/Baa3. Higher yields, wider spreads, greater credit risk. Also called "junk bonds."
- **Crossover/split-rated**: rated IG by one agency and HY by another. Execution can be challenging as different investor bases may or may not be able to hold the security.

**Bond structures:**
- **Fixed rate**: standard semi-annual (US) or annual (Europe) coupon.
- **Floating rate notes (FRNs)**: coupon resets periodically to a reference rate (SOFR, EURIBOR) + spread.
- **Zero coupon**: issued at a discount, no periodic coupon.
- **Callable**: issuer has the right to redeem before maturity (common in IG and HY). Call schedule specifies dates and prices. Make-whole call provisions require the issuer to pay the present value of remaining cash flows.
- **Putable**: holder can put the bond back to the issuer at specified dates.
- **Convertible**: can be converted into equity shares at a specified conversion ratio.
- **Perpetual/AT1**: no maturity date; issuer has call rights. Common in bank capital (Additional Tier 1 under Basel III). Can be written down or converted to equity if the bank's capital falls below a trigger level.
- **Green/social/sustainability bonds**: use-of-proceeds bonds for environmental or social projects. Same credit structure but with reporting obligations.
- **Sukuk**: Islamic finance bonds structured to comply with Sharia law (no interest; structured as asset-backed or profit-sharing).

**Trading characteristics:**
- Corporate bonds are predominantly traded OTC (over-the-counter), not on exchanges.
- Liquidity is concentrated in recently issued ("on-the-run") bonds and larger issue sizes ($500M+ for IG, $300M+ for HY).
- Bid-ask spreads: 1-5 bps for liquid IG, 25-100+ bps for less liquid HY or distressed.
- Settlement: T+1 for US Treasuries, T+2 for US corporates (historically, now moving to T+1 alignment), varying by jurisdiction.
- Minimum denominations: typically $1,000 or $2,000 face for US corporates, EUR 100,000 for many European bonds (wholesale denomination).

### Municipal Bonds

- Issued by state and local governments, agencies, and authorities in the US.
- **General obligation (GO)**: backed by the full faith and credit (taxing power) of the issuer.
- **Revenue bonds**: backed by specific revenue streams (tolls, utility fees, hospital revenue, etc.).
- **Tax-exempt**: interest is exempt from federal income tax and often state/local tax for in-state holders. This creates a unique investor base (high-net-worth individuals, muni bond funds, insurance companies).
- **Taxable munis**: some municipal bonds are taxable (e.g., Build America Bonds, certain private activity bonds).
- **Yield equivalence**: tax-exempt yield / (1 - marginal tax rate) = taxable equivalent yield. A 3% tax-exempt yield is equivalent to ~4.6% taxable for a 35% bracket investor.
- **Credit quality**: ranges from AAA (many state GOs) to below investment grade. Defaults are rare but do occur (Detroit, Puerto Rico).
- **Market structure**: highly fragmented (~1 million outstanding CUSIPs). Most bonds trade infrequently. Broker-dealers hold inventory and quote on request.
- **Electronic platforms**: growing adoption via platforms like MuniBrokers, TM3, and Bloomberg's municipal trading tools.

### Agency Bonds

- Issued by government-sponsored enterprises (GSEs) and federal agencies.
- **GSE issuers**: Federal Home Loan Banks (FHLB), Fannie Mae, Freddie Mac, Federal Farm Credit Banks.
- **Federal agency issuers**: Ginnie Mae (explicitly government-guaranteed), Tennessee Valley Authority (TVA), etc.
- **Structures**: bullets (non-callable), callable, step-up (coupon increases over time), discount notes (short-term, zero-coupon).
- **Credit quality**: implied government support for GSEs (Fannie/Freddie under conservatorship since 2008). Slightly wider spreads than Treasuries.
- **Liquidity**: very liquid for benchmark callable and bullet issues. FHLB and FFCB are among the largest issuers.

---

## Fixed Income Market Structure

### Dealer-to-Client (D2C)

The traditional model for fixed income trading:

1. Client contacts dealer (via phone, Bloomberg MSG, or electronic platform) with a request to buy or sell.
2. Dealer provides a price (or declines to quote).
3. If the client accepts, the trade is done. The dealer takes the position onto their book.
4. Dealer manages inventory risk by hedging or finding the other side.

**Key characteristics:**
- Principal-based: dealers trade from their own inventory and capital.
- Relationship-driven: pricing quality depends on the client-dealer relationship, trading volume, and information content of the flow.
- Bilateral credit: each party takes counterparty credit risk (mitigated by CCP clearing where available).
- Transparency has historically been low; post-trade reporting (TRACE in the US) has improved price transparency significantly.

### Dealer-to-Dealer (D2D)

Interdealer markets allow dealers to manage inventory by trading with each other:

- **Interdealer brokers (IDBs)**: ICAP (now TP ICAP), BGC Partners, Tullett Prebon, GFI Group, Tradition. Provide voice-brokered and electronic matching services.
- **Anonymous trading**: D2D platforms typically mask counterparty identity pre-trade.
- **Benchmark pricing**: D2D markets often establish the "inside market" (best bid/offer) that informs D2C pricing.

### Electronic Platforms

**Tradeweb:**
- Multi-dealer RFQ platform for rates, credit, munis, and money markets.
- Supports RFQ, click-to-trade (streaming prices), and order book protocols.
- Strong in government bonds, agency MBS, interest rate swaps.
- Tradeweb Direct for institutional and Tradeweb Retail for retail/wealth management.

**MarketAxess:**
- Dominant in US investment grade corporate bond electronic trading.
- Pioneered Open Trading protocol (all-to-all trading where any participant can provide liquidity, not just dealers).
- Strong composite pricing (CP+) used as a benchmark.
- Expanding into EM, HY, and municipal bonds.

**Bloomberg:**
- Bloomberg Terminal's ALLQ (all quotes), BOLT (Bloomberg Order and Liquidity Tracking), and FIT (Fixed Income Trading) functions.
- Extensive messaging (MSG) functionality for voice/text negotiation.
- Bloomberg Valuation Service (BVAL) for bond pricing.
- Bloomberg indices (formerly Barclays indices) are major fixed income benchmarks.

**BrokerTec (CME Group):**
- Leading D2D platform for US Treasuries and European government bonds.
- Central limit order book (CLOB) model for benchmark on-the-run Treasuries.
- BrokerTec Quote provides streaming D2C prices.

**MTS (Euronext):**
- Dominant D2D platform for European government bonds.
- MTS BondVision for D2C.

**ICE Bonds:**
- Municipal bond trading platform.
- ICE BondPoint and TMC (The Muni Center) merged.

**Trumid:**
- All-to-all corporate bond trading platform.
- Focuses on credit (IG and HY).

### Post-Trade Transparency

**TRACE (Trade Reporting and Compliance Engine):**
- Operated by FINRA (US).
- Requires reporting of virtually all OTC fixed income transactions (corporates, agencies, MBS, ABS) within 15 minutes of execution (1 minute for Treasuries as of recent rules).
- Disseminates price and volume data to the public (with some volume caps for large trades to protect liquidity providers).
- TRACE Academic dataset provides complete (uncapped) data for research.

**MiFID II Post-Trade Transparency (Europe):**
- Real-time publication of OTC bond trade data.
- Deferral regime allows delayed publication for large/illiquid trades (varying by jurisdiction).
- Approved Publication Arrangements (APAs) disseminate the data.

---

## Yield Curve Analysis and Trading

### Curve Construction

The yield curve represents the term structure of interest rates. Construction involves:

**Input instruments:**
- **Short end (overnight to 2 years)**: overnight rates (SOFR, EONIA/ESTR), money market rates, FRAs (Forward Rate Agreements), Eurodollar/SOFR futures, short-term swaps.
- **Belly (2 to 10 years)**: interest rate swap rates, government bond yields, futures.
- **Long end (10 to 30+ years)**: long-dated swap rates, long-dated government bonds.

**Bootstrapping:**
- Sequential process to extract zero-coupon (spot) rates from observed par rates.
- Start with the shortest maturity instrument and work outward.
- Each successive instrument is priced using previously derived discount factors, solving for the new unknown rate.

**Interpolation methods:**
- **Linear**: simple but produces discontinuities in forward rates.
- **Cubic spline**: smooth curve through observed points. Natural cubic spline, not-a-knot, or clamped boundary conditions.
- **Monotone convex**: ensures forward rates remain positive and well-behaved.
- **Nelson-Siegel / Svensson**: parametric models that fit the curve using a small number of parameters (level, slope, curvature, and optionally a second hump term). Used by many central banks.
- **Piecewise constant forwards**: simple model assuming constant forward rates between node points.

**Multi-curve framework (post-2008):**
- The financial crisis revealed that LIBOR-based curves and OIS curves diverge significantly.
- Modern curve construction uses OIS discounting (SOFR/ESTR) for all collateralized derivatives, with separate projection curves for each tenor (1M, 3M, 6M SOFR/EURIBOR).
- Cross-currency basis swaps are used to construct curves in one currency collateralized in another.

### Curve Trading Strategies

**Flattener/Steepener:**
- **Bull flattener**: long end rallies more than short end (long rates fall faster). Occurs when the market prices in rate cuts or recession.
- **Bear flattener**: short end sells off more than long end (short rates rise faster). Occurs when the central bank is tightening.
- **Bull steepener**: short end rallies more than long end. Occurs when the central bank is cutting rates.
- **Bear steepener**: long end sells off more than short end. Occurs when inflation expectations rise or term premium increases.
- Implementation: duration-neutral combinations of two bonds/swaps at different maturities (e.g., long 2-year, short 10-year for a flattener).

**Butterfly/Barbell:**
- **Butterfly**: a three-legged trade combining body (one maturity) and wings (two other maturities). For example: short the 5-year, long the 2-year and 10-year.
- **Positive butterfly** (long wings, short body): profits if the belly cheapens relative to the wings (curve becomes more humped).
- **Negative butterfly** (short wings, long body): profits if the belly richens relative to the wings.
- Weighting: typically duration-neutral and cash-neutral (DV01-weighted). Use regression weights or principal-component-based weights for more sophisticated hedging.

**Curve spread trades:**
- **2s10s**: the spread between 2-year and 10-year yields. The most watched curve spread.
- **5s30s**: spread between 5-year and 30-year yields.
- **2s5s10s butterfly**: measures curvature at the 5-year point.
- **Implementation via futures**: use Treasury futures (2yr TU, 5yr FV, 10yr TY, Bond US, Ultra UB) to express curve views. Futures DV01 per contract must be used for proper weighting.

**Roll-down / Carry:**
- A bond "rolls down" the yield curve as time passes (assuming the curve is upward-sloping). A 10-year bond becomes a 9.5-year bond in 6 months, potentially at a lower yield.
- **Carry**: coupon income minus financing cost. Carry = (coupon rate - repo rate) * time.
- **Roll-down return**: additional return from price appreciation due to moving to a lower-yield point on the curve.
- **Carry and roll-down analysis** is fundamental to identifying rich/cheap points on the curve.

---

## Credit Trading

### Investment Grade (IG)

- Bonds rated BBB-/Baa3 or above.
- US IG corporate bond market: ~$7 trillion outstanding.
- Key indices: Bloomberg US Investment Grade Corporate Index, ICE BofA US Corporate Index, iBoxx USD Liquid Investment Grade Index.
- **Spread measures**: OAS (option-adjusted spread) over the Treasury curve or swap curve. IG spreads typically range from 50-200 bps, widening significantly in stress periods.
- **New issue market**: IG issuance is heavy ($1+ trillion/year in the US). New issue concession (premium yield over secondary market) attracts investor participation.
- **Sector trading**: financials (banks, insurance), industrials (energy, utilities, consumer, technology), and structured finance each have distinct spread dynamics.

### High Yield (HY)

- Bonds rated below BBB-/Baa3.
- US HY market: ~$1.5 trillion outstanding.
- Key indices: Bloomberg US Corporate High Yield Index, ICE BofA US High Yield Index.
- **Spread and yield**: HY bonds are often quoted on a price basis rather than spread basis (especially distressed names). Spreads range from 200 bps to 1000+ bps.
- **Credit tiers**: BB (highest quality HY), B (middle), CCC and below (most speculative, approaching distressed).
- **Covenant analysis**: HY bonds have protective covenants (limitations on debt, restricted payments, change of control). Covenant quality has deteriorated over market cycles ("covenant-lite" trends).
- **Call features**: most HY bonds are callable after a non-call period (e.g., NC3 = non-call for 3 years). Call prices step down to par over time.
- **Recovery analysis**: expected recovery rate in default. Senior secured: 60-80%, senior unsecured: 40-50%, subordinated: 20-30% (historical averages, with wide variance).

### Distressed Debt

- Bonds trading below 60-70 cents on the dollar, or with spreads above 1000 bps. Often involves companies in or approaching bankruptcy.
- **Fulcrum security**: the security in the capital structure where the enterprise value "breaks" (i.e., the security that will be partially impaired in a restructuring). Owning the fulcrum security provides leverage in restructuring negotiations.
- **Claims trading**: buying and selling bankruptcy claims at a discount.
- **Chapter 11 process (US)**: debtor-in-possession (DIP) financing, plan of reorganization, creditor committees, equitization (converting debt to equity in the reorganized entity).
- **Loan-to-own strategies**: distressed investors provide DIP financing or buy fulcrum debt with the goal of converting to equity ownership.
- **Event-driven trading**: restructuring announcements, covenant breaches, rating downgrades, tender offers all create trading opportunities.

### Credit Default Swaps (CDS)

A CDS is a bilateral contract where the protection buyer pays a periodic premium (spread) to the protection seller in exchange for a payment if a credit event occurs.

**Mechanics:**
- **Reference entity**: the issuer whose credit is being referenced.
- **Notional amount**: the face amount of protection.
- **Premium (spread)**: quoted in basis points per annum, paid quarterly (typically on IMM dates: March 20, June 20, September 20, December 20).
- **Credit events**: bankruptcy, failure to pay, restructuring (modified restructuring for North American IG, old restructuring for European, no restructuring for North American HY).
- **Settlement**: physical (deliver bonds, receive par) or cash (ISDA auction determines recovery price; seller pays par minus recovery).
- **Standard coupons**: since the Big Bang protocol (2009), CDS trade with standard coupons (100 bps for IG, 500 bps for HY) with upfront payment to equalize. The upfront amount represents the present value of the difference between the running spread and the standard coupon.

**Quoting:**
- IG CDS: quoted in spread (bps per annum).
- HY CDS: often quoted in price (points upfront + running coupon).
- Conversion between spread and upfront price uses the ISDA standard model (flat hazard rate assumption).

### CDS Indices (CDX / iTraxx)

**CDX (North America):**
- **CDX.NA.IG**: 125-name investment grade index. Most liquid credit derivative instrument globally. Rolls every 6 months (Series 1 started in 2003; new series in March and September).
- **CDX.NA.HY**: 100-name high yield index.
- **CDX.NA.IG tranches**: 0-3% (equity), 3-7% (mezzanine), 7-15% (senior), 15-100% (super senior). Tranche trading allows expression of correlation and specific loss views.

**iTraxx (Europe):**
- **iTraxx Europe Main**: 125-name European IG index.
- **iTraxx Crossover (Xover)**: ~75 high yield / crossover names. Very liquid, widely used for macro hedging.
- **iTraxx Senior Financials and Sub Financials**: bank credit indices.

**Index mechanics:**
- Indices roll to a new series every 6 months. The composition is updated (names that have been upgraded, downgraded, or defaulted are replaced).
- On-the-run vs off-the-run indices: the most recent series is most liquid.
- Basis: CDS index spread vs the theoretical spread from individual CDS (the "intrinsic"). Positive basis = index trades wide of intrinsics.
- **Index-to-single-name basis trades**: buy protection on the index, sell protection on individual names (or vice versa) to capture the basis.

---

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

---

## Money Markets

### Instruments

**Treasury Bills (T-bills):**
- US government zero-coupon instruments, maturities up to 52 weeks.
- Auctioned weekly (4-week and 8-week) and monthly (13-, 17-, 26-, 52-week).
- Quoted on a discount yield basis: Price = Face * (1 - discount yield * days to maturity / 360).
- The most liquid and safest money market instrument.

**Commercial Paper (CP):**
- Short-term unsecured promissory notes issued by corporations, typically 1-270 days.
- Issued at a discount. Denominations: typically $100,000 minimum.
- **ABCP (Asset-Backed Commercial Paper)**: issued by conduits backed by pools of assets (trade receivables, auto loans, etc.). ABCP conduits nearly collapsed in 2007-2008.
- Ratings: A-1/P-1 (top tier) to A-3/P-3. Money market funds can only hold A-1/P-1 (or equivalent).

**Certificates of Deposit (CDs):**
- Time deposits issued by banks with a fixed maturity and interest rate.
- **Negotiable CDs**: can be sold in the secondary market before maturity. Large denominations ($100,000+).
- **Brokered CDs**: placed through broker-dealers.
- **Yankee CDs**: USD-denominated CDs issued by foreign banks in the US.
- **Eurodollar CDs**: USD-denominated CDs issued outside the US.

**Federal Funds:**
- Overnight unsecured lending between banks of reserve balances held at the Federal Reserve.
- The federal funds effective rate is the volume-weighted median of overnight fed funds transactions.
- This rate is the primary target of Federal Reserve monetary policy.

**Bankers' Acceptances:**
- Time drafts drawn on and accepted by a bank, used primarily in international trade finance.
- The accepting bank guarantees payment at maturity. Traded at a discount.
- Declining in usage, largely replaced by letters of credit and other trade finance instruments.

### Money Market Fund Considerations

- **Rule 2a-7 (US)**: SEC regulation governing money market funds. Limits on weighted average maturity (WAM <= 60 days), weighted average life (WAL <= 120 days), credit quality, diversification, and liquidity.
- **NAV**: government and retail money market funds may maintain a stable $1.00 NAV. Institutional prime and municipal funds use floating NAV.
- **Liquidity fees and gates**: funds may impose fees or restrict redemptions if weekly liquid assets fall below 30% (fee trigger) or 10% (gate trigger).
- **Investment implications**: MMFs are major buyers of T-bills, repo, CP, and CDs. Their demand patterns influence short-term rates.

---

## Mortgage-Backed Securities

### MBS Pass-Throughs

A pool of residential mortgages is securitized into a pass-through certificate. Investors receive monthly payments of principal (scheduled amortization + prepayments) and interest.

**Agency MBS:**
- Guaranteed by Ginnie Mae (explicit US government guarantee), Fannie Mae, or Freddie Mac (implicit government support, now in conservatorship).
- Credit risk is effectively removed; the primary risk is prepayment risk.
- **Pool characteristics**: coupon rate, weighted average maturity (WAM), weighted average loan age (WALA), loan balance, geographic concentration, loan-to-value (LTV) ratio, FICO score distribution.
- **TBA (To Be Announced)**: the primary trading mechanism for agency MBS. See TBA Trading below.
- **Specified pools**: pools with specific characteristics (low loan balance, high LTV, geographic concentrations) that command a premium ("pay-up") over TBA because of more predictable prepayment behavior.

**Non-agency MBS:**
- Not guaranteed by GSEs. Credit risk borne by investors.
- Structured with subordination (senior/mezzanine/subordinate tranches) to provide credit enhancement.
- Largely collapsed in 2008; the market has partially revived as credit risk transfer (CRT) securities.

### Collateralized Mortgage Obligations (CMOs)

CMOs restructure MBS cash flows into multiple tranches with different risk/return profiles.

**Common tranche types:**
- **Sequential pay**: tranches receive principal in order (A receives all principal until paid off, then B, then C, etc.). Front tranches have shorter average life; back tranches have longer and more uncertain average life.
- **PAC (Planned Amortization Class)**: tranches with a predefined principal payment schedule, protected within a prepayment band. Companion (support) tranches absorb prepayment variability.
- **TAC (Targeted Amortization Class)**: similar to PAC but protected only against faster prepayments (one-sided collar).
- **Z-tranche (accrual)**: receives no cash flow initially; interest accrues and is added to principal. Begins receiving cash flow once preceding tranches are retired.
- **IO (Interest Only) and PO (Principal Only)**: IO receives only interest payments (value increases when rates rise and prepayments slow); PO receives only principal payments (value increases when rates fall and prepayments accelerate).
- **Floater / Inverse floater**: floating-rate and inverse-floating-rate tranches created from fixed-rate collateral.

### TBA Trading

The TBA market is the most liquid segment of the MBS market and one of the most liquid fixed income markets globally.

**Mechanics:**
- Trades are agreed with only six parameters specified: agency (Ginnie, Fannie, Freddie), maturity (30yr, 15yr, 20yr), coupon, price, face amount, and settlement date.
- The actual pool(s) to be delivered are not specified until 48 hours before settlement ("48-hour rule" / notification day).
- The seller has the cheapest-to-deliver option: they will deliver the pools with the worst prepayment characteristics (fastest prepayments for premium coupons, slowest for discounts).
- TBA trades settle monthly on PSA-defined settlement dates (specific day of the month for each coupon/maturity combination).

**Dollar Rolls:**
- Simultaneous sale of TBA for near-month settlement and purchase for far-month settlement.
- Economically similar to a repo: the drop (price difference between months) reflects the financing rate plus the value of the cheapest-to-deliver option.
- Roll specialness: when a particular coupon/maturity trades "special" (the drop is larger than implied by financing rates), it indicates strong demand to borrow that collateral.
- Dollar rolls are a critical financing mechanism and a measure of supply/demand balance in the MBS market.

### Prepayment Analysis

Prepayment risk is the defining characteristic of MBS. Homeowners can refinance their mortgages when interest rates fall, returning principal to investors earlier than expected (reinvestment risk). When rates rise, prepayments slow (extension risk).

**Prepayment measures:**
- **CPR (Conditional Prepayment Rate)**: annualized prepayment rate as a percentage of the remaining balance.
- **SMM (Single Monthly Mortality)**: monthly prepayment rate. CPR = 1 - (1 - SMM)^12.
- **PSA (Public Securities Association) model**: a standard prepayment ramp (0% CPR at month 0, rising linearly to 6% CPR at month 30, constant thereafter). "100% PSA" is this baseline; "200% PSA" is twice as fast, etc.

**Prepayment drivers:**
- **Refinancing**: the dominant driver. Depends on the incentive (current mortgage rate vs coupon rate on existing mortgage), burnout (borrowers who can refinance tend to do so early, leaving a "burned out" pool), and credit/LTV constraints.
- **Housing turnover**: home sales cause payoffs. Relatively stable, driven by demographics and housing market conditions.
- **Curtailment**: partial prepayments (extra principal payments). More common in older, lower-balance pools.
- **Default**: involuntary prepayment. For agency MBS, the GSE guarantee pays the investor at par.

**Prepayment models:**
- Vendor models: Andrew Davidson, Yield Book (LSEG), Bloomberg PREP, Black Knight (ICE), Recursion Co.
- Models predict CPR based on interest rate incentive, loan age, seasonality, burnout, borrower characteristics, and macro factors.
- S-curve: the relationship between refinancing incentive and prepayment speed is S-shaped (no prepayments when rates are above the coupon, accelerating prepayments as rates fall below the coupon, flattening at high incentive levels due to borrower capacity constraints).

---

## Fixed Income Analytics

### Duration

**Macaulay Duration:**
- Weighted average time to receive the bond's cash flows, where the weights are the present values of the cash flows.
- Expressed in years. Higher coupon bonds have shorter duration than lower coupon bonds at the same maturity.

**Modified Duration:**
- Measures the percentage price change for a 1% (100 bps) change in yield.
- Modified Duration = Macaulay Duration / (1 + yield/n), where n is the number of compounding periods per year.
- Example: a bond with modified duration of 5.0 will decrease in price by approximately 5% for a 100 bps increase in yield.

**Effective Duration (Option-Adjusted Duration):**
- Measures price sensitivity to a parallel shift in the benchmark yield curve, accounting for embedded options (calls, puts, prepayment options).
- Calculated numerically: (P_down - P_up) / (2 * P_0 * delta_y), where P_down and P_up are prices under shifted curves.
- Essential for callable bonds and MBS, where modified duration is misleading.

**DV01 (Dollar Value of a Basis Point) / PV01:**
- Dollar change in price for a 1 bp change in yield.
- DV01 = Modified Duration * Price * 0.0001.
- The standard unit for hedging: to hedge a $10M position with DV01 of $800, find a hedge instrument whose DV01 offsets.

**Key Rate Duration (KRD):**
- Measures sensitivity to changes in specific points on the yield curve (e.g., 2-year, 5-year, 10-year, 30-year key rates).
- Essential for managing curve risk in a portfolio. A portfolio may be duration-neutral but have significant exposure to curve reshaping.
- Sum of all key rate durations equals the effective duration.

### Convexity

- Measures the curvature of the price-yield relationship (the second derivative).
- **Positive convexity**: most option-free bonds. The price increases more for a rate decrease than it decreases for an equal rate increase. This is beneficial for the holder.
- **Negative convexity**: callable bonds and MBS. When rates fall, the bond's upside is limited by the call or prepayment option. The price-yield curve flattens or bends downward on the left side.
- **Convexity adjustment**: for large yield changes, duration alone underestimates price changes. The convexity adjustment = 0.5 * Convexity * (delta_y)^2.
- **Dollar convexity**: convexity expressed in dollar terms.

### Spread Measures

**Nominal Spread (G-spread):**
- Yield spread over the interpolated government bond yield curve.
- Simple to calculate but ignores the term structure of rates (uses a single point on the curve).

**Z-spread (Zero-Volatility Spread):**
- The constant spread added to each point on the spot rate (zero-coupon) curve that makes the present value of the bond's cash flows equal to its market price.
- Better than nominal spread because it uses the entire curve, not a single benchmark.
- Appropriate for option-free bonds.

**I-spread (Interpolated Spread):**
- Spread over the swap curve (SOFR or EURIBOR swap rates).
- Used when the swap curve is the relevant benchmark (common in European markets and for financial institution bonds).
- Typically quoted as the bond yield minus the linearly interpolated swap rate at the bond's maturity.

**OAS (Option-Adjusted Spread):**
- The spread added to the risk-free rate in an interest rate model that equates the model price to the market price, after accounting for embedded options.
- Uses a term structure model (e.g., Black-Karasinski, Hull-White, BDT) to generate interest rate paths. Along each path, cash flows are adjusted for option exercise (calls, prepayments). The OAS is the spread that makes the average present value across all paths equal to the market price.
- The gold standard for comparing bonds with different embedded options.
- **OAS vs Z-spread**: for option-free bonds, OAS equals Z-spread. For callable bonds, OAS is less than Z-spread (the difference is the option cost). For putable bonds, OAS is greater than Z-spread.

**ASW (Asset Swap Spread):**
- The spread earned by an investor who buys a bond and swaps the fixed coupons to floating. Reflects the bond's credit spread relative to the swap curve.
- Par ASW vs market ASW: par ASW assumes the bond is purchased at par (adjustment for premium/discount); market ASW uses the actual market price.
- Commonly used in the European market for relative value analysis.

**CDS-Bond Basis:**
- CDS spread minus bond spread (usually Z-spread or ASW).
- **Positive basis**: CDS is wider than the bond spread. Can arise from cheapest-to-deliver optionality in CDS, funding costs, or counterparty risk.
- **Negative basis**: bond spread is wider than CDS. Can arise from cash bond illiquidity, forced selling, or funding dislocations.
- Negative basis trades (buy the bond, buy CDS protection) were popular pre-2008 and blew up when funding costs spiked.

### Relative Value Metrics

**Rich/cheap analysis:**
- Compare a bond's OAS or Z-spread to a fitted curve (spline or model) of similar bonds.
- Residual (actual spread minus fitted spread) indicates richness (negative residual) or cheapness (positive residual).
- Must control for differences in liquidity, issue size, coupon, and embedded options.

**Carry and roll-down:**
- As described in the yield curve section, but applied specifically to each bond.
- Total expected return = carry + roll-down + spread change * duration + convexity adjustment.

---

## RFQ (Request for Quote) Workflows

### Standard RFQ Process

The RFQ is the dominant electronic trading protocol in fixed income.

**Workflow:**
1. **Client initiates**: specifies security (CUSIP/ISIN), direction (buy/sell), and quantity (face amount). May include a target price or leave it open.
2. **Dealer selection**: client selects 3-10 dealers to compete for the trade (platform rules may require a minimum number of dealers).
3. **Quote submission**: dealers have a defined time window (30 seconds to several minutes, depending on the platform and asset class) to submit firm, executable prices.
4. **Comparison and execution**: client compares all received quotes and selects the best price (or rejects all). Execution is immediate upon selection.
5. **Trade confirmation and reporting**: platform generates trade confirmations and reports to TRACE (or equivalent).

**RFQ variations:**
- **Indicative RFQ**: dealers provide indicative (non-binding) prices. Client may follow up bilaterally for a firm price.
- **Disclosed vs anonymous**: most D2C RFQs are disclosed (the client reveals their identity). Some platforms offer anonymous RFQ.
- **Dealer-to-dealer RFQ**: interdealer platforms like Tradeweb D2D or Bloomberg IB allow dealers to RFQ each other.

### RFQ Optimization

**For the client (buy-side):**
- **Dealer selection strategy**: balance between competitive tension (more dealers) and information leakage (each dealer knows you are looking to trade).
- **Timing**: RFQ during active hours (10 AM - 3 PM ET for US credit) yields tighter quotes.
- **Size signaling**: very large sizes may cause dealers to widen their quotes or decline. Consider breaking large orders into smaller RFQs.
- **Auto-execution rules**: set up automated acceptance of quotes that meet specified price thresholds.

**For the dealer (sell-side):**
- **Pricing engine**: automated pricing based on inventory position, market conditions, client tier, and expected information content.
- **Win rate optimization**: track hit rates per client and adjust pricing to optimize the revenue vs risk trade-off.
- **Inventory management**: integrate RFQ responses with overall inventory position and risk limits.
- **Axes**: proactively advertise bonds the desk wants to buy or sell (axed inventory) to attract matching RFQs.

### All-to-All Trading

A newer model where any participant (not just traditional dealers) can respond to RFQs or provide liquidity:

- **MarketAxess Open Trading**: the leading all-to-all protocol. Any client can respond to an RFQ, not just dealers. This democratizes liquidity provision.
- **Trumid**: all-to-all platform for credit.
- **Benefits**: more liquidity sources, tighter spreads, particularly for off-the-run/less liquid bonds.
- **Challenges**: credit intermediation (how to manage counterparty risk when non-dealers are trading), settlement logistics.

---

## Electronic Bond Trading Evolution and Protocols

### Historical Evolution

**Pre-2000: Voice-only**
- All bond trading conducted via phone between traders.
- Pricing was opaque; no post-trade transparency.
- Dealer balance sheets funded large inventory positions.

**2000-2010: Early electronification**
- RFQ platforms launched (TradeWeb for government bonds, MarketAxess for credit).
- TRACE introduced post-trade transparency for US corporate bonds (2002).
- Electronic trading share: government bonds ~50%, IG credit ~10-15%.

**2010-2020: Acceleration**
- MiFID II (2018) mandated pre- and post-trade transparency and best execution.
- All-to-all protocols emerged (MarketAxess Open Trading, Trumid).
- Portfolio trading protocols launched.
- Algo/systematic trading entered fixed income.
- Electronic share of IG credit trading grew to ~35-40%.

**2020-present: Maturation**
- COVID-19 pandemic accelerated electronification (voice trading difficult with remote work).
- Portfolio trading became a major protocol for credit (~6-8% of US IG volume).
- Automated/algo execution by buy-side firms increased.
- Electronic share: IG credit ~40-50%, HY credit ~30-35%, government bonds ~70-80%.

### Trading Protocols

**Click-to-Trade (Streaming):**
- Dealers stream continuous firm prices to clients.
- Client clicks to execute at the displayed price.
- Dominant in government bonds (especially on-the-runs) and liquid IG credit.
- Requires the dealer to manage quote staling risk (prices become stale in fast markets).

**Central Limit Order Book (CLOB):**
- Continuous anonymous order matching (like equity exchanges).
- Used for government bonds on BrokerTec and MTS (D2D).
- Limited adoption for corporate bonds due to lower liquidity and heterogeneity of instruments.

**Portfolio Trading:**
- Client submits a basket of bonds (50 to 1000+ line items) as a single package.
- Dealers bid on the entire portfolio, providing a single price (typically expressed as a spread to a benchmark or as a percentage of par).
- Benefits: operational efficiency (one execution for many bonds), potential for netting (dealer may already own some bonds in the basket or can cross-hedge).
- Dominant in ETF creation/redemption baskets and large portfolio rebalances.
- Platforms: Tradeweb, MarketAxess, Bloomberg.

**Session-Based Trading:**
- Orders are collected during a defined window and then matched in a crossing session.
- Used by some platforms for less liquid bonds.

**Processed Trading / Work-Up:**
- After an initial trade on a CLOB, other participants can "work up" additional volume at the same price for a limited time.
- Common on BrokerTec for Treasuries.

### Data and Analytics in Electronic Trading

**Composite pricing:**
- Aggregation of dealer quotes and trade data to establish a "fair value" mid-price.
- MarketAxess CP+ (Composite Plus), Bloomberg BVAL, ICE Pricing, Refinitiv evaluated pricing.
- Used as a pre-trade benchmark, a reference for RFQ evaluation, and for portfolio valuation.

**Transaction Cost Analysis (TCA):**
- Post-trade analysis of execution quality relative to benchmarks (arrival price, composite mid, VWAP equivalent).
- Increasingly mandated by regulations (MiFID II best execution) and demanded by asset owners.
- Metrics: implementation shortfall, spread to mid at time of trade, market impact.

**Liquidity scores:**
- Vendor-provided estimates of bond liquidity (frequency of trading, number of dealers quoting, depth of quotes, bid-ask spread).
- Used for portfolio liquidity risk management, trade scheduling, and venue selection.
- Examples: MarketAxess Liquidity Score, Bloomberg LQA, ICE Liquidity Indicators.

---

## Key Data Requirements for a Fixed Income Trading Platform

| Data Type | Sources | Update Frequency |
|---|---|---|
| Reference data (CUSIP, ISIN, terms, covenants) | Bloomberg, Refinitiv, ICE | Daily with event-driven |
| Real-time quotes | Tradeweb, MarketAxess, Bloomberg, dealer streams | Real-time |
| Trade reporting (TRACE) | FINRA | Real-time (15-min delay public) |
| Yield curves (government, swap, OIS) | Bloomberg, Refinitiv, internal curve engines | Real-time/intraday |
| Credit ratings | S&P, Moody's, Fitch | Event-driven |
| CDS spreads | Markit (S&P Global), Bloomberg | End-of-day / intraday |
| Prepayment models and speeds | Andrew Davidson, Yield Book, Bloomberg | Monthly actuals, daily model updates |
| Repo rates (GC and specials) | DTCC GCF Repo Index, SOFR, dealer indications | Daily |
| Index compositions and analytics | Bloomberg Barclays, ICE BofA, JP Morgan, FTSE Russell | Daily |
| New issue calendars | Bloomberg, IFR, Dealogic | Daily/event-driven |
| Regulatory filings (13F, EMMA for munis) | SEC EDGAR, MSRB EMMA | Periodic |
