# List Assignment Preferences History

## Endpoint

```
GET /assignmentprogram/history
```

## Description

Returns information on assignment program preferences change history. This provides a record of all changes made to assignment program preferences for the account.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `history` | array | List of historical assignment program preference changes |
| `history[].symbol` | string | The futures contract symbol |
| `history[].preference` | string | The assignment preference that was set |
| `history[].timestamp` | string | ISO 8601 timestamp of when the change was made |
| `history[].action` | string | The action performed (e.g., `add`, `delete`) |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/assignmentprogram/history" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "history": [
    {
      "symbol": "fi_xbtusd",
      "preference": "maker",
      "timestamp": "2024-01-15T10:30:00.000Z",
      "action": "add"
    }
  ]
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 401 | Unauthorized - invalid or missing API credentials |
| 500 | Internal server error |

## Notes

- This endpoint is part of the Assignment Program group within the Futures Trading API.
- Related endpoints: List Assignment Programs (`GET /assignmentprogram/current`), Add Assignment Preference (`POST /assignmentprogram/add`), Delete Assignment Preference (`POST /assignmentprogram/delete`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-assignment-program-history)
