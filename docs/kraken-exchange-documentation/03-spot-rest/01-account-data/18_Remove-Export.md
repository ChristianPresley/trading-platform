# Delete Export Report

> Source: https://docs.kraken.com/api/docs/rest-api/remove-export

## Endpoint

`POST /private/RemoveExport`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/RemoveExport`

## Description

Delete exported trades/ledgers report

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
| `id` | string | Yes | ID of report to delete or cancel |
| `type` | string | Yes | `delete` can only be used for reports that have already been processed. Use `cancel` for queued or processing reports.  Enum: `['cancel', 'delete']` |

## Response Fields

**HTTP 200:** Export report deleted or cancelled

| Field | Type | Description |
|-------|------|-------------|
| `result` | object |  |
| `result.delete` | boolean | Whether deletion was successful |
| `result.cancel` | boolean | Whether cancellation was successful |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "delete": true
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/RemoveExport" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
