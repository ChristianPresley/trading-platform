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
