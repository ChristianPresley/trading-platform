# Amend Order

> Source: https://docs.kraken.com/api/docs/rest-api/amend-order

## Endpoint
`POST /0/private/AmendOrder`

## Description
Amend (modify) the parameters of an open order in-place without the need to cancel the existing order and create a new one. Order identifiers remain unchanged, and queue priority is maintained where possible. If the amended quantity falls below the already-filled quantity, the remaining quantity is cancelled.

This endpoint is preferred over `EditOrder` as it provides better performance and preserves queue priority.

## Authentication
Requires a valid API key with one of the following permissions:
- `Orders and trades - Create & modify orders`
- `Orders and trades - Cancel & close orders`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `order_id` | string | Conditional | The order ID (txid) of the order to amend. Either `order_id` or `cl_ord_id` must be provided. |
| `cl_ord_id` | string | Conditional | The client order ID of the order to amend. Either `order_id` or `cl_ord_id` must be provided. |
| `order_qty` | string | No | New order quantity in terms of the base asset. |
| `display_qty` | string | No | New iceberg order display quantity. |
| `limit_price` | string | No | New limit price. |
| `trigger_price` | string | No | New trigger price for stop/take-profit orders. |
| `post_only` | boolean | No | If `true`, the amended order will be post-only. |
| `deadline` | string | No | RFC3339 timestamp after which the amend request will be rejected. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object (present on success). |
| `result.amend_id` | string | The unique Kraken amend identifier. |
| `result.order_id` | string | The order ID (txid) of the amended order (unchanged from the original). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/AmendOrder" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&order_id=OUF4EM-FRGI2-MQMWZD&order_qty=2.5&limit_price=28000.0"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "amend_id": "AMND01-XXXXX-XXXXXX",
    "order_id": "OUF4EM-FRGI2-MQMWZD"
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EOrder:Unknown order` | The specified order was not found or is not open. |
| `EOrder:Invalid order` | The amended order parameters are invalid. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- The `AmendOrder` endpoint is newer and preferred over the older `EditOrder` endpoint.
- Unlike `EditOrder`, amending preserves the order's queue priority where possible.
- The order ID (txid) does not change when an order is amended.
- Only open (live) orders can be amended.
- Triggered stop-loss or take-profit orders can be amended.
- At least one modifiable field (`order_qty`, `display_qty`, `limit_price`, `trigger_price`, `post_only`) must be provided.
- If the amended quantity is less than the already-filled quantity, the order's remaining quantity is cancelled.
- For detailed guidance, refer to the Kraken amend transaction guide.
