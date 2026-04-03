# Get Pre-Trade Data

> Source: https://docs.kraken.com/api/docs/rest-api/get-pre-trade

## Endpoint
`GET /0/public/PreTrade`

## Description
Retrieve the price levels in the order book with aggregated order quantities at each price level. The API returns the top 10 levels for each trading pair. This is a public endpoint used for MiFID II / MiCAR pre-trade transparency reporting.

## Authentication
None required. This is a public endpoint.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pair` | string | No | Asset pair to get pre-trade data for (e.g., `XBTUSD`, `ETHUSD`). If omitted, data for all pairs may be returned. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object containing pre-trade data keyed by pair name. |
| `result.<pair>` | object | Pre-trade data for the specified pair. |
| `result.<pair>.bids` | array of arrays | Array of bid price levels. Each entry is `[price, volume, timestamp]`. |
| `result.<pair>.bids[][0]` | string | Bid price at this level. |
| `result.<pair>.bids[][1]` | string | Aggregated volume at this bid price level. |
| `result.<pair>.bids[][2]` | integer | Timestamp (UNIX). |
| `result.<pair>.asks` | array of arrays | Array of ask price levels. Each entry is `[price, volume, timestamp]`. |
| `result.<pair>.asks[][0]` | string | Ask price at this level. |
| `result.<pair>.asks[][1]` | string | Aggregated volume at this ask price level. |
| `result.<pair>.asks[][2]` | integer | Timestamp (UNIX). |

## Example Request

```bash
curl -X GET "https://api.kraken.com/0/public/PreTrade?pair=XBTUSD"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "XXBTZUSD": {
      "bids": [
        ["27500.0", "1.500", 1617014586],
        ["27499.5", "2.300", 1617014586],
        ["27499.0", "0.750", 1617014585],
        ["27498.5", "3.100", 1617014585],
        ["27498.0", "1.200", 1617014584],
        ["27497.5", "0.500", 1617014584],
        ["27497.0", "4.000", 1617014583],
        ["27496.5", "1.800", 1617014583],
        ["27496.0", "2.500", 1617014582],
        ["27495.5", "0.900", 1617014582]
      ],
      "asks": [
        ["27500.5", "0.800", 1617014586],
        ["27501.0", "1.200", 1617014586],
        ["27501.5", "3.500", 1617014585],
        ["27502.0", "0.600", 1617014585],
        ["27502.5", "2.100", 1617014584],
        ["27503.0", "1.500", 1617014584],
        ["27503.5", "0.400", 1617014583],
        ["27504.0", "2.800", 1617014583],
        ["27504.5", "1.100", 1617014582],
        ["27505.0", "0.700", 1617014582]
      ]
    }
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid pair or parameters. |
| `EQuery:Unknown asset pair` | The specified asset pair is not recognized. |

## Notes

- This is a public endpoint; no API key or authentication is required.
- Returns the top 10 price levels for each side (bids and asks).
- Order quantities are aggregated at each price level.
- This endpoint is part of Kraken's regulatory transparency reporting (MiFID II / MiCAR compliance).
- Data represents the current state of the order book at the time of the request.
- The `pair` parameter uses standard Kraken pair naming conventions (e.g., `XBTUSD`, `ETHUSD`).
