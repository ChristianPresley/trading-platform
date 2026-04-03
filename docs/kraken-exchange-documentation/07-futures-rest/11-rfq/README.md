# RFQ (Request for Quote)

Block trade negotiation endpoints -- creating, offering on, accepting, and managing Requests for Quote.

## Contents

1. [Accept RFQ Offer](01_Accept-Rfq-Offer.md) -- Accept a bid or ask offer on an open RFQ created by the authenticated account.
   - `POST /rfqs/open-rfqs/accept-offer/:rfqUid`
2. [Cancel RFQ Offer](02_Cancel-Rfq-Offer.md) -- Cancel the current open offer on a specified RFQ.
   - `DELETE /rfqs/cancel-offer/:rfqUid`
3. [Cancel User RFQ](03_Cancel-User-Rfq.md) -- Cancel an open RFQ created by the authenticated account.
   - `DELETE /rfqs/open-rfqs/:rfqUid`
4. [Create User RFQ](04_Create-User-Rfq.md) -- Create a new Request for Quote to initiate a block trade negotiation.
   - `POST /rfqs/open-rfqs`
5. [Get Open RFQ](05_Get-Open-Rfq.md) -- Retrieve a single open RFQ by its unique identifier.
   - `GET /rfqs/:rfqUid`
6. [Get Open RFQ Offers](06_Get-Open-Rfq-Offers.md) -- List all open offers placed by the authenticated account on active RFQs.
   - `GET /rfqs/open-offers`
7. [Get Open RFQs for Account](07_Get-Open-Rfqs-For-Account.md) -- List all open RFQs created by the authenticated account.
   - `GET /rfqs/open-rfqs`
8. [Get Open RFQs](08_Get-Open-Rfqs.md) -- List all currently open RFQs on the platform.
   - `GET /rfqs`
9. [Place RFQ Offer](09_Place-Rfq-Offer.md) -- Place a new bid and/or ask offer on an open RFQ.
   - `POST /rfqs/place-offer/:rfqUid`
