# Add Assignment Preference

## Endpoint

```
POST /assignmentprogram/add
```

## Description

Adds an assignment program preference for a futures contract. This allows the user to specify how they prefer assignments to be handled for a particular contract.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `symbol` | string | Yes | The futures contract symbol (e.g., `fi_xbtusd`) |
| `preference` | string | Yes | The assignment preference to set for the contract |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

```bash
curl -X POST "https://futures.kraken.com/derivatives/api/v3/assignmentprogram/add" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "symbol=fi_xbtusd&preference=maker"
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
| 400 | Bad request - invalid parameters |
| 401 | Unauthorized - invalid or missing API credentials |
| 500 | Internal server error |

## Notes

- This endpoint is part of the Assignment Program group within the Futures Trading API.
- Use `GET /assignmentprogram/current` to verify the preference was applied.
- Related endpoints: List Assignment Programs (`GET /assignmentprogram/current`), Delete Assignment Preference (`POST /assignmentprogram/delete`), List Assignment Preferences History (`GET /assignmentprogram/history`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/add-assignment-program)
