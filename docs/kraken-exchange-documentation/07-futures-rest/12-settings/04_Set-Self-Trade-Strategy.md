# Update Self Trade Strategy

## Endpoint

```
PUT /self-trade-strategy
```

## Description

Updates the account-wide self-trade matching strategy. The self-trade strategy determines how the matching engine handles orders from the same account that would trade against each other.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `strategy` | string | Yes | The self-trade strategy to set. Possible values: `cancelNewest`, `cancelOldest`, `cancelBoth` |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

```bash
curl -X PUT "https://futures.kraken.com/derivatives/api/v3/self-trade-strategy" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/json" \
  -d '{"strategy": "cancelNewest"}'
```

## Example Response

```json
{
  "result": "success"
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 400 | Bad request - invalid strategy value |
| 401 | Unauthorized - invalid or missing API credentials |
| 500 | Internal server error |

## Notes

- Self-trade prevention (STP) prevents an account's orders from matching against each other.
- A successful 200 response indicates "Self trade strategy was successfully updated."
- Strategy options:
  - `cancelNewest` - the incoming (aggressing) order is canceled
  - `cancelOldest` - the resting order is canceled
  - `cancelBoth` - both orders are canceled
- Related endpoint: Get Self Trade Strategy (`GET /self-trade-strategy`) to retrieve the current strategy.
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/set-self-trade-strategy)
