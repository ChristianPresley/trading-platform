# Get Grouped Order Book

> Source: https://docs.kraken.com/api/docs/rest-api/get-grouped-order-book

## Endpoint

`GET https://api.kraken.com/0/public/GroupedBook`

## Description

The GroupedBook endpoint aggregates the volume in the order book over a specified tick range. It provides a summary of liquidity deep into the book, useful for user interface display.

Bids and asks between grouped price levels are accumulated to the nearest passive level (asks rounded up, bids down).

## Authentication

None required. This is a public endpoint.

## Request Parameters

Request body is JSON (`application/json`).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pair` | string | **Yes** | Asset pair to get order book for. Example: `BTC/USD` |
| `depth` | integer | No | The number of price levels to return per side (bids/asks). Default: `10`. Possible values: `10`, `25`, `100`, `250`, `1000`. Example: `10` |
| `grouping` | integer (int32, nullable) | No | Specifies how many tick levels should be within each price level. Bids and asks between grouped price levels are accumulated to the nearest passive level (asks rounded up, bids down). Default: `1`. Possible values: `1`, `5`, `10`, `25`, `50`, `100`, `250`, `500`, `1000`. Example: `1000` |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array[] | Array of error messages. Empty on success. |
| `result` | object | Result object containing grouped order book data |
| `result.pair` | string | Asset pair |
| `result.grouping` | integer | The grouping value used |
| `result.bids` | object[] | Array of aggregated bid level objects |
| `result.asks` | object[] | Array of aggregated ask level objects |

### Bid/Ask Level Object

Each entry in the `bids` and `asks` arrays is an object with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `price` | string | Grouped price level |
| `qty` | string | Aggregated quantity at this price level |

## Example Request

### cURL

```bash
curl -L -X GET 'https://api.kraken.com/0/public/GroupedBook' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{
    "pair": "BTC/USD",
    "depth": 10,
    "grouping": 1000
  }'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "pair": "XBTUSD",
    "bids": [
      {"price": "66842.90000", "qty": "3.89495027"},
      {"price": "66841.80000", "qty": "0.74803402"},
      {"price": "66839.60000", "qty": "0.74805934"},
      {"price": "66838.00000", "qty": "0.00005100"},
      {"price": "66837.80000", "qty": "0.07840000"},
      {"price": "66837.30000", "qty": "0.59853100"},
      {"price": "66836.60000", "qty": "0.74809208"},
      {"price": "66835.30000", "qty": "1.43647500"},
      {"price": "66834.70000", "qty": "0.00005100"},
      {"price": "66833.50000", "qty": "0.02000000"}
    ],
    "asks": [
      {"price": "66843.00000", "qty": "0.03092115"},
      {"price": "66844.60000", "qty": "0.00005100"},
      {"price": "66847.90000", "qty": "0.00005100"},
      {"price": "66848.20000", "qty": "0.74796408"},
      {"price": "66851.30000", "qty": "0.00005100"},
      {"price": "66854.60000", "qty": "0.00005100"},
      {"price": "66854.70000", "qty": "0.23980800"},
      {"price": "66856.20000", "qty": "0.74787409"},
      {"price": "66856.40000", "qty": "0.07840000"},
      {"price": "66856.50000", "qty": "0.06395195"}
    ],
    "grouping": 1
  }
}
```

## Notes

- Unlike the standard L2 order book (`/public/Depth`), the GroupedBook endpoint uses JSON request body via GET, not query parameters.
- The `grouping` parameter controls how many tick levels are combined into each reported price level. A grouping of `1` means no aggregation across ticks.
- Asks are rounded **up** to the nearest passive level, and bids are rounded **down** when grouping is applied. This ensures conservative display of available liquidity.
- The `grouping` parameter is nullable; when null, the default grouping of `1` is used.
- This endpoint is designed primarily for UI display purposes, providing a summary view of deep book liquidity.
- The response uses structured objects (`{price, qty}`) rather than the array tuples used by the L2 order book endpoint.
