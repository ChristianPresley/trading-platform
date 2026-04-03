# Get OHLC Data

> Source: https://docs.kraken.com/api/docs/rest-api/get-ohlc-data

## Endpoint

`GET https://api.kraken.com/0/public/OHLC`

## Description

Retrieve OHLC market data. The last entry in the OHLC array is for the current, not-yet-committed timeframe, and will always be present, regardless of the value of `since`. Returns up to 720 of the most recent entries (older data cannot be retrieved, regardless of the value of `since`).

## Authentication

None required. This is a public endpoint.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pair` | string | **Yes** | Asset pair to get data for. Example: `XBTUSD` |
| `interval` | integer | No | Time frame interval in minutes. Default: `1`. Possible values: `1`, `5`, `15`, `30`, `60`, `240`, `1440`, `10080`, `21600`. Example: `60` |
| `since` | integer | No | Return OHLC entries since the given timestamp (intended for incremental updates). Example: `1688671200` |
| `asset_class` | string | No | This parameter is required on requests for non-crypto pairs, i.e. use `tokenized_asset` for xstocks. Possible values: `tokenized_asset`. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | string[] | Array of error messages. Empty on success. |
| `result` | object | Result object containing OHLC data and last ID |
| `result.last` | integer | ID to be used as `since` when polling for new, committed OHLC data |
| `result.<pair_name>` | array[] | Array of tick data arrays (see TickData format below) |

### TickData Array Format

Each entry in the OHLC array is a tuple with exactly 8 elements:

| Index | Type | Description |
|-------|------|-------------|
| 0 | integer | Time (Unix timestamp, start of the interval) |
| 1 | string | Open price |
| 2 | string | High price |
| 3 | string | Low price |
| 4 | string | Close price |
| 5 | string | VWAP (volume-weighted average price) |
| 6 | string | Volume |
| 7 | integer | Count of trades in the interval |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/public/OHLC?pair=XBTUSD&interval=60' \
  -H 'Accept: application/json'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "XXBTZUSD": [
      [1688671200, "68336.7", "68421.5", "67886.0", "68116.7", "68134.0", "39.07780953", 2594],
      [1688674800, "68116.8", "68897.7", "67973.3", "68401.8", "68443.3", "58.69706468", 2935],
      [1688678400, "68418.0", "68431.4", "68009.7", "68314.7", "68205.0", "57.48607548", 1991]
    ],
    "last": 1688752800
  }
}
```

## Notes

- A maximum of 720 recent entries are returnable; historical data beyond this limit cannot be accessed regardless of the `since` parameter.
- The `since` parameter is intended for incremental updates. It does not provide access to older historical data beyond the 720-entry window.
- The last entry in the OHLC array represents the current, not-yet-committed timeframe and is always present regardless of the `since` value.
- The `last` field in the response should be used as the `since` parameter in subsequent requests for incremental polling.
- Interval values correspond to: 1 min, 5 min, 15 min, 30 min, 1 hour, 4 hours, 1 day, 1 week, 15 days.
