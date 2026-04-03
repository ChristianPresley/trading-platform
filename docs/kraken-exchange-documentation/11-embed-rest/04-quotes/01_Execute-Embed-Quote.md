# Execute Embed Quote

## Endpoint

```
PUT /b2b/quotes/:quote_id
```

## Description

Executes a quote that was previously requested.

## Authentication

Required. Requests must be authenticated with valid API credentials. Missing or invalid credentials will result in a `401 Unauthorized` response.

## Request Parameters

### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `quote_id` | string | Yes | The unique identifier of the quote to execute. |

## Response

### Success

- **200 OK** -- The quote was successfully executed.

### Error Responses

| Status Code | Description | Error Code | Retryable |
|-------------|-------------|------------|-----------|
| 400 | Bad Request -- the request was malformed or contained invalid parameters. | -- | No |
| 401 | Unauthorized -- authentication failed or credentials are missing/invalid. | -- | No |
| 403 | Forbidden -- the authenticated user does not have permission to perform this action. | -- | No |
| 404 | Not Found -- the requested resource does not exist. | -- | No |
| 408 | Request Timeout -- the request took too long to process. | -- | Yes |
| 409 | Conflict -- quote already accepted. | `EPTL:Quote already accepted` | No (terminal) |
| 409 | Conflict -- quote was cancelled. | `EPTL:Quote cancelled` | No (terminal) |
| 409 | Conflict -- price quote has expired. | `EPTL:Price quote expired` | No (terminal) |
| 409 | Conflict -- quote execution failed. | `EPTL:Quote execution failed` | No (terminal) |
| 409 | Conflict -- insufficient funds for transfer. | `EPTL:Insufficient funds for transfer` | No (terminal) |
| 422 | Unprocessable Entity -- unable to fund transfer for quote. | `EPTL:PTL unable to fund transfer for quote` | No |
| 422 | Unprocessable Entity -- unable to fund order for quote. | `EPTL:PTL unable to fund order for quote` | No |
| 429 | Too Many Requests -- user has too many quote executions in progress. | `EPTL:User has too many quote executions in progress` | Yes |
| 429 | Too Many Requests -- user has reached volume threshold. | `EPTL:User has reached volume threshold` | No (terminal) |
| 500 | Internal Server Error -- an unexpected error occurred. | -- | Yes (generally) |
| 503 | Service Unavailable -- order cancelled, try again. | `EPTL:Order cancelled. Try again.` | Yes |

## Example Request

```http
PUT /b2b/quotes/quote-abc-123 HTTP/1.1
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

- The quote must be in a valid, non-expired state to be executed.
- `EPTL:Quote already accepted` -- the quote has already been executed; cannot execute again.
- `EPTL:Quote cancelled` -- the quote was cancelled and can no longer be executed.
- `EPTL:Price quote expired` -- the quote has expired; request a new quote.
- `EPTL:Quote execution failed` -- execution failed; this is a terminal error.
- `EPTL:Insufficient funds for transfer` -- the user does not have sufficient funds.
- `EPTL:PTL unable to fund transfer for quote` / `EPTL:PTL unable to fund order for quote` -- system unable to fund the operation (422).
- `EPTL:User has too many quote executions in progress` -- rate limit on concurrent executions; retry after a delay.
- `EPTL:User has reached volume threshold` -- volume limit reached; terminal error, cannot retry.
- `EPTL:Order cancelled. Try again.` -- transient failure on 503; safe to retry.

---

*Source: [Kraken API Documentation -- Execute Embed Quote](https://docs.kraken.com/api/docs/embed-api/execute-embed-quote)*
