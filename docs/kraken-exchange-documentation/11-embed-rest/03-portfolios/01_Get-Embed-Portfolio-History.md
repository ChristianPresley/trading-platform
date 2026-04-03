# Get Embed Portfolio History

## Endpoint

```
GET /b2b/portfolio/:user/history
```

## Description

Gets a portfolio's historical balances and valuations over time.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user` | string | Yes | The unique identifier of the user whose portfolio history to retrieve. |

### Query Parameters

Query parameters may include time range filters and pagination cursors. Specific parameter details are defined by the Embed API schema.

## Response

### Success

- **200 OK** -- Returns historical balance and valuation data for the user's portfolio.

### Pagination

Maximum of 365 data points returned per request. Responses exceeding this limit include a `next_cursor` field for retrieving subsequent pages. Continue paginating until `next_cursor` is absent from the response.

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 400 | Bad Request -- the request was malformed or contained invalid parameters. | No |
| 401 | Unauthorized -- authentication failed or credentials are missing/invalid. | No |
| 403 | Forbidden -- the authenticated user does not have permission to perform this action. | No |
| 404 | Not Found -- the requested resource does not exist. | No |
| 408 | Request Timeout -- the request took too long to process. | Yes |
| 409 | Conflict -- the request conflicts with the current state of the resource. | Sometimes |
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |
| 503 | Service Unavailable -- the service is temporarily unavailable. | Yes |

## Example Request

```http
GET /b2b/portfolio/user-123/history HTTP/1.1
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

- Maximum of 365 data points per request; use `next_cursor` for pagination.
- A null balance at the start of the range indicates no prior asset holding.
- A zero balance suggests past ownership with a current zero balance.
- The final day's balance appears at UTC + 5 hours due to processing delays.
- For current portfolio holdings, see [List Embed Portfolio Details](list-embed-portfolio-details.md).

---

*Source: [Kraken API Documentation -- Get Embed Portfolio History](https://docs.kraken.com/api/docs/embed-api/get-embed-portfolio-history)*
