# Get Subaccount Trading Capability

## Endpoint

```
GET /subaccount/:subaccountUid/trading-enabled
```

## Description

Returns trading capability information for a given subaccount. This indicates whether trading is currently enabled or disabled for the specified subaccount.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Location | Description |
|-----------|------|----------|----------|-------------|
| `subaccountUid` | string | Yes | Path | The unique identifier of the subaccount |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `tradingEnabled` | boolean | Whether trading is enabled for the subaccount |
| `subaccountUid` | string | The unique identifier of the subaccount |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/subaccount/abc123-def456/trading-enabled" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "tradingEnabled": true,
  "subaccountUid": "abc123-def456"
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 401 | Unauthorized - invalid or missing API credentials |
| 404 | The account or subaccount could not be found |
| 500 | Internal server error |

## Notes

- The `subaccountUid` must correspond to a valid subaccount under the authenticated master account.
- A 404 error indicates either the master account or the specified subaccount does not exist.
- Related endpoints: Update Subaccount Trading Capability (`PUT /subaccount/:subaccountUid/trading-enabled`), List Subaccounts (`GET /subaccounts`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-subaccount-trading-capability)
