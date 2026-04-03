# Get Embed User

## Endpoint

```
GET /b2b/users/:user
```

## Description

Get a previously created user.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `user` | string | Yes | The unique identifier of the user to retrieve. |

## Response

### Success

- **200 OK** -- Returns the user profile data for the specified user.

### Error Responses

| Status Code | Description | Error Code | Retryable |
|-------------|-------------|------------|-----------|
| 400 | Bad Request -- the request was malformed or contained invalid parameters. | `ENexus:Invalid user ID` | No |
| 401 | Unauthorized -- authentication failed or credentials are missing/invalid. | -- | No |
| 403 | Forbidden -- the authenticated user does not have permission to perform this action. | -- | No |
| 404 | Not Found -- the requested resource does not exist. | -- | No |
| 408 | Request Timeout -- the request took too long to process. | -- | Yes |
| 409 | Conflict -- the request conflicts with the current state of the resource. | -- | Sometimes |
| 429 | Too Many Requests -- rate limit exceeded. | -- | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | -- | Yes (generally) |
| 503 | Service Unavailable -- the service is temporarily unavailable. | -- | Yes |

## Example Request

```http
GET /b2b/users/user-123 HTTP/1.1
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

- The `:user` path parameter must match a previously created user ID.
- The `ENexus:Invalid user ID` error on a 400 response indicates the provided user ID does not conform to the expected format.

---

*Source: [Kraken API Documentation -- Get Embed User](https://docs.kraken.com/api/docs/embed-api/get-embed-user)*
