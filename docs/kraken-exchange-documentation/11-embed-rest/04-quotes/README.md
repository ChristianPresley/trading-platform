# Quotes

Embed API endpoints for requesting, retrieving, and executing trade quotes.

## Contents

1. [Execute Embed Quote](01_Execute-Embed-Quote.md) — Execute a previously requested quote to complete a trade.
   - `PUT /b2b/quotes/:quote_id`
2. [Get Embed Quote Limits](02_Get-Embed-Quote-Limits.md) — Get minimum, maximum, and precision limits for a given asset pair.
   - `GET /b2b/quotes/limits`
3. [Get Embed Quote](03_Get-Embed-Quote.md) — Retrieve the status of a previously requested quote.
   - `GET /b2b/quotes/:quote_id`
4. [List Embed Tradable Assets](04_List-Embed-Tradable-Assets.md) — List tradable assets available for a user, including trading status and pair restrictions.
   - `GET /b2b/quotes/assets`
5. [Request Embed Prospective Quote](05_Request-Embed-Prospective-Quote.md) — Get an indicative price and fee for an asset pair without reserving liquidity.
   - `POST /b2b/quotes/prospective`
6. [Request Embed Quote](06_Request-Embed-Quote.md) — Request a price quote for an asset that can be executed later.
   - `POST /b2b/quotes`
