# List Assignment Programs

## Endpoint

```
GET /assignmentprogram/current
```

## Description

Returns information on currently active assignment programs. Assignment programs define preferences for how futures contract assignments are handled for the account.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `programs` | array | List of currently active assignment program objects |
| `programs[].symbol` | string | The futures contract symbol |
| `programs[].preference` | string | The assignment preference for the contract |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/assignmentprogram/current" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "programs": [
    {
      "symbol": "fi_xbtusd",
      "preference": "maker"
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
- Related endpoints: Add Assignment Preference (`POST /assignmentprogram/add`), Delete Assignment Preference (`POST /assignmentprogram/delete`), List Assignment Preferences History (`GET /assignmentprogram/history`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-assignment-program-current)
