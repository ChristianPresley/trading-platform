# Request Embed Prospective Quote

## Endpoint

```
POST /b2b/quotes/prospective
```

## Description

Request a prospective quote for an asset pair, to receive an indicative price and fee. This provides pricing information without reserving liquidity or committing to a trade.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

The request body should contain the asset pair and amount for the prospective quote. Specific parameter details are defined by the Embed API schema.

## Response

### Success

- **200 OK** -- Returns an indicative price and fee for the specified asset pair and amount.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 400 | Bad Request -- the request was malformed or contained invalid parameters. | No |
| 401 | Unauthorized -- authentication failed or credentials are missing/invalid. | No |
| 403 | Forbidden -- the authenticated user does not have permission to perform this action. | No |
| 408 | Request Timeout -- the request took too long to process. | Yes |
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |
| 503 | Service Unavailable -- the service is temporarily unavailable. | Yes |

## Example Request

```http
POST /b2b/quotes/prospective HTTP/1.1
Host: nexus.kraken.com
Content-Type: application/json
API-Key: <your-api-key>
API-Sign: <your-api-signature>
```

## Example Response

```
HTTP/1.1 200 OK
Content-Type: application/json
```

## Notes

- This endpoint provides indicative pricing without executing a trade or reserving liquidity.
- Use this for preview/estimation purposes before committing to a real quote via [Request Embed Quote](request-embed-quote.md).
- The indicative price and fee may differ from the actual quote price due to market movements.

---

*Source: [Kraken API Documentation -- Request Embed Prospective Quote](https://docs.kraken.com/api/docs/embed-api/request-embed-prospective-quote)*
