# Get Recent Trades

> Source: https://docs.kraken.com/api/docs/rest-api/get-recent-trades

## Endpoint

`GET https://api.kraken.com/0/public/Trades`

## Description

Returns the last 1000 trades by default.

## Authentication

None required. This is a public endpoint.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pair` | string | **Yes** | Asset pair to get data for. Example: `XBTUSD` |
| `since` | string | No | Return trade data since given timestamp. Example: `1616663618` |
| `count` | integer | No | Return specific number of trades, up to 1000. Default: `1000`. Possible values: `>= 1` and `<= 1000`. Example: `2` |
| `asset_class` | string | No | This parameter is required on requests for non-crypto pairs, i.e. use `tokenized_asset` for xstocks. Possible values: `tokenized_asset`. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | string[] | Array of error messages. Empty on success. |
| `result` | object | Result object containing trade data and last ID |
| `result.last` | string | ID to be used as `since` when polling for new trade data |
| `result.<pair_name>` | array[] | Array of trade entry arrays (see Trade Entry format below) |

### Trade Entry Array Format

Each entry in the trades array is a tuple with 7 elements:

| Index | Type | Description |
|-------|------|-------------|
| 0 | string | Price |
| 1 | string | Volume |
| 2 | number | Time (Unix timestamp with fractional seconds) |
| 3 | string | Buy/sell indicator: `"b"` = buy, `"s"` = sell |
| 4 | string | Market/limit indicator: `"m"` = market, `"l"` = limit |
| 5 | string | Miscellaneous (empty string if none) |
| 6 | integer | Trade ID |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/public/Trades?pair=XBTUSD&count=2' \
  -H 'Accept: application/json'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "XXBTZUSD": [
      [
        "66824.30000",
        "0.10000000",
        1688669448.330884,
        "b",
        "l",
        "",
        98240918
      ],
      [
        "66842.90000",
        "0.00062987",
        1688669449.543850,
        "s",
        "l",
        "",
        98240919
      ]
    ],
    "last": "1688669449543850696"
  }
}
```

## Notes

- The `last` field is a string representing a nanosecond-precision timestamp that should be used as the `since` parameter for incremental polling.
- The `since` parameter accepts timestamps in various precisions (seconds, nanoseconds).
- The trade `time` field (index 2) is a floating-point Unix timestamp with fractional seconds for sub-second precision.
- Trade IDs (index 6) are sequential integers.
- The buy/sell indicator (`"b"`/`"s"`) refers to the taker side of the trade.
- The market/limit indicator (`"m"`/`"l"`) refers to the type of the taker order.
- Default response includes the most recent 1000 trades when no `count` or `since` parameters are provided.
