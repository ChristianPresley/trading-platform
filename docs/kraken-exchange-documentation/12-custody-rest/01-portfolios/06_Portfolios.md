# Portfolios

## Overview

The Portfolios section of the Kraken Custody REST API provides endpoints for managing and querying custody vaults, balances, deposit methods, deposit addresses, and transaction history.

## Available Endpoints

| Endpoint | Description |
|----------|-------------|
| [List Vaults](list-custody-vaults.md) | Retrieve all vaults within the custody domain |
| [Get Vault Information by ID](get-custody-vault.md) | Retrieve information and balances for a specific vault |
| [Get Custody Balance](get-custody-balance.md) | Retrieve the balance for each asset held in the specified vault |
| [Get Deposit Methods](deposit-methods.md) | Retrieve available deposit funding methods for depositing a specific asset |
| [Get Deposit Addresses](deposit-addresses.md) | Retrieve (or generate a new) deposit addresses for a particular asset |

## Related Sections

- [Custody Transactions](../../custody-transactions/) - Transaction history and transaction lookup
- [Transfers](../transfers/) - Withdrawal methods and addresses
- [Tasks](../tasks/) - Review tasks and activities

## Authentication

All endpoints in the Portfolios section are private endpoints (URL path contains `/private/`), requiring authenticated API access. Requests must include valid API credentials.

## Base URL

All Custody REST API endpoints use the following base path pattern:

```
POST /0/private/<EndpointName>
```

## Source

- [Kraken API Documentation - Portfolios](https://docs.kraken.com/api/docs/custody-api/portfolios)
