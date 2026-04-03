# Get Post-Trade Data

> Source: https://docs.kraken.com/api/docs/rest-api/get-post-trade

## Endpoint
`GET /0/public/PostTrade`

## Description
Returns a list of trades on the spot exchange. If no filter parameters are specified, the last 1000 trades for all pairs are returned. This is a public endpoint used for MiFID II / MiCAR post-trade transparency reporting.

## Authentication
None required. This is a public endpoint.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pair` | string | No | Asset pair to filter trades (e.g., `XBTUSD`, `ETHUSD`). If omitted, trades for all pairs are returned. |
| `start` | string | No | Start timestamp (UNIX timestamp) to filter results. Only trades after this time are returned. |
| `end` | string | No | End timestamp (UNIX timestamp) to filter results. Only trades before this time are returned. |
| `count` | integer | No | Number of trades to return. Default: 1000. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object containing trade data. |
| `result.trades` | array of objects | Array of trade objects. |
| `result.trades[].pair` | string | Asset pair (e.g., `XXBTZUSD`). |
| `result.trades[].time` | number | Trade execution timestamp (UNIX timestamp with decimal precision). |
| `result.trades[].type` | string | Trade direction: `buy` or `sell` (taker side). |
| `result.trades[].ordertype` | string | Order type that triggered the trade (e.g., `market`, `limit`). |
| `result.trades[].price` | string | Trade execution price. |
| `result.trades[].volume` | string | Trade volume (quantity). |
| `result.trades[].misc` | string | Miscellaneous info. |
| `result.trades[].trade_id` | integer | Unique trade identifier. |
| `result.count` | integer | Total number of trades returned. |

## Example Request

```bash
curl -X GET "https://api.kraken.com/0/public/PostTrade?pair=XBTUSD"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "trades": [
      {
        "pair": "XXBTZUSD",
        "time": 1617014586.1234,
        "type": "buy",
        "ordertype": "market",
        "price": "27500.50",
        "volume": "0.01500000",
        "misc": "",
        "trade_id": 123456789
      },
      {
        "pair": "XXBTZUSD",
        "time": 1617014585.5678,
        "type": "sell",
        "ordertype": "limit",
        "price": "27499.00",
        "volume": "0.50000000",
        "misc": "",
        "trade_id": 123456788
      }
    ],
    "count": 2
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid parameters. |
| `EQuery:Unknown asset pair` | The specified asset pair is not recognized. |

## Notes

- This is a public endpoint; no API key or authentication is required.
- If no filter parameters are specified, the last 1000 trades across all pairs are returned.
- This endpoint is part of Kraken's regulatory transparency reporting (MiFID II / MiCAR compliance).
- Trades are returned in reverse chronological order (newest first).
- The `type` field indicates the taker side of the trade (the order that was matched against a resting order).
- The `time` field includes sub-second precision as a decimal.
- Trade data represents executed trades on the Kraken spot exchange.
