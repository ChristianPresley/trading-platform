# Get Ticker Information

> Source: https://docs.kraken.com/api/docs/rest-api/get-ticker-information

## Endpoint

`GET https://api.kraken.com/0/public/Ticker`

## Description

Get ticker information for all or requested markets.

- Today's prices start at midnight UTC.
- Leaving the `pair` parameter blank will return tickers for all tradeable assets on Kraken.

## Authentication

None required. This is a public endpoint.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pair` | string | No | Asset pair to get data for. Default: all tradeable exchange pairs. Example: `XBTUSD` |
| `asset_class` | string | No | This parameter is required on requests for tokenized pairs, i.e. xstocks. If `asset_class` is provided without the `pair` parameter, all pairs for that asset class will be returned. Default: `forex`. Possible values: `tokenized_asset`, `forex`. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | string[] | Array of error messages. Empty on success. |
| `result` | object | Object with pair names as keys and AssetTickerInfo objects as values |

### AssetTickerInfo Object

Each key in `result` is a pair name (e.g., `XXBTZUSD`), with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `a` | string[] | Ask: `[<price>, <whole lot volume>, <lot volume>]` |
| `b` | string[] | Bid: `[<price>, <whole lot volume>, <lot volume>]` |
| `c` | string[] | Last trade closed: `[<price>, <lot volume>]` |
| `v` | string[] | Volume: `[<today>, <last 24 hours>]` |
| `p` | string[] | Volume weighted average price: `[<today>, <last 24 hours>]` |
| `t` | integer[] | Number of trades: `[<today>, <last 24 hours>]` |
| `l` | string[] | Low: `[<today>, <last 24 hours>]` |
| `h` | string[] | High: `[<today>, <last 24 hours>]` |
| `o` | string | Today's opening price |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/public/Ticker' \
  -H 'Accept: application/json'
```

### With Parameters

```bash
curl -L 'https://api.kraken.com/0/public/Ticker?pair=XBTUSD' \
  -H 'Accept: application/json'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "XXBTZUSD": {
      "a": ["66828.10000", "9", "9.000"],
      "b": ["66828.00000", "1", "1.000"],
      "c": ["66828.10000", "0.00007891"],
      "v": ["34.03851926", "2069.05127456"],
      "p": ["66858.25039", "66832.03797"],
      "t": [537, 59587],
      "l": ["66805.10000", "65688.20000"],
      "h": ["66975.00000", "68632.70000"],
      "o": "66885.70000"
    }
  }
}
```

## Notes

- "Today" values reset at midnight UTC.
- "Last 24 hours" values are rolling 24-hour windows.
- The `a` (ask) and `b` (bid) arrays contain 3 elements: price, whole lot volume, and lot volume.
- The `c` (last trade closed) array contains 2 elements: the closing price and the lot volume.
- The `v`, `p`, `l`, and `h` arrays contain 2 elements each: today's value and the last 24 hours value.
- The `t` array contains integer counts of trades for today and the last 24 hours.
- Requesting without a `pair` parameter returns tickers for all tradeable assets, which can be a large response.
