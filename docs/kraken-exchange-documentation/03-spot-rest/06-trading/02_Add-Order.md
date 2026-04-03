# Add Order

> Source: https://docs.kraken.com/api/docs/rest-api/add-order

## Endpoint
`POST /0/private/AddOrder`

## Description
Place a new order on the Kraken spot exchange. See the AssetPairs endpoint for details on available trading pairs, their price and quantity precisions, order minimums, available leverage, etc.

## Authentication
Requires a valid API key with the following permission:
- `Orders and trades - Create & modify orders`

Authenticated using the standard Kraken private endpoint signing scheme (API-Key header, API-Sign header with HMAC-SHA512 signature using the API secret, nonce, and POST data).

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer (commonly a UNIX timestamp in milliseconds). |
| `userref` | integer | No | User reference ID. A 32-bit signed integer that can be used to link/group orders. |
| `cl_ord_id` | string | No | Client-originating unique order ID (max 18 characters). Used for order identification across the system. Must be unique for each open order. |
| `ordertype` | string | Yes | Order type. Allowed values: `market`, `limit`, `stop-loss`, `take-profit`, `stop-loss-limit`, `take-profit-limit`, `trailing-stop`, `trailing-stop-limit`, `settle-position`. |
| `type` | string | Yes | Order direction. Allowed values: `buy`, `sell`. |
| `volume` | string | No | Order quantity in terms of the base asset. Required for all order types except `settle-position`. For market `buy` orders with `oflags` containing `viqc`, this is the amount of quote currency to spend. |
| `displayvol` | string | No | Iceberg order visible quantity. Only used with `limit` order type. Must be less than `volume`. |
| `pair` | string | Yes | Asset pair ID or altname (e.g., `XXBTZUSD`, `XBTUSD`). |
| `price` | string | Conditional | Price. Required for: `limit`, `stop-loss`, `take-profit`, `stop-loss-limit`, `take-profit-limit`, `trailing-stop`, `trailing-stop-limit`. For `trailing-stop` and `trailing-stop-limit`, this is the trailing stop offset (either absolute or percentage based on `oflags`). Prefix `+` or `-` for relative pricing from the current market price. Prefix `#` for the price as a relative amount (either `+` or `-`). |
| `price2` | string | Conditional | Secondary price. Required for: `stop-loss-limit` (limit price), `take-profit-limit` (limit price), `trailing-stop-limit` (limit offset). |
| `trigger` | string | No | Price trigger type for stop-loss, take-profit, and trailing-stop orders. Allowed values: `index` (use the exchange composite index price), `last` (use the last traded price). Default: `last`. |
| `leverage` | string | No | Amount of leverage desired. Allowed values: `none` (default) or a leverage multiplier (e.g., `2`, `3`, `5`). |
| `reduce_only` | boolean | No | If `true`, the order is reduce-only. Ensures the order only reduces an existing position. Default: `false`. |
| `stptype` | string | No | Self-trade prevention type. Allowed values: `cancel-newest` (default), `cancel-oldest`, `cancel-both`. |
| `oflags` | string | No | Comma-delimited list of order flags. Allowed values: `post` (post-only order, limit only), `fcib` (prefer fee in base currency), `fciq` (prefer fee in quote currency), `nompp` (no market price protection), `viqc` (volume in quote currency, market buy only). |
| `timeinforce` | string | No | Time-in-force. Allowed values: `GTC` (Good-Till-Cancelled, default), `IOC` (Immediate-Or-Cancel), `GTD` (Good-Till-Date, requires `expiretm`). |
| `starttm` | string | No | Scheduled start time. Allowed values: `0` (now, default), `+<n>` (schedule start time `n` seconds from now), or a UNIX timestamp. |
| `expiretm` | string | No | Expiration time. Allowed values: `0` (no expiration, default), `+<n>` (expire `n` seconds from now), or a UNIX timestamp. Required when `timeinforce` is `GTD`. |
| `close[ordertype]` | string | No | Conditional close order type. Allowed values: `limit`, `stop-loss`, `take-profit`, `stop-loss-limit`, `take-profit-limit`. |
| `close[price]` | string | No | Conditional close order price. |
| `close[price2]` | string | No | Conditional close order secondary price. |
| `deadline` | string | No | RFC3339 timestamp (e.g., `2021-04-01T00:18:45Z`) after which the order request will be rejected. Used to prevent delayed execution of stale orders. |
| `validate` | boolean | No | If `true`, validate inputs only without submitting the order. Default: `false`. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object (present on success). |
| `result.descr` | object | Order description. |
| `result.descr.order` | string | Human-readable order description (e.g., `buy 1.25000000 XBTUSD @ limit 27500.0`). |
| `result.descr.close` | string | Conditional close order description (if applicable). |
| `result.txid` | array of strings | Array of transaction IDs for the order (when `validate` is `false`). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/AddOrder" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&ordertype=limit&type=buy&volume=1.25&pair=XBTUSD&price=27500.0"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "descr": {
      "order": "buy 1.25000000 XBTUSD @ limit 27500.0"
    },
    "txid": [
      "OUF4EM-FRGI2-MQMWZD"
    ]
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EOrder:Insufficient funds` | Insufficient balance to place the order. |
| `EOrder:Minimum order volume not met` | Order volume is below the minimum for the pair. |
| `EOrder:Invalid order` | Order parameters are invalid. |
| `EOrder:Rate limit exceeded` | Too many orders placed in a short time. |
| `EOrder:Positions limit exceeded` | Maximum number of open positions reached. |
| `EOrder:Orders limit exceeded` | Maximum number of open orders reached (typically 225 for standard accounts). |
| `EOrder:Unknown position` | Position referenced for `settle-position` does not exist. |
| `EOrder:Post only order` | Post-only order would immediately match (rejected). |
| `EAPI:Invalid nonce` | Nonce is not valid (must be increasing). |

## Notes

- The maximum number of open orders is typically 225 for standard accounts.
- Trailing stop orders use the `price` field for the trail offset. Append `%` to the price or use `oflags` to specify percentage-based trailing.
- Relative prices can be specified using `+` or `-` prefix for limit orders relative to the current market price.
- The `#` prefix can be used for relative amounts.
- When `validate` is `true`, the order is not actually submitted; only input validation is performed.
- Self-trade prevention (STP) ensures orders from the same account do not trade against each other.
- Iceberg orders (using `displayvol`) are only available for `limit` orders.
- The `settle-position` order type is used to settle open margin positions.
