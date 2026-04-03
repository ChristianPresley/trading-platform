# Delete Assignment Preference

## Endpoint

```
POST /assignmentprogram/delete
```

## Description

Deletes an existing assignment program preference for a futures contract. Removes the previously configured assignment handling preference.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `symbol` | string | Yes | The futures contract symbol to remove the preference for (e.g., `fi_xbtusd`) |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

```bash
curl -X POST "https://futures.kraken.com/derivatives/api/v3/assignmentprogram/delete" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "symbol=fi_xbtusd"
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
| 400 | Bad request - invalid parameters or no preference exists for the given symbol |
| 401 | Unauthorized - invalid or missing API credentials |
| 500 | Internal server error |

## Notes

- This endpoint is part of the Assignment Program group within the Futures Trading API.
- Related endpoints: List Assignment Programs (`GET /assignmentprogram/current`), Add Assignment Preference (`POST /assignmentprogram/add`), List Assignment Preferences History (`GET /assignmentprogram/history`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/delete-assignment-program)
