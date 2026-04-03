# Edit Order

> Source: https://docs.kraken.com/api/docs/rest-api/edit-order

## Endpoint
`POST /0/private/EditOrder`

## Description
Edit the parameters of a live order. When modified successfully, the original order is cancelled and a new order is created with the adjusted parameters. A new transaction ID is returned. The `AmendOrder` endpoint is recommended over `EditOrder` as it provides better performance and preserves queue priority.

## Authentication
Requires a valid API key with the following permissions:
- `Orders and trades - Create & modify orders`
- `Orders and trades - Cancel & close orders`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `txid` | string | Yes | Transaction ID (order ID) of the order to edit. |
| `pair` | string | Yes | Asset pair (e.g., `XBTUSD`). |
| `userref` | integer | No | New user reference ID (32-bit signed integer). |
| `volume` | string | No | New order quantity in terms of the base asset. |
| `displayvol` | string | No | New iceberg order display quantity. |
| `price` | string | No | New price. |
| `price2` | string | No | New secondary price. |
| `oflags` | string | No | New comma-delimited order flags: `post`, `fcib`, `fciq`, `nompp`, `viqc`. |
| `deadline` | string | No | RFC3339 timestamp after which the edit request will be rejected. |
| `cancel_response` | boolean | No | If `true`, the response will be sent when the cancellation of the original order is confirmed (rather than waiting for the new order to be placed). Default: `false`. |
| `validate` | boolean | No | If `true`, validate inputs only without submitting. Default: `false`. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object (present on success). |
| `result.descr` | object | Order description. |
| `result.descr.order` | string | Human-readable order description. |
| `result.txid` | string | New transaction ID for the edited order. |
| `result.newuserref` | string | New user reference (if changed). |
| `result.olduserref` | string | Original user reference. |
| `result.orders_cancelled` | integer | Number of orders cancelled (should be 1). |
| `result.originaltxid` | string | Transaction ID of the original order that was cancelled. |
| `result.status` | string | Status of the edit operation (e.g., `ok`). |
| `result.volume` | string | Volume of the new order. |
| `result.price` | string | Price of the new order. |
| `result.price2` | string | Secondary price of the new order. |
| `result.error_message` | string | Error message if the edit failed. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/EditOrder" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&txid=OUF4EM-FRGI2-MQMWZD&pair=XBTUSD&volume=2.0&price=28000.0"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "descr": {
      "order": "buy 2.00000000 XBTUSD @ limit 28000.0"
    },
    "txid": "OGTT3Y-C6I3P-XRI6HX",
    "newuserref": "0",
    "olduserref": "0",
    "orders_cancelled": 1,
    "originaltxid": "OUF4EM-FRGI2-MQMWZD",
    "status": "ok",
    "volume": "2.00000000",
    "price": "28000.0",
    "price2": "0"
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EOrder:Unknown order` | The specified order was not found or is not open. |
| `EOrder:Invalid order` | The edited order parameters are invalid. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- **Recommendation:** Use `AmendOrder` instead of `EditOrder` for better performance and queue priority preservation.
- `EditOrder` cancels the original order and creates a new one, resulting in a new transaction ID. Queue position is not preserved.
- Triggered stop-loss or take-profit orders cannot be edited with this endpoint.
- Orders with conditional close terms are not supported for editing.
- If the new volume is less than the already-executed volume, the edit will be rejected.
- Client order ID (`cl_ord_id`) is not supported for identifying orders with this endpoint.
- Existing partial executions remain tied to the original order ID.
- At least one editable field (`volume`, `displayvol`, `price`, `price2`, `oflags`) should be different from the current order.
