# Get Websockets Token

> Source: https://docs.kraken.com/api/docs/rest-api/get-websockets-token

## Endpoint
`POST /0/private/GetWebSocketsToken`

## Description
An authentication token must be requested via this REST API endpoint in order to connect to and authenticate with the Kraken WebSockets API. The token should be used within 15 minutes of creation, but once a successful WebSocket connection is established and maintained, the token persists for the lifetime of that connection.

## Authentication
Requires a valid API key with the following permission:
- `WebSocket interface - On`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object (present on success). |
| `result.token` | string | WebSocket authentication token. |
| `result.expires` | integer | Time (in seconds) after which the token expires if unused. Typically 900 seconds (15 minutes). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/GetWebSocketsToken" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "token": "1Dwc4lzSwNWOAwkMdqhssNNFhs1ed606d1WcF3XfEMw",
    "expires": 900
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Permission denied` | API key does not have the `WebSocket interface - On` permission. |
| `EAPI:Invalid nonce` | Nonce is not valid. |
| `EAPI:Invalid key` | API key is invalid. |

## Notes

- The token must be used within 15 minutes (900 seconds) of creation.
- Once a WebSocket connection is successfully authenticated with the token, the connection remains authenticated for its lifetime regardless of token expiry.
- A new token should be requested each time a new WebSocket connection is established.
- This token is used with both the WebSocket v1 and v2 APIs.
- The token is a string that should be passed as the `token` field in the WebSocket subscription/authentication message.
