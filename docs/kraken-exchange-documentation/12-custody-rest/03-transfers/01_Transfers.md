# Transfers

## Overview

The Transfers section of the Kraken Custody REST API provides endpoints for managing withdrawal methods and withdrawal addresses for custody vaults.

## Available Endpoints

| Endpoint | Description |
|----------|-------------|
| [Get Withdraw Methods](withdraw-methods.md) | Retrieve a list of withdrawal methods available for a specified vault |
| [Get Withdraw Addresses](withdraw-addresses.md) | Retrieve a list of withdrawal addresses for a specified vault |

## Related Sections

- [Portfolios](../portfolios/) - Vault management, balances, and deposit operations
- [Tasks](../tasks/) - Review tasks and activities
- [Custody Transactions](../../custody-transactions/) - Transaction history and lookup

## Authentication

All endpoints in the Transfers section are private endpoints (URL path contains `/private/`), requiring authenticated API access. Requests must include valid API credentials.

## Base URL

All Custody REST API endpoints use the following base path pattern:

```
POST /0/private/<EndpointName>
```

## Source

- [Kraken API Documentation - Transfers](https://docs.kraken.com/api/docs/custody-api/transfers)
