# OTC REST

Over-the-counter (OTC) trading REST API — quotes, eligibility, and trade execution.

## Contents

1. [Check OTC Eligibility](01_Check-Otc-Eligibility.md) — Verify whether the authenticated account has permissions to use OTC trading features.
   - `POST /private/CheckOtcClient`
2. [Create OTC Quote Request](02_Create-Otc-Quote-Request.md) — Create a new OTC request for quote.
   - `POST /private/CreateOtcQuoteRequest`
3. [Get OTC Active Quotes](03_Get-Otc-Active-Quotes.md) — Retrieve currently active OTC quotes.
   - `POST /private/GetOtcActiveQuotes`
4. [Get OTC Historical Quotes](04_Get-Otc-Historical-Quotes.md) — Retrieve the historical record of OTC quotes.
   - `POST /private/GetOtcHistoricalQuotes`
5. [Get OTC Pairs](05_Get-Otc-Pairs.md) — Retrieve the list of available OTC trading pairs.
   - `POST /private/GetOtcPairs`
