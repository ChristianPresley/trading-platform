# List All Open RFQs

## Endpoint

```
GET /rfqs
```

## Description

Returns all currently open RFQs (Requests for Quote) on the platform. An RFQ is a mechanism for requesting price quotes for large block trades.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `rfqs` | array | List of open RFQ objects |
| `rfqs[].rfqUid` | string | Unique identifier for the RFQ |
| `rfqs[].symbol` | string | The futures contract symbol |
| `rfqs[].size` | number | The requested trade size |
| `rfqs[].side` | string | The side of the trade (`buy` or `sell`) |
| `rfqs[].createdTime` | string | ISO 8601 timestamp when the RFQ was created |
| `rfqs[].expiryTime` | string | ISO 8601 timestamp when the RFQ expires |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/rfqs" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "rfqs": [
    {
      "rfqUid": "rfq-uuid-here",
      "symbol": "pi_xbtusd",
      "size": 50000,
      "side": "buy",
      "createdTime": "2024-01-15T10:00:00.000Z",
      "expiryTime": "2024-01-15T10:05:00.000Z"
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
- RFQs are used for negotiating large block trades outside the regular order book.
- A 404 response indicates the RFQ feature is not enabled for the account or environment.
- Related endpoints: Get Open RFQ (`GET /rfqs/:rfqUid`), Get Open RFQ Offers (`GET /rfqs/open-offers`), Create User RFQ (`POST /rfqs/open-rfqs`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-open-rfqs)
