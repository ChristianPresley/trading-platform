# Account History

Source: [https://docs.kraken.com/api/docs/futures-api/history/account-history](https://docs.kraken.com/api/docs/futures-api/history/account-history)

## Overview

The Account History section provides access to account-specific historical data through several endpoints under the Futures REST API. These endpoints return paginated JSON responses with access to private account history specified by ranges of timestamp or ID.

## Available Endpoints

| Endpoint | Method | Path | Description |
|----------|--------|------|-------------|
| [Get Execution Events](get-execution-events.md) | GET | `/api/history/v2/executions` | Lists executions/trades for authenticated account |
| [Get Order Events](get-order-events.md) | GET | `/api/history/v2/orders` | Lists order events for authenticated account |
| [Get Trigger Events](get-trigger-events.md) | GET | `/api/history/v2/triggers` | Lists trigger events for authenticated account |

## Base URL

```
https://futures.kraken.com
```

## Authentication

All Account History endpoints require authentication.

**Required Headers:**

| Header | Description |
|--------|-------------|
| `APIKey` | Your Kraken Futures API public key |
| `Authent` | Authentication signature |
| `Nonce` | A unique, incrementing value for each request (optional) |

**Authentication Computation:**

The `Authent` header is computed as follows:

1. Concatenate `postData + Nonce + endpointPath`
2. Hash the result with SHA-256
3. Base64-decode the `api_secret`
4. Use the decoded secret to compute HMAC-SHA-512 of the SHA-256 hash from step 2
5. Base64-encode the HMAC result

**Required Permission:** `General API - Read Only` (minimum)

## Common Query Parameters

All Account History endpoints share the following pagination and filtering parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `before` | integer | No | Filter to only return results before a specific timestamp (epoch milliseconds) |
| `since` | integer | No | Filter by specifying a start point (epoch milliseconds) |
| `continuation_token` | string | No | Token returned from a previous request, used to continue requesting historical events |
| `sort` | string | No | Sort the results (e.g., `asc` or `desc`) |
| `tradeable` | string | No | Filter results by a specific contract/asset (e.g., `PI_XBTUSD`, `PF_SOLUSD`) |

## Common Response Structure

All Account History endpoints return responses with the following common structure:

| Field | Type | Description |
|-------|------|-------------|
| `accountUid` | string | The unique identifier of the account |
| `elements` | array | Array of event objects |
| `len` | integer | Number of elements returned |
| `continuationToken` | string | Token to use for requesting the next page of results |
| `serverTime` | string (date-time) | Server time in UTC |

## Related Endpoints

- [Market History](market-history.md) - Public market history endpoints (no authentication required)
