# Market History

Source: [https://docs.kraken.com/api/docs/futures-api/history/market-history](https://docs.kraken.com/api/docs/futures-api/history/market-history)

## Overview

The Market History section provides access to public market data through several endpoints under the Futures REST API. These endpoints return paginated JSON responses with access to public market history for a specific tradeable contract. No authentication is required.

## Available Endpoints

| Endpoint | Method | Path | Description |
|----------|--------|------|-------------|
| [Get Public Execution Events](get-public-execution-events.md) | GET | `/api/history/v2/market/{tradeable}/executions` | Lists trades for a market |
| [Get Public Order Events](get-public-order-events.md) | GET | `/api/history/v2/market/{tradeable}/orders` | Lists order events for a market |
| [Get Public Mark Price Events](get-public-price-events.md) | GET | `/api/history/v2/market/{tradeable}/price` | Lists price events for a market |

## Base URL

```
https://futures.kraken.com
```

## Authentication

Market History endpoints are **public** and do not require authentication.

## Common Query Parameters

All Market History endpoints share the following pagination and filtering parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `before` | integer | No | Filter to only return results before a specific timestamp (epoch milliseconds) |
| `since` | integer | No | Filter by specifying a start point (epoch milliseconds) |
| `continuation_token` | string | No | Token returned from a previous request, used to continue requesting historical events |
| `sort` | string | No | Sort the results. Values: `asc`, `desc` |

## Common Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tradeable` | string | Yes | The contract symbol to query (e.g., `PI_XBTUSD`, `PF_SOLUSD`) |

## Common Response Structure

All Market History endpoints return responses with the following common structure:

| Field | Type | Description |
|-------|------|-------------|
| `elements` | array | Array of event objects |
| `len` | integer | Number of elements returned |
| `continuationToken` | string | Token to use for requesting the next page of results |

## Related Endpoints

- [Account History](account-history.md) - Private account history endpoints (authentication required)
