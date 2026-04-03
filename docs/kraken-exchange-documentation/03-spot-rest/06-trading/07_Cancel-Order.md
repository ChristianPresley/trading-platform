# Cancel Order

> Source: https://docs.kraken.com/api/docs/rest-api/cancel-order

## Endpoint
`POST /0/private/CancelOrder`

## Description
Cancel a particular open order (or set of open orders) by `txid`, `userref`, or `cl_ord_id`.

## Authentication
Requires a valid API key with one of the following permissions:
- `Orders and trades - Create & modify orders`
- `Orders and trades - Cancel & close orders`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `txid` | string | Conditional | Transaction ID (order ID) of the order to cancel. Can also be a `userref` or `cl_ord_id`. At least one identifier must be provided. |
| `cl_ord_id` | string | Conditional | Client order ID of the order to cancel. Alternative to `txid`. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object (present on success). |
| `result.count` | integer | Number of orders cancelled. |
| `result.pending` | boolean | If `true`, the cancellation is pending (order may not be immediately cancelled). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/CancelOrder" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&txid=OUF4EM-FRGI2-MQMWZD"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "count": 1
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EOrder:Unknown order` | The specified order was not found. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- When cancelling by `userref`, all open orders with that user reference will be cancelled.
- When cancelling by `cl_ord_id`, the specific order with that client order ID will be cancelled.
- The `count` field in the response indicates how many orders were actually cancelled.
- If the order has already been fully filled or previously cancelled, an error will be returned.
- The `txid` field accepts transaction IDs, user reference IDs, or client order IDs.
