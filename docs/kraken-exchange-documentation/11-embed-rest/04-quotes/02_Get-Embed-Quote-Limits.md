# Get Embed Quote Limits

## Endpoint

```
GET /b2b/quotes/limits
```

## Description

Request minimum, maximum and precision for trade using a given asset pair.

## Authentication

Required. Requests must be authenticated with valid API credentials.

## Request Parameters

Query parameters should specify the asset pair for which to retrieve limits. Specific parameter details are defined by the Embed API schema.

## Response

### Success

- **200 OK** -- Returns the minimum, maximum, and precision limits for the specified asset pair.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |

## Example Request

```http
GET /b2b/quotes/limits HTTP/1.1
Host: nexus.kraken.com
API-Key: <your-api-key>
API-Sign: <your-api-signature>
```

## Example Response

```
HTTP/1.1 200 OK
Content-Type: application/json
```

## Notes

- Use this endpoint to determine valid quantity ranges and decimal precision before requesting a quote.
- The response includes minimum trade size, maximum trade size, and decimal precision for the asset pair.
- Related endpoints: [Request Embed Quote](request-embed-quote.md), [List Embed Tradable Assets](list-embed-tradable-assets.md).

---

*Source: [Kraken API Documentation -- Get Embed Quote Limits](https://docs.kraken.com/api/docs/embed-api/get-embed-quote-limits)*
