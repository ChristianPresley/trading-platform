# Get Self Trade Strategy

## Endpoint

```
GET /self-trade-strategy
```

## Description

Retrieves the account-wide self-trade matching strategy configuration. The self-trade strategy determines how the matching engine handles orders from the same account that would trade against each other.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `strategy` | string | The current self-trade strategy. Possible values: `cancelNewest`, `cancelOldest`, `cancelBoth` |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/self-trade-strategy" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "strategy": "cancelNewest"
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 401 | Unauthorized - invalid or missing API credentials |
| 500 | Internal server error |

## Notes

- Self-trade prevention (STP) prevents an account's orders from matching against each other.
- Common strategies:
  - `cancelNewest` - the incoming (aggressing) order is canceled
  - `cancelOldest` - the resting order is canceled
  - `cancelBoth` - both orders are canceled
- Related endpoint: Update Self Trade Strategy (`PUT /self-trade-strategy`) to change the strategy.
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-self-trade-strategy)
