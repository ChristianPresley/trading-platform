# Historical Funding Rates

## Endpoint

```
GET /historical-funding-rates
```

## Description

Returns a list of historical funding rates for a given market. Funding rates are periodic payments exchanged between long and short position holders in perpetual futures contracts to keep the contract price anchored to the spot price.

## Authentication

This endpoint may be publicly accessible without authentication.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `symbol` | string | Yes | The perpetual futures contract symbol (e.g., `PF_XBTUSD`) |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `result` | string | Status of the request (e.g., `success`) |
| `rates` | array | List of historical funding rate objects |
| `rates[].timestamp` | string | ISO 8601 timestamp of the funding rate |
| `rates[].fundingRate` | number | The funding rate value (positive means longs pay shorts, negative means shorts pay longs) |
| `rates[].relativeFundingRate` | number | The relative funding rate as a decimal |

## Example Request

```bash
curl -X GET "https://futures.kraken.com/derivatives/api/v3/historical-funding-rates?symbol=PF_XBTUSD"
```

## Example Response

```json
{
  "result": "success",
  "rates": [
    {
      "timestamp": "2024-01-15T08:00:00.000Z",
      "fundingRate": 0.000025,
      "relativeFundingRate": 0.000025
    },
    {
      "timestamp": "2024-01-15T04:00:00.000Z",
      "fundingRate": -0.000010,
      "relativeFundingRate": -0.000010
    }
  ]
}
```

## Error Codes

| HTTP Status | Description |
|-------------|-------------|
| 400 | Symbol is invalid or does not reference a perpetual market |
| 500 | Internal server error |

## Notes

- This endpoint only applies to perpetual futures contracts. Fixed-maturity futures do not have funding rates.
- The `symbol` parameter must reference a perpetual market (e.g., `PF_XBTUSD`). Providing a non-perpetual symbol will return a 400 error.
- Funding rates are typically calculated and applied every 4 hours (at 00:00, 04:00, 08:00, 12:00, 16:00, 20:00 UTC).
- A positive funding rate means long position holders pay short position holders; a negative rate means shorts pay longs.
- Source: [Kraken API Docs](https://docs.kraken.com/api/docs/futures-api/trading/historical-funding-rates)
