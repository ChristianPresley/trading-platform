# Ramp REST API

## Overview

The Ramp REST API provides endpoints for cryptocurrency on-ramp transactions, enabling partners to integrate fiat-to-crypto purchasing capabilities.

## Authentication

The Ramp REST API utilizes two authentication headers:

### API-Key Header

The `API-Key` header should contain your API key.

### API-Sign Header

Authenticated requests require signing with the `API-Sign` header, utilizing a signature generated with your private key, nonce, encoded payload, and URI path.

### Signature Generation

The API-Sign value is computed using:
1. Your private key
2. A nonce value
3. The encoded request payload
4. The URI path

## API Versioning

Include the version header with all requests:

```
Payward-Version: 2025-04-15
```

## Base URL

```
https://nexus.kraken.com
```

## Available Endpoints

### Supported Options
- `GET /b2b/ramp/buy/crypto` -- List buy crypto assets
- `GET /b2b/ramp/fiat-currencies` -- List fiat currencies
- `GET /b2b/ramp/payment-methods` -- List payment methods
- `GET /b2b/ramp/countries` -- List countries

### Quotes & Limits
- `GET /b2b/ramp/limits` -- Get transaction limits
- `GET /b2b/ramp/quotes/prospective` -- Get prospective quote

### Checkout
- `GET /b2b/ramp/checkout` -- Generate checkout URL

### Webhooks
- `POST /webhooks/payward/transaction-update` -- Transaction update webhook

## Notes

- All requests must include both `API-Key` and `API-Sign` headers.
- The `Payward-Version` header is required on all requests.
- See individual endpoint documentation for detailed parameters and response schemas.

---

*Source: [Kraken API Documentation -- Ramp REST API](https://docs.kraken.com/api/docs/ramp-api/ramp-rest-api)*
