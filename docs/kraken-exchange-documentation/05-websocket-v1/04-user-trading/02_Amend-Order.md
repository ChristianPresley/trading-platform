# Amend Order (WebSocket v1)

> Source: https://docs.kraken.com/api/docs/websocket-v1/amendorder

## Overview

The `amendOrder` method modifies order parameters in-place without the need to cancel the existing order and create a new one. Key benefits include preserved Kraken/client order identifiers and maintained queue priority where possible.

**Endpoint:** `wss://ws-auth.kraken.com`
**Event:** `amendOrder`

## Authentication

**Required.** A valid session token must be provided in the `token` field.

## Request Format

```json
{
  "event": "amendOrder",
  "token": "AxBH/MuD3MyJWjkiViDd1FLPoinFBC8MHQg0/952jKE",
  "txid": "OB54AL-OBWL7-YOYRZI",
  "volume": "0.011"
}
```

## Request Fields

### Required Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event` | string | Yes | Must be `"amendOrder"` |
| `token` | string | Yes | Authenticated session token |

### Order Identifier (one required)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `txid` | string | Conditional | Kraken order identifier (e.g., `"OFGKYQ-FHPCQ-HUQFEK"`) |
| `cl_ord_id` | string | Conditional | Client order identifier (e.g., `"6d1b345e-2821-40e2-ad83-4ecb18a06876"`) |

### Amendable Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `volume` | string | No | New order quantity in base asset terms |
| `display_volume` | string | No | For iceberg orders only; minimum 1/15 of remaining quantity |
| `limit_price` | string | No | New limit price. Supports relative pricing with `+`/`-` prefix or `%` suffix |
| `trigger_price` | string | No | New trigger price for triggered orders. Supports relative pricing with `+`/`-` prefix or `%` suffix |
| `post_only` | boolean | No | Default `false`. Rejects limit price change if the order cannot post passively |
| `pair` | string | No | Required for non-crypto pairs (e.g., `"TSLAx/USD"`) |
| `deadline` | string (RFC3339) | No | Valid offsets 500ms to 60 seconds; default 5 seconds |
| `reqid` | integer | No | Client-originated request identifier echoed in response |

## Response Format

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `event` | string | `"amendOrderStatus"` |
| `amend_id` | string | Unique Kraken identifier for the amend transaction |
| `txid` | string | Kraken order identifier (if provided in request) |
| `cl_ord_id` | string | Client order identifier (if provided in request) |
| `status` | string | `"ok"` or `"error"` |
| `reqid` | integer | Client-originated identifier from request (if provided) |
| `errorMessage` | string | Error description for unsuccessful requests |

## Example Messages

### Request (Trigger Price Amendment)

```json
{
  "event": "amendOrder",
  "token": "AxBH/MuD3MyJWjkiViDd1FLPoinFBC8MHQg0/952jKE",
  "cl_ord_id": "906bcc85-1866-4b4b-9d0d-880bbcbe7447",
  "trigger_price": "61036.4"
}
```

### Request (Volume Amendment)

```json
{
  "event": "amendOrder",
  "token": "AxBH/MuD3MyJWjkiViDd1FLPoinFBC8MHQg0/952jKE",
  "txid": "OB54AL-OBWL7-YOYRZI",
  "volume": "0.011"
}
```

### Success Response

```json
{
  "amend_id": "TGS4UP-DP6E3-YO3KFN",
  "cl_ord_id": "906bcc85-1866-4b4b-9d0d-880bbcbe7447",
  "event": "amendOrderStatus",
  "status": "ok"
}
```

## Notes

- If the amended quantity is reduced below the existing filled quantity, the remaining quantity is cancelled.
- Relative pricing syntax: `"+2%"` adds 2% to reference price; `"-2%"` subtracts from reference price.
- The `post_only` parameter applies only to `limit_price` changes and rejects the amendment if the order would immediately match.
- Either `txid` or `cl_ord_id` must be provided to identify the order being amended (not both required, but at least one).
- Queue priority is maintained where possible, unlike the older `editOrder` method which cancels and recreates.
- This is a WebSocket v1 method. Kraken recommends migrating to WebSocket v2 for new implementations.
