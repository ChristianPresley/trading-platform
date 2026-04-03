# List Embed Asset Rates

## Endpoint

```
GET /b2b/assets/:asset/rates
```

## Description

Returns historical rates for a given asset, including the timestamp for the period the rate is for and the median price of the asset during the period (daily).

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `asset` | string | Yes | The unique identifier of the asset to retrieve rates for. |

### Query Parameters

Query parameters may include time range filters (start time, end time, interval). Specific parameter details are defined by the Embed API schema.

## Response

### Success

- **200 OK** -- Returns historical rate data for the specified asset, including timestamps and median daily prices.

### Error Responses

| Status Code | Description | Error Code | Retryable |
|-------------|-------------|------------|-----------|
| 400 | Bad Request -- the request was malformed or contained invalid parameters. | `ENexus:Unknown base asset` | No |
| 400 | Bad Request | `ENexus:Unknown quote asset` | No |
| 400 | Bad Request | `ENexus:Interval is too large` | No |
| 400 | Bad Request | `ENexus:Invalid start time` | No |
| 400 | Bad Request | `ENexus:Invalid end time` | No |
| 401 | Unauthorized -- authentication failed or credentials are missing/invalid. | -- | No |
| 403 | Forbidden -- the authenticated user does not have permission to perform this action. | -- | No |
| 404 | Not Found -- the requested resource does not exist. | -- | No |
| 408 | Request Timeout -- the request took too long to process. | -- | Yes |
| 429 | Too Many Requests -- rate limit exceeded. | -- | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | -- | Yes (generally) |
| 503 | Service Unavailable -- the service is temporarily unavailable. | -- | Yes |

## Example Request

```http
GET /b2b/assets/BTC/rates HTTP/1.1
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

- Returns daily historical rates with median prices.
- The `ENexus:Unknown base asset` and `ENexus:Unknown quote asset` errors indicate unrecognized asset identifiers.
- The `ENexus:Interval is too large` error indicates the requested time range exceeds the allowed maximum.
- The `ENexus:Invalid start time` and `ENexus:Invalid end time` errors indicate malformed time parameters.

---

*Source: [Kraken API Documentation -- List Embed Asset Rates](https://docs.kraken.com/api/docs/embed-api/list-embed-asset-rates)*
