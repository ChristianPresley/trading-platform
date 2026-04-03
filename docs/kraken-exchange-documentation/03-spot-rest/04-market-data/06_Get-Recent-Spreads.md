# Get Recent Spreads

> Source: https://docs.kraken.com/api/docs/rest-api/get-recent-spreads

## Endpoint

`GET https://api.kraken.com/0/public/Spread`

## Description

Returns the last ~200 top-of-book spreads for a given pair.

## Authentication

None required. This is a public endpoint.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pair` | string | **Yes** | Asset pair to get data for. Example: `XBTUSD` |
| `since` | integer | No | Returns spread data since given timestamp. Optional, intended for incremental updates within available dataset (does not contain all historical spreads). Example: `1678219570` |
| `asset_class` | string | No | This parameter is required on requests for non-crypto pairs, i.e. use `tokenized_asset` for xstocks. Possible values: `tokenized_asset`. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | string[] | Array of error messages. Empty on success. |
| `result` | object | Result object containing spread data and last ID |
| `result.last` | integer | ID to be used as `since` when polling for new spread data |
| `result.<pair_name>` | array[] | Array of spread entry arrays (see Spread Entry format below) |

### Spread Entry Array Format

Each entry in the spreads array is a tuple with exactly 3 elements:

| Index | Type | Description |
|-------|------|-------------|
| 0 | integer | Time (Unix timestamp) |
| 1 | string | Bid price |
| 2 | string | Ask price |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/public/Spread?pair=XBTUSD' \
  -H 'Accept: application/json'
```

### With Since Parameter

```bash
curl -L 'https://api.kraken.com/0/public/Spread?pair=XBTUSD&since=1678219570' \
  -H 'Accept: application/json'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "XXBTZUSD": [
      [1688669065, "66814.20000", "66814.30000"],
      [1688669066, "66813.00000", "66814.30000"],
      [1688669066, "66813.00000", "66813.10000"]
    ],
    "last": 1688669448
  }
}
```

## Notes

- Only approximately the last 200 spread entries are available; this endpoint does not provide a complete history.
- The `since` parameter is intended for incremental updates within the available dataset. It does not provide access to historical spread data beyond what is retained.
- The `last` field in the response should be used as the `since` parameter in subsequent requests for incremental polling.
- The spread is the difference between the ask and bid prices. Each entry captures a snapshot of the top-of-book spread at a given moment.
- Multiple spread entries can share the same timestamp if the spread changed multiple times within the same second.
