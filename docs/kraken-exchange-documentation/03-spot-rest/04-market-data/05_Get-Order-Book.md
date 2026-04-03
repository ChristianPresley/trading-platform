# Get Order Book

> Source: https://docs.kraken.com/api/docs/rest-api/get-order-book

## Endpoint

`GET https://api.kraken.com/0/public/Depth`

## Description

Returns level 2 (L2) order book, which describes the individual price levels in the book with aggregated order quantities at each level.

## Authentication

None required. This is a public endpoint.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pair` | string | **Yes** | Asset pair to get data for. Example: `XBTUSD` |
| `count` | integer | No | Maximum number of asks/bids. Default: `100`. Possible values: `>= 1` and `<= 500`. Example: `2` |
| `asset_class` | string | No | This parameter is required on requests for non-crypto pairs, i.e. use `tokenized_asset` for xstocks. Possible values: `tokenized_asset`. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | string[] | Array of error messages. Empty on success. |
| `result` | object | Object with pair name as key and OrderBook object as value |

### OrderBook Object

| Field | Type | Description |
|-------|------|-------------|
| `asks` | array[] | Ask side array of entries. Each entry is `[<price>, <volume>, <timestamp>]` (exactly 3 elements). |
| `bids` | array[] | Bid side array of entries. Each entry is `[<price>, <volume>, <timestamp>]` (exactly 3 elements). |

### Order Book Entry Format

Each entry in the `asks` and `bids` arrays is a tuple with exactly 3 elements:

| Index | Type | Description |
|-------|------|-------------|
| 0 | string | Price level |
| 1 | string | Volume at this price level (aggregated) |
| 2 | integer | Unix timestamp of the last update at this price level |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/public/Depth?pair=XBTUSD&count=2' \
  -H 'Accept: application/json'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "XXBTZUSD": {
      "asks": [
        ["66843.00000", "0.031", 1688669448],
        ["66844.60000", "0.001", 1688669450]
      ],
      "bids": [
        ["66842.90000", "3.117", 1688669452],
        ["66840.50000", "0.749", 1688669448]
      ]
    }
  }
}
```

## Notes

- This is a Level 2 (L2) order book, meaning orders at the same price level are aggregated into a single volume.
- The `count` parameter limits the number of price levels returned per side (asks and bids), not the total number of entries.
- Prices are sorted: asks in ascending order (lowest first), bids in descending order (highest first).
- For individual order-level data, use the Level 3 order book endpoint (`/private/Level3`) instead.
- The maximum number of price levels per side is 500.
