# Ramp REST API Introduction

## Overview

The Payward Ramp REST API enables partners to incorporate cryptocurrency on-ramp capabilities into their applications, allowing users to purchase cryptocurrency using fiat currencies.

## Base URL

```
https://nexus.kraken.com
```

## Authentication

The API requires two headers for request authentication:

| Header | Description |
|--------|-------------|
| `API-Key` | Your API key credential. |
| `API-Sign` | Request signature created using your private key, nonce, encoded payload, and URI path. |

## API Versioning

Requests must include a date-based version header:

```
Payward-Version: 2025-04-15
```

## Available Endpoint Categories

### Supported Options

Query available cryptocurrencies, fiat currencies, payment methods, and countries.

- [List Buy Crypto Assets](get-ramp-buy-crypto-assets.md)
- [List Fiat Currencies](get-ramp-fiat-currencies.md)
- [List Payment Methods](get-ramp-payment-methods.md)
- [List Countries](get-ramp-countries.md)

### Quotes

Obtain prospective pricing and transaction limits.

- [Get Ramp Limits](get-ramp-limits.md)
- [Get Ramp Prospective Quote](get-ramp-prospective-quote.md)

### Checkout

Generate hosted checkout experiences.

- [Get Ramp Checkout](get-ramp-checkout.md)

### Webhooks

Transaction update notifications.

- [Ramp Transaction Update Webhook](ramp-transaction-update-webhook.md)

## Notes

- All endpoints require the `API-Key` and `API-Sign` authentication headers.
- Include the `Payward-Version` header with every request.
- The Ramp API is designed for partner integrations enabling crypto on-ramp functionality.

---

*Source: [Kraken API Documentation -- Ramp REST API Introduction](https://docs.kraken.com/api/docs/ramp-api/intro)*
