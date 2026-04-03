# Retrieve Data Export

> Source: https://docs.kraken.com/api/docs/rest-api/retrieve-export

## Endpoint

`POST /private/RetrieveExport`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/RetrieveExport`

## Description

Retrieve a processed data export

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
| `id` | string | Yes | Report ID to retrieve |

## Response Fields

**HTTP 200:** Data export report retrieved

**Content-Type:** `application/octet-stream`

The response is a binary ZIP archive containing the requested export report.

| Field | Type | Description |
|-------|------|-------------|
| `report` | string (binary) | Binary zip archive containing the report |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/RetrieveExport" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
