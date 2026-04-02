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
