# Cancel Order Batch

> Source: https://docs.kraken.com/api/docs/rest-api/cancel-order-batch

## Endpoint
`POST /0/private/CancelOrderBatch`

## Description
Cancel multiple open orders by `txid`, `userref`, or `cl_ord_id`. A maximum of 50 total unique IDs/references can be specified per request.

## Authentication
Requires a valid API key with one of the following permissions:
- `Orders and trades - Create & modify orders`
- `Orders and trades - Cancel & close orders`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `orders` | array of strings | Yes | Array of order identifiers to cancel. Each element can be a `txid`, `userref`, or `cl_ord_id`. Maximum 50 unique identifiers. |
| `cl_ord_id` | array of strings | No | Alternative: array of client order IDs to cancel. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object (present on success). |
| `result.count` | integer | Number of orders cancelled. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/CancelOrderBatch" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&orders[0]=OUF4EM-FRGI2-MQMWZD&orders[1]=OB5VMB-B4U2U-DK2WRW&orders[2]=OQCLML-BW3P3-BUCMWZ"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "count": 3
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EOrder:Unknown order` | One or more specified orders were not found. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Maximum of 50 unique order identifiers per request.
- Supports cancellation by three identifier types: transaction ID (`txid`), user reference (`userref`), or client order ID (`cl_ord_id`).
- When cancelling by `userref`, all open orders with that user reference will be cancelled.
- The `count` in the response indicates the total number of orders successfully cancelled.
- If some orders have already been filled or cancelled, those will be skipped and only actually-open orders will be cancelled.
