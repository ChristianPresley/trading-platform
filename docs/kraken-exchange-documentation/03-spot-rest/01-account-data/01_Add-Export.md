# Request Export Report

> Source: https://docs.kraken.com/api/docs/rest-api/add-export

## Endpoint

`POST /private/AddExport`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/AddExport`

## Description

Request export of trades or ledgers.

## Authentication

This is a private endpoint and requires authentication.

- **API Key Permissions Required:** Data - Export data
- **Headers Required:**
  - `API-Key`: Your API key
  - `API-Sign`: Message signature using HMAC-SHA512
  - `Content-Type`: `application/x-www-form-urlencoded`

## Request Parameters

**Content-Type:** `application/x-www-form-urlencoded`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer (int64) | Yes | Nonce used in construction of `API-Sign` header |
| `report` | string | Yes | Type of data to export Enum: `['trades', 'ledgers']` |
| `format` | string | No | File format to export Enum: `['CSV', 'TSV']` Default: `CSV` |
| `description` | string | Yes | Description for the export |
| `fields` | string | No | Comma-delimited list of fields to include  * `trades`: `ordertxid`, `time`, `ordertype`, `price`, `cost`, `fee`, `vol`, `margin`, `misc`, `ledgers` * `ledgers`: `refid`, `time`, `type`, `subtype`, `aclass`, `asset`, `amount`, `fee`, `balance`, `wallet`  Default: `all` |
| `starttm` | integer | No | UNIX timestamp for report start time (default 1st of the current month) |
| `endtm` | integer | No | UNIX timestamp for report end time (default now) |

## Response Fields

**HTTP 200:** Export request made

| Field | Type | Description |
|-------|------|-------------|
| `result` | object |  |
| `result.id` | string | Report ID |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "id": "TCJA"
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/AddExport" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
