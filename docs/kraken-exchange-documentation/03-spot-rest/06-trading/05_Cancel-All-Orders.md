# Cancel All Orders

> Source: https://docs.kraken.com/api/docs/rest-api/cancel-all-orders

## Endpoint
`POST /0/private/CancelAll`

## Description
Cancel all open orders.

## Authentication
Requires a valid API key with one of the following permissions:
- `Orders and trades - Create & modify orders`
- `Orders and trades - Cancel & close orders`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object (present on success). |
| `result.count` | integer | Number of orders cancelled. |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/CancelAll" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "count": 4
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- This cancels all open orders across all trading pairs.
- The `count` field indicates how many orders were actually cancelled.
- If no orders are open, the count will be `0`.
- This endpoint does not affect conditional close orders that are attached to positions.
