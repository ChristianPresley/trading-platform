# Query L3 Order Book

> Source: https://docs.kraken.com/api/docs/rest-api/get-level-3-order-book

## Endpoint

`POST https://api.kraken.com/0/private/Level3`

## Description

Retrieve Level3 order book data, which provides individual order information at each price level. This includes order IDs and timestamps for each order in the book.

The Level3 endpoint requires authentication.

## Authentication

**Required.** This is a private endpoint.

- **API Key Permissions Required:** Orders and trades - Query open orders & trades
- **Headers Required:**
  - `API-Key` - Your API key
  - `API-Sign` - Message signature using HMAC-SHA512

## Request Parameters

Request body is JSON (`application/json`).

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer (int64) | **Yes** | Nonce used in construction of `API-Sign` header |
| `pair` | string | **Yes** | Asset pair to get order book for. Example: `YFI/EUR` |
| `depth` | integer | No | Number of price levels to return per side (bids/asks). Use `0` to return the full book. Default: `100`. Possible values: `0`, `10`, `25`, `100`, `250`, `1000`. Example: `10` |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array[] | Array of error messages. Empty on success. |
| `result` | object | Result object containing L3 order book data |
| `result.pair` | string | Asset pair |
| `result.bids` | object[] | Array of bid order objects |
| `result.asks` | object[] | Array of ask order objects |

### Bid/Ask Order Object

Each entry in the `bids` and `asks` arrays is an object with the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `price` | string | Order price |
| `qty` | string | Order quantity |
| `order_id` | string | Order ID |
| `timestamp` | integer | Order timestamp (nanoseconds) |

## Example Request

### cURL

```bash
curl -L 'https://api.kraken.com/0/private/Level3' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'API-Key: <API-Key>' \
  -H 'API-Sign: <API-Sign>' \
  -d '{
    "nonce": 0,
    "pair": "YFI/EUR",
    "depth": 10
  }'
```

## Example Response

```json
{
  "error": [],
  "result": {
    "pair": "YFI/EUR",
    "bids": [
      {
        "price": "5432.10000",
        "qty": "0.50000000",
        "order_id": "OABCDE-FGHIJ-KLMNOP",
        "timestamp": 1688669448000000000
      },
      {
        "price": "5430.00000",
        "qty": "1.25000000",
        "order_id": "OQRSTU-VWXYZ-123456",
        "timestamp": 1688669447000000000
      }
    ],
    "asks": [
      {
        "price": "5435.00000",
        "qty": "0.75000000",
        "order_id": "O78901-23456-789012",
        "timestamp": 1688669449000000000
      }
    ]
  }
}
```

## Notes

- This is a **private** endpoint requiring authentication, unlike the L2 order book (`/public/Depth`).
- The `timestamp` field is in **nanoseconds**, not seconds or milliseconds.
- Unlike the L2 order book, L3 data shows individual orders rather than aggregated volumes at each price level.
- Setting `depth` to `0` returns the full order book, which can be very large for active pairs.
- The `nonce` must be an incrementing integer (typically a Unix timestamp in milliseconds or a counter) to prevent replay attacks.
- The API key used must have the "Orders and trades - Query open orders & trades" permission enabled.
