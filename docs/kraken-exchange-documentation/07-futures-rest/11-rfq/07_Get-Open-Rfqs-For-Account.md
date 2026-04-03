# List Open RFQs for Account

## Endpoint

```
GET /rfqs/open-rfqs
```

## Description

Returns all open RFQs created by the authenticated account. Unlike `GET /rfqs` which returns all platform RFQs, this endpoint filters to only show RFQs created by the calling account.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `rfqs` | array | List of open RFQ objects created by the authenticated account |
| `rfqs[].rfqUid` | string | Unique identifier for the RFQ |
| `rfqs[].symbol` | string | The futures contract symbol |
| `rfqs[].size` | number | The requested trade size |
| `rfqs[].side` | string | The side of the trade (`buy` or `sell`) |
| `rfqs[].createdTime` | string | ISO 8601 timestamp when the RFQ was created |
| `rfqs[].expiryTime` | string | ISO 8601 timestamp when the RFQ expires |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/rfqs/open-rfqs" \
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
- Only returns RFQs created by the authenticated account. Use `GET /rfqs` to view all platform RFQs.
- Related endpoints: Create User RFQ (`POST /rfqs/open-rfqs`), Cancel User RFQ (`DELETE /rfqs/open-rfqs/:rfqUid`), Accept RFQ Offer (`POST /rfqs/open-rfqs/accept-offer/:rfqUid`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-open-rfqs-for-account)
