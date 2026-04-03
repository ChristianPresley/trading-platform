# Retrieve a Single Open RFQ

## Endpoint

```
GET /rfqs/:rfqUid
```

## Description

Retrieves a specific open RFQ by its unique identifier. Returns detailed information about a single Request for Quote.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Location | Description |
|-----------|------|----------|----------|-------------|
| `rfqUid` | string | Yes | Path | Unique identifier of the RFQ to retrieve |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `rfq` | object | The RFQ object |
| `rfq.rfqUid` | string | Unique identifier for the RFQ |
| `rfq.symbol` | string | The futures contract symbol |
| `rfq.size` | number | The requested trade size |
| `rfq.side` | string | The side of the trade (`buy` or `sell`) |
| `rfq.createdTime` | string | ISO 8601 timestamp when the RFQ was created |
| `rfq.expiryTime` | string | ISO 8601 timestamp when the RFQ expires |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/rfqs/rfq-uuid-here" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "rfq": {
    "rfqUid": "rfq-uuid-here",
    "symbol": "pi_xbtusd",
    "size": 50000,
    "side": "buy",
    "createdTime": "2024-01-15T10:00:00.000Z",
    "expiryTime": "2024-01-15T10:05:00.000Z"
  }
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 401 | Unauthorized - invalid or missing API credentials |
| 404 | RFQ feature is not enabled, or the specified RFQ was not found |
| 500 | Internal server error |

## Notes

- **DEMO ONLY**: This feature is currently available exclusively in the Kraken Futures DEMO environment.
- The `rfqUid` must correspond to a currently open RFQ. Expired or canceled RFQs will not be returned.
- Related endpoints: List All Open RFQs (`GET /rfqs`), Get Open RFQ Offers (`GET /rfqs/open-offers`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-open-rfq)
