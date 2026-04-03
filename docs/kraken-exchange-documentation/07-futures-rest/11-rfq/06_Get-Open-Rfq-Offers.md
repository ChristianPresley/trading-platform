# List Open Offers on Open RFQs

## Endpoint

```
GET /rfqs/open-offers
```

## Description

Returns all open offers for the authenticated account on currently open RFQs. This allows market makers and participants to view their outstanding price quotes on active Requests for Quote.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `offers` | array | List of open offer objects |
| `offers[].rfqUid` | string | Unique identifier of the RFQ this offer is on |
| `offers[].bid` | number | The bid price offered (if provided) |
| `offers[].ask` | number | The ask price offered (if provided) |
| `offers[].createdTime` | string | ISO 8601 timestamp when the offer was placed |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/rfqs/open-offers" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "offers": [
    {
      "rfqUid": "rfq-uuid-here",
      "bid": 42000.0,
      "ask": 42100.0,
      "createdTime": "2024-01-15T10:01:00.000Z"
    }
  ]
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 401 | Unauthorized - invalid or missing API credentials |
| 404 | RFQ feature is not enabled |
| 500 | Internal server error |

## Notes

- **DEMO ONLY**: This feature is currently available exclusively in the Kraken Futures DEMO environment.
- Only returns offers placed by the authenticated account.
- Related endpoints: Place RFQ Offer (`POST /rfqs/place-offer/:rfqUid`), Cancel RFQ Offer (`DELETE /rfqs/cancel-offer/:rfqUid`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-open-rfq-offers)
