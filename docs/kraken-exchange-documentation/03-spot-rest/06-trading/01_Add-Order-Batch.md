# Add Order Batch

> Source: https://docs.kraken.com/api/docs/rest-api/add-order-batch

## Endpoint
`POST /0/private/AddOrderBatch`

## Description
Send a batch of orders (minimum 2, maximum 15) to the exchange. All orders in the batch must be for the same trading pair.

The entire batch undergoes validation before being submitted to the matching engine. If any individual order fails validation, the entire batch is rejected. However, once the batch passes validation and is submitted to the engine, if an order fails pre-match checks (such as insufficient funding), that specific order is rejected while the remaining orders continue to process.

## Authentication
Requires a valid API key with the following permissions:
- `Orders and trades - Create & modify orders`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `pair` | string | Yes | Asset pair for all orders in the batch (e.g., `XBTUSD`). All orders must be for this single pair. |
| `deadline` | string | No | RFC3339 timestamp after which the batch request will be rejected. |
| `validate` | boolean | No | If `true`, validate inputs only without submitting orders. Default: `false`. |
| `orders` | array of objects | Yes | Array of order objects (minimum 2, maximum 15). Each order object supports the same parameters as AddOrder (see below). |

### Order Object Parameters

Each object in the `orders` array supports the following fields:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `userref` | integer | No | User reference ID (32-bit signed integer). |
| `cl_ord_id` | string | No | Client order ID (max 18 characters). |
| `ordertype` | string | Yes | Order type: `market`, `limit`, `stop-loss`, `take-profit`, `stop-loss-limit`, `take-profit-limit`, `trailing-stop`, `trailing-stop-limit`, `settle-position`. |
| `type` | string | Yes | Order direction: `buy` or `sell`. |
| `volume` | string | Yes | Order quantity in terms of the base asset. |
| `displayvol` | string | No | Iceberg order visible quantity (limit orders only). |
| `price` | string | Conditional | Price (required for limit and stop/take-profit order types). |
| `price2` | string | Conditional | Secondary price (required for stop-loss-limit and take-profit-limit). |
| `trigger` | string | No | Price trigger type: `index` or `last` (default: `last`). |
| `leverage` | string | No | Leverage amount (e.g., `2`, `3`, `5`). Default: `none`. |
| `reduce_only` | boolean | No | Reduce-only flag. Default: `false`. |
| `stptype` | string | No | Self-trade prevention: `cancel-newest` (default), `cancel-oldest`, `cancel-both`. |
| `oflags` | string | No | Comma-delimited order flags: `post`, `fcib`, `fciq`, `nompp`, `viqc`. |
| `timeinforce` | string | No | Time-in-force: `GTC` (default), `IOC`, `GTD`. |
| `starttm` | string | No | Scheduled start time. |
| `expiretm` | string | No | Expiration time. |
| `close[ordertype]` | string | No | Conditional close order type. |
| `close[price]` | string | No | Conditional close order price. |
| `close[price2]` | string | No | Conditional close order secondary price. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object (present on success). |
| `result.orders` | array of objects | Array of order result objects, in the same order as the request. |
| `result.orders[].txid` | string | Transaction ID of the placed order. |
| `result.orders[].descr` | object | Order description object. |
| `result.orders[].descr.order` | string | Human-readable order description. |
| `result.orders[].descr.close` | string | Conditional close order description (if applicable). |
| `result.orders[].error` | string | Error message for this specific order (if it failed). |
| `result.orders[].close` | string | Close order description (if applicable). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/AddOrderBatch" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594&pair=XBTUSD&orders[0][ordertype]=limit&orders[0][type]=buy&orders[0][volume]=1.0&orders[0][price]=25000.0&orders[1][ordertype]=limit&orders[1][type]=sell&orders[1][volume]=1.0&orders[1][price]=30000.0"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "orders": [
      {
        "txid": "OUF4EM-FRGI2-MQMWZD",
        "descr": {
          "order": "buy 1.00000000 XBTUSD @ limit 25000.0"
        }
      },
      {
        "txid": "OB5VMB-B4U2U-DK2WRW",
        "descr": {
          "order": "sell 1.00000000 XBTUSD @ limit 30000.0"
        }
      }
    ]
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EOrder:Invalid order` | One or more orders have invalid parameters (batch rejected). |
| `EOrder:Insufficient funds` | Insufficient balance (individual order rejected post-validation). |
| `EOrder:Orders limit exceeded` | Maximum number of open orders reached. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- All orders in a batch must be for the same trading pair.
- Minimum batch size is 2 orders; maximum is 15 orders.
- If any order fails validation, the entire batch is rejected before any orders are placed.
- Once past validation, individual order failures (e.g., insufficient funds) only affect that specific order; the remaining orders in the batch continue to be processed.
- The order of the `orders` array in the response matches the order of the request.
- See the AssetPairs endpoint for details on available trading pairs, price and quantity precisions, order minimums, and available leverage.
