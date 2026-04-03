# List Subaccounts

## Endpoint

```
GET /subaccounts
```

## Description

Returns information about subaccounts, including balances and UIDs. This provides a complete view of all subaccounts under the authenticated master account.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

This endpoint does not accept any request parameters.

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `subaccounts` | array | List of subaccount objects |
| `subaccounts[].uid` | string | Unique identifier for the subaccount |
| `subaccounts[].name` | string | Name of the subaccount |
| `subaccounts[].tradingEnabled` | boolean | Whether trading is enabled for this subaccount |
| `subaccounts[].balances` | object | Balance information for the subaccount |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/subaccounts" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "subaccounts": [
    {
      "uid": "abc123-def456",
      "name": "Trading Bot 1",
      "tradingEnabled": true,
      "balances": {}
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

- This endpoint is only available for master accounts that have subaccount functionality enabled.
- Related endpoints: Get Subaccount Trading Capability (`GET /subaccount/:subaccountUid/trading-enabled`), Update Subaccount Trading Capability (`PUT /subaccount/:subaccountUid/trading-enabled`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/list-subaccounts)
