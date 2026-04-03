# Get Server Time

> Source: https://docs.kraken.com/api/docs/rest-api/get-server-time

## Endpoint

`GET https://api.kraken.com/0/public/Time`

## Description

Get the server's time.

## Authentication

None required. This is a public endpoint.

## Request Parameters

None.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | string[] | Array of error messages. Empty on success. |
| `result` | object | Result object containing server time data |
| `result.unixtime` | integer | Unix timestamp |
| `result.rfc1123` | string | RFC 1123 time format |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/public/Time' \
  -H 'Accept: application/json'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "unixtime": 1688669448,
    "rfc1123": "Thu, 06 Jul 23 18:50:48 +0000"
  }
}
```

## Notes

- This endpoint can be used to approximate the skew time between the server and client.
- This is a public endpoint and does not require authentication.
- No rate limit information is specified for this endpoint.
