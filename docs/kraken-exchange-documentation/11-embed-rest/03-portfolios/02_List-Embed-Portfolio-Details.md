# List Embed Portfolio Details

## Endpoint

```
GET /b2b/portfolio/:user/details
```

## Description

Lists owned assets in a user's portfolio.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user` | string | Yes | The unique identifier of the user whose portfolio details to retrieve. |

## Response

### Success

- **200 OK** -- Returns a list of owned assets in the user's portfolio.

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
GET /b2b/portfolio/user-123/details HTTP/1.1
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

- Returns detailed information about each asset the user currently holds.
- For historical portfolio data, see [Get Embed Portfolio History](get-embed-portfolio-history.md).

---

*Source: [Kraken API Documentation -- List Embed Portfolio Details](https://docs.kraken.com/api/docs/embed-api/list-embed-portfolio-details)*
