# Get Your Fills

## Endpoint

```
GET /fills
```

## Description

Returns information on your filled orders for all futures contracts. This endpoint provides the trade execution history for the authenticated account.

## Authentication

Requires API key authentication with Futures trading permissions. Requests must include the `APIKey` and `Authent` headers using the standard Kraken Futures authentication scheme (HMAC-SHA-512 signature).

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lastFillTime` | string | No | ISO 8601 timestamp to filter fills after this time |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `fills` | array | List of fill objects |
| `fills[].instrument` | string | The futures contract symbol |
| `fills[].time` | string | ISO 8601 timestamp of the fill |
| `fills[].price` | number | Execution price |
| `fills[].size` | number | Number of contracts filled |
| `fills[].side` | string | Trade side (`buy` or `sell`) |
| `fills[].orderId` | string | The order ID that generated this fill |
| `fills[].fillId` | string | Unique identifier for this fill |
| `fills[].fillType` | string | Type of fill (e.g., `maker`, `taker`, `liquidation`) |
| `fills[].feesPaid` | number | Fees paid for this fill |
| `fills[].feeCurrency` | string | Currency in which fees were denominated |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/fills" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

### With Filter

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/fills?lastFillTime=2024-01-01T00:00:00.000Z" \
  -H "APIKey: <your-api-key>" \
  -H "Authent: <your-auth-signature>"
```

## Example Response

```json
{
  "result": "success",
  "fills": [
    {
      "instrument": "pi_xbtusd",
      "time": "2024-01-15T14:30:00.000Z",
      "price": 42500.0,
      "size": 1000,
      "side": "buy",
      "orderId": "order-uuid-here",
      "fillId": "fill-uuid-here",
      "fillType": "taker",
      "feesPaid": 0.50,
      "feeCurrency": "USD"
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

- Returns fills for all futures contracts. Filter by `lastFillTime` to paginate through results.
- Fill data is essential for reconciliation, P&L tracking, and trade reporting.
- The `fillType` field indicates whether you were the maker or taker, or if the fill resulted from a liquidation.
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/get-fills)
