# Get Fee Schedule Volumes

## Endpoint

```
GET /feeschedules/volumes
```

## Description

Returns your fee schedule volumes for each fee schedule. This provides the trailing trading volume used to determine which fee tier applies to your account.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `volumesByFeeSchedule` | object | Map of fee schedule UIDs to volume information |
| `volumesByFeeSchedule.<uid>.usdVolume` | number | Trailing 30-day USD trading volume for this fee schedule |
| `volumesByFeeSchedule.<uid>.feeScheduleUid` | string | The fee schedule unique identifier |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/feeschedules/volumes" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "volumesByFeeSchedule": {
    "eef90775-995b-4596-9257-5e23a3f1b???": {
      "usdVolume": 250000.00,
      "feeScheduleUid": "eef90775-995b-4596-9257-5e23a3f1b???"
    }
  }
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 401 | Unauthorized - invalid or missing API credentials |
| 500 | Internal server error |

## Notes

- This is version 3 of the fee schedule volumes endpoint.
- Volume is typically calculated as a trailing 30-day rolling window.
- Use this in conjunction with `GET /feeschedules` to determine which fee tier currently applies to your account.
- Related endpoint: Get Fee Schedules (`GET /feeschedules`) to list all available fee schedules and their tier structures.
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-user-fee-schedule-volumes-v-3)
