# Edit Order (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/editorder

## Overview

The `editOrder` method modifies live order parameters. When successfully modified, the original order is cancelled and a new order is created with the adjusted parameters, returning a new transaction ID. **Note:** The newer `amendOrder` method is recommended as it resolves the caveats listed below and offers additional performance gains.

**Endpoint:** `wss://ws-auth.kraken.com`
**Event:** `editOrder`

## Authentication

**Required.** A valid session token must be provided in the `token` field.

## Request Format

```json
{
  "event": "editOrder",
  "newuserref": "666",
  "oflags": "",
  "orderid": "O26VH7-COEPR-YFYXLK",
  "pair": "XBT/USD",
  "price": "9000",
  "reqid": 3,
  "token": "0000000000000000000000000000000000000000"
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"editOrder"` |
| `token` | string | Yes | Authenticated session token |
| `orderid` | string | No | Original order ID or userref to edit |
| `pair` | string | Yes | Currency pair identifier |
| `volume` | string | Yes | Order volume in base currency |
| `price` | string | No | Dependent on order type - order price |
| `price2` | string | No | Dependent on order type - order secondary price |
| `oflags` | string | No | Comma-delimited list of order flags. `post` = post-only order (available when ordertype = limit) |
| `newuserref` | string | No | User reference ID for new order (should be an integer in quotes) |
| `validate` | boolean | No | Validate inputs only; do not submit order |
| `reqid` | integer | No | Client-originated request identifier echoed in response |

## Response Format

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `event` | string | `"editOrderStatus"` |
| `status` | string | `"ok"` or `"error"` |
| `txid` | string | New Kraken order identifier for the amended order |
| `originaltxid` | string | Kraken order identifier for the original order |
| `descr` | string | Descriptive summary for the amended order |
| `reqid` | integer | Client-originated identifier from request (if provided) |
| `errorMessage` | string | Error description for unsuccessful requests |

## Example Messages

### Request

```json
{
  "event": "editOrder",
  "newuserref": "666",
  "oflags": "",
  "orderid": "O26VH7-COEPR-YFYXLK",
  "pair": "XBT/USD",
  "price": "9000",
  "reqid": 3,
  "token": "0000000000000000000000000000000000000000"
}
```

### Success Response

```json
{
  "descr": "order edited price = 9000.00000000",
  "event": "editOrderStatus",
  "originaltxid": "O65KZW-J4AW3-VFS74A",
  "reqid": 3,
  "status": "ok",
  "txid": "OTI672-HJFAO-XOIPPK"
}
```

## Limitations

- Triggered stop-loss or take-profit orders are **not supported**
- Orders with conditional close terms are **not supported**
- Orders where executed volume exceeds the new supplied volume will be **rejected**
- `cl_ord_id` parameter is **not supported**
- Existing executions remain associated with the original order
- **Queue position is not maintained** (the edited order gets a new position in the book)

## Notes

- **Use `amendOrder` instead.** The `amendOrder` method is the recommended replacement for `editOrder`. It resolves all the caveats listed above and provides additional performance gains, including queue priority preservation.
- Unlike `amendOrder`, `editOrder` works by cancelling the original order and creating a new one, which results in a new transaction ID (`txid`) and loss of queue position.
- The `originaltxid` in the response identifies the cancelled original order.
- The `txid` in the response is the new order's identifier.
- This is a WebSocket v1 method. Kraken recommends migrating to WebSocket v2 for new implementations.
