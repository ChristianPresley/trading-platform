# List Embed Assets

## Endpoint

```
GET /b2b/assets
```

## Description

List all assets available on the platform. The response includes the asset identifier, the type of the asset, and the status of the asset on the platform.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

No request parameters are required for this endpoint.

## Response

### Success

- **200 OK** -- Returns a list of all available assets with their identifiers, types, and platform statuses.

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
GET /b2b/assets HTTP/1.1
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

- Returns all assets available on the platform regardless of trading status.
- Each asset includes its identifier, type, and current platform status.
- For details on a specific asset, see [Get Embed Asset](get-embed-asset.md).

---

*Source: [Kraken API Documentation -- List Embed Assets](https://docs.kraken.com/api/docs/embed-api/list-embed-assets)*
