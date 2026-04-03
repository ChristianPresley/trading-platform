# Cancel Open Offer on Open RFQ

## Endpoint

```
DELETE /rfqs/cancel-offer/:rfqUid
```

## Description

Cancels the current open offer on the specified open RFQ. This removes the authenticated account's bid/ask offer from the RFQ.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Location | Description |
|-----------|------|----------|----------|-------------|
| `rfqUid` | string | Yes | Path | Unique identifier of the RFQ whose offer should be canceled |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

```bash
curl -X DELETE "https://futures.kraken.com/derivatives/api/v3/rfqs/cancel-offer/rfq-uuid-here" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
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
| 400 | Bad request - no active offer exists on this RFQ for the account |
| 401 | Unauthorized - invalid or missing API credentials |
| 404 | RFQ feature is not enabled, or the specified RFQ was not found |
| 500 | Internal server error |

## Notes

- **DEMO ONLY**: This feature is currently available exclusively in the Kraken Futures DEMO environment.
- Only cancels the offer belonging to the authenticated account. Cannot cancel other participants' offers.
- Related endpoints: Place RFQ Offer (`POST /rfqs/place-offer/:rfqUid`), Get Open RFQ Offers (`GET /rfqs/open-offers`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/cancel-rfq-offer)
