# Get API Key Info

> Source: https://docs.kraken.com/api/docs/rest-api/get-api-key-info

## Endpoint

`POST /private/GetApiKeyInfo`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/GetApiKeyInfo`

## Description

Retrieve information about the API key that is used to make the request, including its name, permissions, restrictions, and usage timestamps.

## Authentication

This is a private endpoint and requires authentication.

- **API Key Permissions Required:** None
- **Headers Required:**
  - `API-Key`: Your API key
  - `API-Sign`: Message signature using HMAC-SHA512
  - `Content-Type`: `application/x-www-form-urlencoded`

## Request Parameters

**Content-Type:** `application/x-www-form-urlencoded`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer (int64) | Yes | Nonce used in construction of `API-Sign` header |
| `otp` | string | No | Two-factor authentication password (required only if 2FA is configured for the API key) |

## Response Fields

**HTTP 200:** API key information retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | API Key Information |
| `result.apiKeyName` | string | Name/label assigned to the API key |
| `result.apiKey` | string | The API key string |
| `result.nonce` | string | Current nonce value for the API key |
| `result.nonceWindow` | integer (int64) | Custom nonce window value (0 if not configured) |
| `result.permissions` | array | List of permissions assigned to the API key. Values correspond to the API Key permission settings:  \| Value \| API Key Permission \| \|---\|---\| \| `query-funds` \| Funds permissions - Query \| \| `add-funds` \| Funds permissions - Deposit \| \| `withdraw-funds` \| Funds permissions - Withdraw \| \| `earn-funds` \| Funds permissions - Earn \| \| `query-open-trades` \| Orders and trades - Query open orders & trades \| \| `query-closed-trades` \| Orders and trades - Query closed orders & trades \| \| `modify-trades` \| Orders and trades - Create & modify orders \| \| `close-trades` \| Orders and trades - Cancel & close orders \| \| `query-ledger` \| Data - Query ledger entries \| \| `export-data` \| Data - Export data \| \| `create-ws-token` \| WebSocket interface - On \| \| `add-withdraw-address` \| Add withdrawal addresses \| \| `update-withdraw-address` \| Update withdrawal addresses \| |
| `result.permissions[]` | string |  |
| `result.iban` | string | IIBAN (Internal IBAN) of the account associated with the API key |
| `result.validUntil` | string | Unix timestamp for key expiration (0 if not set) |
| `result.queryFrom` | string | Unix timestamp for earliest allowed query date (0 if not set) |
| `result.queryTo` | string | Unix timestamp for latest allowed query date (0 if not set) |
| `result.createdTime` | string | Unix timestamp of when the API key was created |
| `result.modifiedTime` | string | Unix timestamp of when the API key was last modified |
| `result.ipAllowlist` | array | List of IP addresses or ranges allowed to use this API key (empty if not restricted) |
| `result.ipAllowlist[]` | string |  |
| `result.lastUsed` | string, nullable | Unix timestamp of when the API key was last used (null if never used) |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "apiKeyName": "my-api-key",
    "apiKey": "4/SDrDBcOOPnm3nPlNfEMMJDeRcIVqPz+QhRxIodyZbI9po/aVRiHsgX",
    "nonce": "1772627060997",
    "nonceWindow": 0,
    "permissions": [
      "query-funds",
      "withdraw-funds",
      "query-open-trades",
      "modify-trades"
    ],
    "iban": "AA88 N84G WOAK NMOI",
    "validUntil": "0",
    "queryFrom": "0",
    "queryTo": "0",
    "createdTime": "1772542900",
    "modifiedTime": "1772543095",
    "ipAllowlist": [],
    "lastUsed": "1772627061"
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/GetApiKeyInfo" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
