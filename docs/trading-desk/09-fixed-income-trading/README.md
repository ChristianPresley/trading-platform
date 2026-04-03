# Fixed Income Trading

Comprehensive reference for fixed income asset-class features on a professional trading desk. Covers bonds, rates derivatives, credit, repo, money markets, securitized products, analytics, and electronic trading workflows.

## Contents

1. [Bond Trading and Market Structure](01_Bond-Trading-And-Market-Structure.md) — Government, corporate, municipal, and agency bond types; dealer-to-client and dealer-to-dealer market structure; electronic trading platforms (Tradeweb, MarketAxess, BrokerTec)
   - `TreasuryNote`, `CorporateBond`, `MunicipalBond`, `AgencyBond`, `CallableBond`, `ConvertibleBond`, `TRACEReport`, `RFQProtocol`, `CLOBMatch`

2. [Yield Curve Analysis and Credit Trading](02_Yield-Curve-Analysis-And-Credit-Trading.md) — Curve bootstrapping, interpolation methods, multi-curve framework, flattener/steepener/butterfly strategies, IG/HY/distressed credit, and CDS indices (CDX/iTraxx)
   - `CurveBootstrap`, `CubicSplineInterp`, `NelsonSiegelModel`, `FlattenerTrade`, `ButterflyTrade`, `CarryRollDown`, `CreditDefaultSwap`, `CDXIndex`, `iTraxxXover`

3. [Interest Rate Derivatives and Repo](03_Interest-Rate-Derivatives-And-Repo.md) — Vanilla and basis IRS, swaptions, caps/floors, FRAs, SOFR transition mechanics, and repo structures (overnight, term, tri-party, GC vs special)
   - `InterestRateSwap`, `BasisSwap`, `PayerSwaption`, `ReceiverSwaption`, `Cap`, `Floor`, `FRA`, `RepoTrade`, `TriPartyRepo`, `DollarRoll`

4. [Money Markets and Mortgage-Backed Securities](04_Money-Markets-And-Mortgage-Backed-Securities.md) — T-bills, commercial paper, CDs, fed funds; agency MBS pass-throughs, CMO tranches (PAC, IO/PO, Z-tranche), TBA trading, and prepayment modeling
   - `TreasuryBill`, `CommercialPaper`, `NegotiableCD`, `MoneyMarketFund`, `MBSPassThrough`, `CMOTranche`, `TBATrade`, `DollarRoll`, `PrepaymentModel`, `CPR`, `PSAModel`

5. [Fixed Income Analytics](05_Fixed-Income-Analytics.md) — Duration (Macaulay, modified, effective, key-rate), convexity, spread measures (G-spread, Z-spread, OAS, ASW, CDS-bond basis), and rich/cheap relative-value analysis
   - `MacaulayDuration`, `ModifiedDuration`, `EffectiveDuration`, `KeyRateDuration`, `DV01`, `Convexity`, `ZSpread`, `OAS`, `AssetSwapSpread`, `CDSBondBasis`

6. [Electronic Trading and RFQ Workflows](06_Electronic-Trading-And-RFQ-Workflows.md) — RFQ lifecycle and optimization, all-to-all and portfolio trading protocols, click-to-trade streaming, composite pricing, and transaction cost analysis (TCA)
   - `RFQWorkflow`, `DealerPricingEngine`, `AllToAllMatch`, `PortfolioTrade`, `ClickToTrade`, `CompositePrice`, `TransactionCostAnalysis`, `LiquidityScore`
