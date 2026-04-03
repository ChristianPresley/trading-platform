# Request Embed Quote

## Endpoint

```
POST /b2b/quotes
```

## Description

Request a price quote for an asset, that may be used to execute a trade later on.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

The request body should contain the asset pair, amount, and direction for the quote. Specific parameter details are defined by the Embed API schema.

## Response

### Success

- **200 OK** -- Returns the requested price quote, which can later be executed via the [Execute Embed Quote](execute-embed-quote.md) endpoint.

### Error Responses

| Status Code | Description | Error Code | Retryable |
|-------------|-------------|------------|-----------|
| 400 | Bad Request | `EAPI:Quantity is too small for asset` | No |
| 400 | Bad Request | `EAPI:Quantity is too large for asset` | No |
| 400 | Bad Request | `ENexus:Unknown quote asset` | No |
| 400 | Bad Request | `ENexus:Asset disabled` | No |
| 400 | Bad Request | `ENexus:Unknown amount asset` | No |
| 400 | Bad Request | `EAPI:InvalidParameter` | No |
| 401 | Unauthorized -- authentication failed or credentials are missing/invalid. | -- | No |
| 403 | Forbidden | `EAPI:User Locked` | No (terminal) |
| 403 | Forbidden | `EPTL:UserKycDenyTrading` | No (terminal) |
| 404 | Not Found -- the requested resource does not exist. | -- | No |
| 408 | Request Timeout -- the request took too long to process. | -- | Yes |
| 409 | Conflict | `EPTL:Not enough depth on book` | Yes (market conditions) |
| 409 | Conflict | `EAPI:Potential wash trade` | No (terminal) |
| 429 | Too Many Requests -- rate limit exceeded. | -- | Yes (with backoff) |
| 500 | Internal Server Error -- an unexpected error occurred. | -- | Yes (generally) |
| 503 | Service Unavailable -- the service is temporarily unavailable. | -- | Yes |

## Example Request

```http
POST /b2b/quotes HTTP/1.1
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

- The quote must be executed before it expires. Use [Get Embed Quote](get-embed-quote.md) to check quote status and [Execute Embed Quote](execute-embed-quote.md) to execute.
- `EAPI:Quantity is too small for asset` / `EAPI:Quantity is too large for asset` -- the requested quantity is outside the allowed range for the asset.
- `ENexus:Asset disabled` -- the asset is currently disabled for trading.
- `EAPI:User Locked` -- the user account is locked (terminal, contact support).
- `EPTL:UserKycDenyTrading` -- the user has been denied trading due to KYC status (terminal).
- `EPTL:Not enough depth on book` -- insufficient liquidity; may succeed if retried when market conditions change.
- `EAPI:Potential wash trade` -- the trade was rejected as a potential wash trade (terminal).

---

*Source: [Kraken API Documentation -- Request Embed Quote](https://docs.kraken.com/api/docs/embed-api/request-embed-quote)*
