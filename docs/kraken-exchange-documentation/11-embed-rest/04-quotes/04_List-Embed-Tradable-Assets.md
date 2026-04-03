# List Embed Tradable Assets

## Endpoint

```
GET /b2b/quotes/assets
```

## Description

Retrieve the list of tradable assets available for a specific user. The endpoint provides asset information including trading status, decimal precision, and trading pair restrictions to help determine which assets users can trade or include in quote requests.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `tradable` | boolean | No | Filters assets by trading status. `true` returns only tradable assets, `false` returns disabled/soon assets, omitted returns all assets. |

## Response

### Success

- **200 OK** -- Returns the list of tradable assets.

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `tradable` | string | Asset trading status. One of: `"tradable"`, `"disabled"`, or `"soon"`. |
| `disabled_against` | array | Lists assets that cannot be traded against this asset. |

### Asset Status Values

| Status | Description |
|--------|-------------|
| `tradable` | Asset is available for trading. |
| `disabled` | Asset is currently disabled and cannot be traded. |
| `soon` | Asset will be available for trading soon. |

### Error Responses

| Status Code | Description | Retryable |
|-------------|-------------|-----------|
| 400 | Bad Request -- the request was malformed or contained invalid parameters. | No |
| 401 | Unauthorized -- authentication failed or credentials are missing/invalid. | No |
| 403 | Forbidden -- the authenticated user does not have permission to perform this action. | No |
| 404 | Not Found -- the requested resource does not exist. | No |
| 408 | Request Timeout -- the request took too long to process. | Yes |
| 429 | Too Many Requests -- rate limit exceeded. | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | Yes (generally) |
| 503 | Service Unavailable -- the service is temporarily unavailable. | Yes |

## Example Request

```http
GET /b2b/quotes/assets?tradable=true HTTP/1.1
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

- Use the `tradable` query parameter to filter results by trading status.
- The `disabled_against` array indicates specific trading pair restrictions for each asset.
- Check the `tradable` status before including an asset in a quote request.

---

*Source: [Kraken API Documentation -- List Embed Tradable Assets](https://docs.kraken.com/api/docs/embed-api/list-embed-tradable-assets)*
