# Update Subaccount Trading Capability

## Endpoint

```
PUT /subaccount/:subaccountUid/trading-enabled
```

## Description

Updates trading capabilities for a given subaccount. This endpoint allows enabling or disabling trading for a specific subaccount.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Location | Description |
|-----------|------|----------|----------|-------------|
| `subaccountUid` | string | Yes | Path | The unique identifier of the subaccount |
| `tradingEnabled` | boolean | Yes | Body | Whether to enable (`true`) or disable (`false`) trading for the subaccount |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |

## Example Request

```bash
curl -X PUT "https://futures.kraken.com/derivatives/api/v3/subaccount/abc123-def456/trading-enabled" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>" \
  -H "Content-Type: application/json" \
  -d '{"tradingEnabled": true}'
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
| 404 | The account or subaccount could not be found |
| 500 | Internal server error |

## Notes

- A successful 200 response indicates "Trading was successfully enabled/disabled."
- The `subaccountUid` must correspond to a valid subaccount under the authenticated master account.
- Disabling trading will prevent the subaccount from placing new orders but will not cancel existing open orders.
- Related endpoints: Get Subaccount Trading Capability (`GET /subaccount/:subaccountUid/trading-enabled`), List Subaccounts (`GET /subaccounts`).
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/update-subaccount-trading-capability)
