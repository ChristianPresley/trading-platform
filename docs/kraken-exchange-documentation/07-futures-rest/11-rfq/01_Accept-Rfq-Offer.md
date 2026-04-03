# Accept an Offer on an Open RFQ

## Endpoint

```
POST /rfqs/open-rfqs/accept-offer/:rfqUid
```

## Description

Accepts an offer on an open RFQ created by the authenticated account. Exactly one of `bidAccepted` or `askAccepted` must be provided to indicate which side of the offer is being accepted.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature). The authenticated account must be the creator of the RFQ.

## Request Parameters

| Parameter | Type | Required | Location | Description |
|-----------|------|----------|----------|-------------|
| `rfqUid` | string | Yes | Path | Unique identifier of the RFQ containing the offer to accept |
| `bidAccepted` | boolean | Conditional | Body | Set to `true` to accept the bid offer. Exactly one of `bidAccepted` or `askAccepted` must be provided |
| `askAccepted` | boolean | Conditional | Body | Set to `true` to accept the ask offer. Exactly one of `bidAccepted` or `askAccepted` must be provided |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

### Accept Bid

```bash
curl -X POST "https://futures.kraken.com/derivatives/api/v3/rfqs/open-rfqs/accept-offer/rfq-uuid-here" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/json" \
  -d '{"bidAccepted": true}'
```

### Accept Ask

```bash
curl -X POST "https://futures.kraken.com/derivatives/api/v3/rfqs/open-rfqs/accept-offer/rfq-uuid-here" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/json" \
  -d '{"askAccepted": true}'
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
| 400 | Bad request - both or neither of bidAccepted/askAccepted provided, or no offer exists to accept |
| 401 | Unauthorized - invalid or missing API credentials |
| 404 | RFQ feature is not enabled, or the specified RFQ was not found |
| 500 | Internal server error |

## Notes

- **DEMO ONLY**: This feature is currently available exclusively in the Kraken Futures DEMO environment.
- Exactly one of `bidAccepted` or `askAccepted` must be provided. Providing both or neither will result in a 400 error.
- Only the account that created the RFQ can accept offers on it.
- Accepting an offer executes the block trade at the offered price and closes the RFQ.
- Related endpoints: Create User RFQ (`POST /rfqs/open-rfqs`), Place RFQ Offer (`POST /rfqs/place-offer/:rfqUid`), List Open RFQs for Account (`GET /rfqs/open-rfqs`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/accept-rfq-offer)
