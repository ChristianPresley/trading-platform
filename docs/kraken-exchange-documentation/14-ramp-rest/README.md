# Ramp REST

Fiat on/off ramp REST API — payment methods, quotes, checkout, and webhooks.

## Contents

1. [List Buy Crypto Assets](01_Get-Ramp-Buy-Crypto-Assets.md) — List cryptocurrency assets available for Ramp buy transactions, including networks and withdrawal methods.
   - `GET /b2b/ramp/buy/crypto`
2. [Get Ramp Checkout](02_Get-Ramp-Checkout.md) — Generate a hosted checkout URL for a given transaction configuration.
   - `GET /b2b/ramp/checkout`
3. [List Countries](03_Get-Ramp-Countries.md) — List countries and regions where Ramp is available, including sub-regional restrictions.
   - `GET /b2b/ramp/countries`
4. [List Fiat Currencies](04_Get-Ramp-Fiat-Currencies.md) — Retrieve fiat currencies supported for funding Ramp transactions.
   - `GET /b2b/ramp/fiat-currencies`
5. [Get Ramp Limits](05_Get-Ramp-Limits.md) — Retrieve combined min/max limits for a Ramp transaction configuration.
   - `GET /b2b/ramp/limits`
6. [List Payment Methods](06_Get-Ramp-Payment-Methods.md) — List fiat payment methods supported for Ramp deposits, with optional provider-specific identifiers.
   - `GET /b2b/ramp/payment-methods`
7. [Get Ramp Prospective Quote](07_Get-Ramp-Prospective-Quote.md) — Preview spend/receive amounts for a Ramp transaction without reserving liquidity.
   - `GET /b2b/ramp/quotes/prospective`
8. [Introduction](08_Introduction.md) — Overview of the Payward Ramp REST API, base URL, authentication, and versioning.
9. [Ramp REST API](09_Ramp-Rest-Api.md) — Authentication details, signature generation, and API versioning reference.
10. [Ramp Transaction Update Webhook](10_Ramp-Transaction-Update-Webhook.md) — Partner-implemented webhook for receiving real-time transaction status updates via HMAC-signed POST requests.
    - `POST /webhooks/payward/transaction-update`
