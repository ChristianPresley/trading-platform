# Cancel an Open RFQ

## Endpoint

```
DELETE /rfqs/open-rfqs/:rfqUid
```

## Description

Cancels a specific open RFQ created by the authenticated account. This removes the RFQ from the platform and prevents any further offers from being placed on it.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Location | Description |
|-----------|------|----------|----------|-------------|
| `rfqUid` | string | Yes | Path | Unique identifier of the RFQ to cancel |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

```bash
curl -X DELETE "https://futures.kraken.com/derivatives/api/v3/rfqs/open-rfqs/rfq-uuid-here" \
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
| 400 | Bad request - RFQ is not in a cancelable state |
| 401 | Unauthorized - invalid or missing API credentials |
| 404 | RFQ feature is not enabled, or the specified RFQ was not found |
| 500 | Internal server error |

## Notes

- **DEMO ONLY**: This feature is currently available exclusively in the Kraken Futures DEMO environment.
- Only the account that created the RFQ can cancel it.
- Canceling an RFQ also invalidates any outstanding offers placed on it by other participants.
- Related endpoints: Create User RFQ (`POST /rfqs/open-rfqs`), List Open RFQs for Account (`GET /rfqs/open-rfqs`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/cancel-user-rfq)
