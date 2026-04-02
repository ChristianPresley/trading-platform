## Client Onboarding for Trading

### 9.1 Account Setup

Client onboarding for trading is a multi-week process involving legal, compliance, credit, operations, and technology teams.

**Account setup workflow**:

**Phase 1: Client Due Diligence (CDD) - Week 1-3**
1. Collect client identification documents (certificate of incorporation, articles of association, director/shareholder registers)
2. Perform Know Your Customer (KYC) checks:
   - Identity verification (directors, beneficial owners, authorized signatories)
   - Sanctions screening (OFAC, EU sanctions, UN sanctions)
   - Adverse media screening
   - Politically Exposed Person (PEP) screening
   - Anti-money laundering (AML) risk assessment
3. Assign a risk rating (low, medium, high, prohibited)
4. Obtain Legal Entity Identifier (LEI) or verify existing LEI
5. Determine client classification (MiFID II: retail, professional, eligible counterparty)

**Phase 2: Legal Documentation - Week 2-4**
1. Execute trading agreements:
   - ISDA Master Agreement (for OTC derivatives)
   - Credit Support Annex (CSA) for collateral management
   - Global Master Repurchase Agreement (GMRA) for repos
   - Master Securities Lending Agreement (MSLA) for securities lending
   - Prime brokerage agreement
   - Give-up agreement (if applicable)
2. Obtain authorized trader list (who at the client can place orders)
3. Obtain authorized settlement instruction signatories

**Phase 3: Credit and Limit Setup - Week 3-4**
1. Credit analysis (financial statement review, credit rating, counterparty risk assessment)
2. Set credit limits:
   - Pre-settlement exposure limit (mark-to-market exposure)
   - Settlement exposure limit (pending settlement amounts)
   - Product-specific limits (FX, rates, credit, equity)
   - Tenor limits (for derivatives)
   - Country limits (for EM exposure)
3. Set margin parameters (initial margin, variation margin, haircuts)
4. Configure netting agreements

**Phase 4: Operational Setup - Week 3-5**
1. Create client entity in the counterparty master
2. Configure settlement instructions (SSIs):
   - Cash correspondent bank details per currency
   - Securities custodian/depository details per market
   - SWIFT BIC codes, account numbers
3. Set up confirmation routing (SWIFT, DTCC, email)
4. Configure market data and research access (if applicable)
5. Set up client portal access (trade reporting, statement access)
6. Test connectivity (FIX session if electronic trading, API access)

**Phase 5: Go-Live - Week 5**
1. Operational readiness review (all systems configured, all documentation signed)
2. Test trade execution (small test trade through full lifecycle)
3. Verify confirmation delivery
4. Verify settlement processing
5. Go-live approval from operations, compliance, and relationship management
6. First trade with the client

### 9.2 Credit Limits

Credit limit management is a continuous process that extends well beyond initial onboarding.

**Credit limit structure**:
```
Client: ABC Fund
  Aggregate Credit Limit: $50M
    Pre-settlement Limit: $30M
      FX: $15M
      Rates: $10M
      Credit: $5M
    Settlement Limit: $20M
      DvP: $15M (lower risk, delivery vs. payment)
      FoP: $5M (higher risk, free of payment)
  Margin Terms:
    Initial Margin: 5% of notional
    Variation Margin: Daily, cash only
    Minimum Transfer Amount: $500K
    Rounding: $100K
```

**Credit limit monitoring**:
- Real-time utilization tracking (pre-trade and post-trade)
- Automated alerts at utilization thresholds (75%, 90%, 100%)
- Intraday mark-to-market of exposure
- What-if analysis (impact of a proposed trade on credit utilization)

### 9.3 Margin Agreements

Margin agreements define how collateral is exchanged between counterparties to mitigate credit risk.

**Margin workflow**:
1. **Calculation**: Each business day, calculate the mark-to-market exposure for each margined relationship
2. **Netting**: Net the exposure across all trades under the netting agreement
3. **Threshold and MTA**: Apply the threshold (exposure below which no margin is required) and minimum transfer amount
4. **Call**: If the net exposure exceeds the threshold + MTA, issue a margin call to the counterparty (or receive one)
5. **Delivery**: Counterparty delivers collateral (cash or eligible securities) by the agreed deadline (typically T+1 for variation margin)
6. **Valuation**: Value received collateral (applying haircuts to securities collateral)
7. **Dispute resolution**: If the counterparty disputes the margin call amount, initiate the dispute resolution procedure defined in the CSA/regulatory framework
8. **Substitution**: If the counterparty wants to substitute one piece of collateral for another, validate the substitution against eligibility criteria
