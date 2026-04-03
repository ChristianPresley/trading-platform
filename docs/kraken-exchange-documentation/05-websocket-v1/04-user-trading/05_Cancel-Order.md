# Cancel Order (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/cancelorder

## Overview

The `cancelOrder` method cancels one or more open orders in a single authenticated WebSocket request. For each order in the request, a separate `cancelOrderStatus` response message is returned.

**Endpoint:** `wss://ws-auth.kraken.com`
**Event:** `cancelOrder`

## Authentication

**Required.** A valid session token must be provided in the `token` field.

## Request Format

```json
{
  "event": "cancelOrder",
  "token": "0000000000000000000000000000000000000000",
  "txid": [
    "OGTT3Y-C6I3P-XRI6HX",
    "OGTT3Y-C6I3P-X2I6HX"
  ]
}
```

## Request Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"cancelOrder"` |
| `token` | string | Yes | Authenticated session token |
| `txid` | array of strings | Yes | List of Kraken order IDs or client `order_userref` identifiers to cancel |
| `cl_ord_id` | array of strings | No | List of client `cl_ord_id` identifiers for cancellation |
| `reqid` | integer | No | Client-originated request identifier echoed in response |

## Response Format

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `event` | string | `"cancelOrderStatus"` |
| `status` | string | `"ok"` or `"error"` |
| `reqid` | integer | Client-originated identifier from request (if provided) |
| `errorMessage` | string | Error description for unsuccessful cancellations |

## Example Messages

### Request (Multiple Orders)

```json
{
  "event": "cancelOrder",
  "token": "0000000000000000000000000000000000000000",
  "txid": [
    "OGTT3Y-C6I3P-XRI6HX",
    "OGTT3Y-C6I3P-X2I6HX"
  ]
}
```

### Success Response

```json
{
  "event": "cancelOrderStatus",
  "status": "ok"
}
```

### Error Response

```json
{
  "errorMessage": "EOrder:Unknown order",
  "event": "cancelOrderStatus",
  "status": "error"
}
```

## Notes

- **Batch behavior:** When cancelling multiple orders, a separate `cancelOrderStatus` response is sent for each order. For example, if cancelling orders [A, B, C] and two `"ok"` responses are received along with one `"EOrder: Unknown order"` error, the third order was not cancelled.
- Both `txid` (Kraken order IDs) and `cl_ord_id` (client identifiers) can be used to identify orders for cancellation.
- The `txid` array can contain either Kraken order IDs or user reference IDs.
- This is a WebSocket v1 method. Kraken recommends migrating to WebSocket v2 for new implementations.
