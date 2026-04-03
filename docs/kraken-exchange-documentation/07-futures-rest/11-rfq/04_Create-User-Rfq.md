# Create a New RFQ

## Endpoint

```
POST /rfqs/open-rfqs
```

## Description

Creates a new Request for Quote (RFQ) for the authenticated account. This initiates a block trade negotiation by broadcasting a request to market participants for price quotes.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `symbol` | string | Yes | The futures contract symbol (e.g., `pi_xbtusd`) |
| `size` | number | Yes | The requested trade size in contracts |
| `side` | string | Yes | The side of the trade (`buy` or `sell`) |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `rfqUid` | string | Unique identifier of the newly created RFQ |

## Example Request

```bash
curl -X POST "https://futures.kraken.com/derivatives/api/v3/rfqs/open-rfqs" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/json" \
  -d '{"symbol": "pi_xbtusd", "size": 50000, "side": "buy"}'
```

## Example Response

```json
{
  "result": "success",
  "rfqUid": "rfq-uuid-here"
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 400 | Bad request - invalid parameters or invalid symbol |
| 401 | Unauthorized - invalid or missing API credentials |
| 404 | RFQ feature is not enabled |
| 500 | Internal server error |

## Notes

- **DEMO ONLY**: This feature is currently available exclusively in the Kraken Futures DEMO environment.
- The created RFQ will be visible to other market participants who can then place offers on it.
- RFQs have a limited lifespan and will expire after a set duration.
- Related endpoints: List Open RFQs for Account (`GET /rfqs/open-rfqs`), Cancel User RFQ (`DELETE /rfqs/open-rfqs/:rfqUid`), Accept RFQ Offer (`POST /rfqs/open-rfqs/accept-offer/:rfqUid`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/create-user-rfq)
