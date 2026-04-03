# Get Export Report Status

> Source: https://docs.kraken.com/api/docs/rest-api/export-status

## Endpoint

`POST /private/ExportStatus`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/ExportStatus`

## Description

Get status of requested data exports.

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
| `report` | string | Yes | Type of reports to inquire about Enum: `['trades', 'ledgers']` |

## Response Fields

**HTTP 200:** Export status retrieved

| Field | Type | Description |
|-------|------|-------------|
| `result` | array |  |
| `result[].id` | string | Report ID |
| `result[].descr` | string |  |
| `result[].format` | string |  |
| `result[].report` | string |  |
| `result[].subtype` | string |  |
| `result[].status` | string | Status of the report Enum: `['Queued', 'Processing', 'Processed']` |
| `result[].flags` | string |  |
| `result[].fields` | string |  |
| `result[].createdtm` | string | UNIX timestamp of report request |
| `result[].expiretm` | string |  |
| `result[].starttm` | string | UNIX timestamp report processing began |
| `result[].completedtm` | string | UNIX timestamp report processing finished |
| `result[].datastarttm` | string | UNIX timestamp of the report data start time |
| `result[].dataendtm` | string | UNIX timestamp of the report data end time |
| `result[].aclass` | string |  |
| `result[].asset` | string |  |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": [
    {
      "id": "VSKC",
      "descr": "my_trades_1",
      "format": "CSV",
      "report": "trades",
      "subtype": "all",
      "status": "Processed",
      "flags": "0",
      "fields": "all",
      "createdtm": "1688669085",
      "expiretm": "1688878685",
      "starttm": "1688669093",
      "completedtm": "1688669093",
      "datastarttm": "1683556800",
      "dataendtm": "1688669085",
      "aclass": "forex",
      "asset": "all"
    },
    {
      "id": "TCJA",
      "descr": "my_trades_1",
      "format": "CSV",
      "report": "trades",
      "subtype": "all",
      "status": "Processed",
      "flags": "0",
      "fields": "all",
      "createdtm": "1688363637",
      "expiretm": "1688573237",
      "starttm": "1688363664",
      "completedtm": "1688363664",
      "datastarttm": "1683235200",
      "dataendtm": "1688363637",
      "aclass": "forex",
      "asset": "all"
    }
  ]
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/ExportStatus" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
