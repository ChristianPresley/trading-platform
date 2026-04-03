# Create Embed User

## Endpoint

```
POST /b2b/users
```

## Description

Create a new user in the Payward system.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

The request body should contain the user profile data required for creating a new user account. Specific parameter details are defined by the Embed API schema.

## Response

### Success

- **201 Created** -- The user was successfully created.

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
POST /b2b/users HTTP/1.1
Host: nexus.kraken.com
Content-Type: application/json
API-Key: <your-api-key>
API-Sign: <your-api-signature>
```

## Example Response

```
HTTP/1.1 201 Created
Content-Type: application/json
```

## Notes

- The `ENexus:Invalid user ID` error on a 400 response indicates the provided user ID does not conform to the expected format.
- This endpoint creates a full user with profile data (email, name, phone, etc.). For lightweight accounts without user profile data, see [Create Headless Subaccount](create-headless-subaccount.md).

---

*Source: [Kraken API Documentation -- Create Embed User](https://docs.kraken.com/api/docs/embed-api/create-embed-user)*
