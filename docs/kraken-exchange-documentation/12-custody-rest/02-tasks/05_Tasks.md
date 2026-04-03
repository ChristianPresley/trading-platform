# Tasks

## Overview

The Tasks section of the Kraken Custody REST API provides endpoints for managing and querying review tasks and their associated activities within the custody domain.

## Available Endpoints

| Endpoint | Description |
|----------|-------------|
| [List Tasks](list-custody-tasks.md) | Retrieve review tasks that match the specified filter criteria |
| [Get Task by ID](get-custody-task.md) | Retrieve details for a specific task |
| [List Activities](list-custody-tasks-activities.md) | Retrieve all activities that match the specified filter criteria |
| [Get Activity by ID](get-custody-activity.md) | Retrieve details for a specific task activity |

## Related Sections

- [Portfolios](../portfolios/) - Vault management, balances, and deposit operations
- [Transfers](../transfers/) - Withdrawal methods and addresses
- [Custody Transactions](../../custody-transactions/) - Transaction history and lookup

## Authentication

All endpoints in the Tasks section are private endpoints (URL path contains `/private/`), requiring authenticated API access. Requests must include valid API credentials.

## Base URL

All Custody REST API endpoints use the following base path pattern:

```
POST /0/private/<EndpointName>
```

## Source

- [Kraken API Documentation - Tasks](https://docs.kraken.com/api/docs/custody-api/tasks)
