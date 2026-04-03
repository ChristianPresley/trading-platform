# Get Embed Asset

## Endpoint

```
GET /b2b/assets/:asset
```

## Description

Get information about a specific asset.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `asset` | string | Yes | The unique identifier of the asset to retrieve. |

## Response

### Success

- **200 OK** -- Returns detailed information about the specified asset.

### Error Responses

| Status Code | Description | Error Code | Retryable |
|-------------|-------------|------------|-----------|
| 400 | Bad Request -- the request was malformed or contained invalid parameters. | `ENexus:Unknown quote asset` | No |
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
GET /b2b/assets/BTC HTTP/1.1
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

- The `ENexus:Unknown quote asset` error indicates the specified asset identifier is not recognized.
- For a list of all available assets, see [List Embed Assets](list-embed-assets.md).

---

*Source: [Kraken API Documentation -- Get Embed Asset](https://docs.kraken.com/api/docs/embed-api/get-embed-asset)*
