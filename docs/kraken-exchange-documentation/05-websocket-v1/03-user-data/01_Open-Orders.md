# Open Orders (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/openorders

## Overview

The `openOrders` channel provides real-time streaming of the authenticated user's open orders. An initial snapshot delivers all current open orders, followed by incremental updates for any changes (new orders, fills, cancellations, amendments).

**Endpoint:** `wss://ws-auth.kraken.com`
**Channel Name:** `openOrders`

## Authentication

**Required.** A valid session token must be provided in the subscription request. The token is obtained via the REST API `GetWebSocketsToken` endpoint.

## Subscription Format

```json
{
  "event": "subscribe",
  "subscription": {
    "name": "openOrders",
    "token": "WW91ciBhdXRoZW50aWNhdGlvbiB0b2tlbiBnb2VzIGhlcmUu",
    "ratecounter": true,
    "rebased": true
  }
}
```

## Subscription Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `event` | string | Yes | - | Must be `"subscribe"` |
| `subscription.name` | string | Yes | - | Must be `"openOrders"` |
| `subscription.token` | string | Yes | - | Authentication token for the session |
| `subscription.ratecounter` | boolean | No | `false` | If `true`, includes rate-limit counter in updates |
| `subscription.rebased` | boolean | No | `true` | For xstocks: `true` displays underlying equity, `false` displays SPV tokens |
| `subscription.reqid` | string | No | - | Client-originated request identifier for acknowledgment |

## Response/Update Format

Responses are arrays with three elements:

```
[orders_array, channel_name, feed_detail_object]
```

### Array Elements

| Position | Field | Type | Description |
|----------|-------|------|-------------|
| 0 | `orders_array` | array | Array of order objects keyed by Kraken order ID |
| 1 | `channel_name` | string | Always `"openOrders"` |
| 2 | `feed_detail` | object | Contains `sequence` (integer) for subscription sequencing |

## Order Object Fields

### Core Identifiers

| Field | Type | Description |
|-------|------|-------------|
| `<order-id>` | object key | Kraken order identifier (the key that contains all order data) |
| `refid` | string | Referral order transaction ID that created this order |
| `userref` | integer | Optional numeric identifier associated with one or more orders |
| `cl_ord_id` | string | Optional alphanumeric client identifier |
| `ext_ord_id` | string (UUID) | Optional external partner order identifier |

### Order Status and Timing

| Field | Type | Description |
|-------|------|-------------|
| `status` | string | Status of order (e.g., `open`, `closed`, `canceled`) |
| `opentm` | string | Unix timestamp when order was placed |
| `starttm` | string | Unix timestamp of order start time (if set) |
| `expiretm` | string | Unix timestamp of order end time (if set) |
| `lastupdated` | string | Unix timestamp of last change (for updates) |

### Volume Information

| Field | Type | Condition | Description |
|-------|------|-----------|-------------|
| `vol` | string | - | Volume of order (base currency unless `viqc` set in `oflags`) |
| `vol_exec` | string | - | Total volume executed so far |
| `display_volume` | string | Iceberg orders only | The reload quantity for iceberg order types |
| `display_volume_remain` | string | Iceberg orders only | The visible quantity remaining in the book |

### Cost and Fee Information

| Field | Type | Description |
|-------|------|-------------|
| `cost` | string | Total cost (quote currency unless `viqc` set in `oflags`) |
| `fee` | string | Total fee (quote currency) |
| `avg_price` | string | Average price (cumulative; quote currency unless `viqc` set in `oflags`) |

### Price Information

| Field | Type | Description |
|-------|------|-------------|
| `price` | string | Limit price for limit orders; trigger price for all triggered orders |
| `price2` | string | Limit price for stop-loss-limit, take-profit-limit, and trailing-stop-limit orders |
| `stopprice` | string | Stop price (for trailing stops) |
| `limitprice` | string | Triggered limit price (after limit-based order types are triggered) |

### Order Description Object (`descr`)

| Field | Type | Description |
|-------|------|-------------|
| `descr.pair` | string | Asset pair |
| `descr.position` | string | Optional position ID (if applicable) |
| `descr.type` | string | Side of order: `"buy"` or `"sell"` |
| `descr.ordertype` | string | Order type (e.g., `"limit"`, `"market"`, `"stop-loss"`) |
| `descr.price` | string | Primary price (limit or trigger) |
| `descr.price2` | string | Secondary price |
| `descr.leverage` | string | Amount of margin leverage |
| `descr.margin` | boolean | Indicates if order is funded on margin |
| `descr.order` | string | Text summary of order |
| `descr.close` | string | Text summary of conditional order (if attached) |

### Order Flags and Status

| Field | Type | Description |
|-------|------|-------------|
| `oflags` | string | Comma-delimited list of order flags: `viqc` (volume in quote currency), `fcib` (prefer fee in base currency), `fciq` (prefer fee in quote currency), `nompp` (no market price protection), `post` (post-only order) |
| `misc` | string | Comma-delimited list of miscellaneous info: `stopped` (triggered by stop price), `touched` (triggered by touch price), `liquidation` (liquidation event), `partial` (partial fill) |
| `timeinforce` | string | Time-in-force value. `GTC` (Good Till Canceled - default), `GTD` (Good Till Date - until `expiretm`), `IOC` (Immediate Or Cancel) |

### Conditional Orders

| Field | Type | Condition | Description |
|-------|------|-----------|-------------|
| `contingent` | object | Conditional close attached | Parameters for conditional close order |
| `contingent.ordertype` | string | - | Conditional close order type |
| `contingent.price` | string | - | Primary price of conditional close order |
| `contingent.price2` | string | - | Secondary price of conditional close order |
| `contingent.oflags` | string | - | Comma-delimited order flags for conditional close |

### Amendment and Cancellation Info

| Field | Type | Description |
|-------|------|-------------|
| `cancel_reason` | string | Present for all cancellation updates (`status=canceled`) and some close updates (`status=closed`) |
| `amend_reason` | string | Present for all amend events |
| `amended` | boolean | `true` or `false`. Indicates if the order has been amended; modification history available via REST `OrderAmends` endpoint |

### Institutional and Rate Limiting

| Field | Type | Description |
|-------|------|-------------|
| `sender_sub_id` | string | For institutional accounts, identifies underlying sub-account/trader for Self Trade Prevention (STP) |
| `ratecount` | string | Rate-limit counter, present if `ratecounter: true` in subscription request. See Trading Rate Limits |

## Snapshot vs Update Behavior

**Initial Snapshot:**
- Delivers complete order details for all currently open orders
- All fields are populated with current values
- Multiple orders may appear in a single message

**Subsequent Updates:**
- Only changed fields are included in the update payload
- Status-only changes (e.g., `"closed"`) include only `orderid` and `status`
- Minimal payload for efficiency

## Example Messages

### Subscription Request

```json
{
  "event": "subscribe",
  "subscription": {
    "name": "openOrders",
    "ratecounter": true,
    "token": "WW91ciBhdXRoZW50aWNhdGlvbiB0b2tlbiBnb2VzIGhlcmUu"
  }
}
```

### Snapshot Response (Multiple Orders)

```json
[
  [
    {
      "OGTT3Y-C6I3P-XRI6HX": {
        "avg_price": "34.50000",
        "cost": "0.00000",
        "descr": {
          "close": "",
          "leverage": "0:1",
          "order": "sell 10.00345345 XBT/EUR @ limit 34.50000 with 0:1 leverage",
          "ordertype": "limit",
          "pair": "XBT/EUR",
          "price": "34.50000",
          "price2": "0.00000",
          "type": "sell"
        },
        "expiretm": "0.000000",
        "fee": "0.00000",
        "limitprice": "34.50000",
        "misc": "",
        "oflags": "fcib",
        "opentm": "0.000000",
        "refid": "OKIVMP-5GVZN-Z2D2UA",
        "starttm": "0.000000",
        "status": "open",
        "stopprice": "0.000000",
        "userref": 0,
        "vol": "10.00345345",
        "vol_exec": "0.00000000"
      }
    }
  ],
  "openOrders",
  {
    "sequence": 234
  }
]
```

### Status-Only Update (Closed Order)

```json
[
  [
    {
      "OGTT3Y-C6I3P-XRI6HX": {
        "status": "closed"
      }
    }
  ],
  "openOrders",
  {
    "sequence": 59342
  }
]
```

## Notes

- Authentication is mandatory via a session token obtained from the REST API.
- The initial snapshot provides complete details for all open orders.
- Subsequent updates contain only changed fields for efficiency.
- The `sequence` field in the feed detail object can be used for consistency verification and gap detection.
- The `ratecounter` subscription option enables tracking of trading rate limits.
- The `rebased` parameter only applies to xstocks products.
- This is a WebSocket v1 channel. Kraken recommends migrating to WebSocket v2 for new implementations.
