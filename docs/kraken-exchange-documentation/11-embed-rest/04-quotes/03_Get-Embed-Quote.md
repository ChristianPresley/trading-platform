# Get Embed Quote

## Endpoint

```
GET /b2b/quotes/:quote_id
```

## Description

Gets the status of a quote that was previously requested.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `quote_id` | string | Yes | The unique identifier of the quote to retrieve. |

## Response

### Success

- **200 OK** -- Returns the current status and details of the specified quote.

### Error Responses

| Status Code | Description | Error Code | Retryable |
|-------------|-------------|------------|-----------|
| 400 | Bad Request -- the request was malformed or contained invalid parameters. | -- | No |
| 401 | Unauthorized -- authentication failed or credentials are missing/invalid. | -- | No |
| 403 | Forbidden -- the authenticated user does not have permission to perform this action. | -- | No |
| 404 | Not Found -- the requested resource does not exist. | `ENexus:Quote not found` | No |
| 408 | Request Timeout -- the request took too long to process. | -- | Yes |
| 409 | Conflict -- the request conflicts with the current state of the resource. | -- | Sometimes |
| 429 | Too Many Requests -- rate limit exceeded. | -- | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | -- | Yes (generally) |
| 503 | Service Unavailable -- the service is temporarily unavailable. | -- | Yes |

## Example Request

```http
GET /b2b/quotes/quote-abc-123 HTTP/1.1
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

- The `ENexus:Quote not found` error on a 404 response indicates the specified quote ID does not match any existing quote.
- Use this endpoint to check quote status before executing via [Execute Embed Quote](execute-embed-quote.md).
- Quotes have an expiration time -- check the status to ensure the quote is still valid before execution.

---

*Source: [Kraken API Documentation -- Get Embed Quote](https://docs.kraken.com/api/docs/embed-api/get-embed-quote)*
