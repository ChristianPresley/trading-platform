# Spot Client Order Identifiers

> Source: https://docs.kraken.com/api/docs/guides/spot-clordid

## What is cl_ord_id?

The `cl_ord_id` terminology is borrowed from Financial Information eXchange (FIX) protocol. It is a parameter used as a "client order identifier" for tracking and managing transactions.

## Why is cl_ord_id Important?

The identifier enables clients to track orders using their own preferred format. Kraken verifies `cl_ord_id` uniqueness across open orders for each client. This proves particularly valuable when clients need to cancel or modify orders by referencing their own identifiers.

## Comparing Order Identifiers

Kraken supports three distinct identifier types:

| Characteristic | cl_ord_id | Kraken Id | Userref |
|---|---|---|---|
| Format | string | string | number |
| Encoding | UUID, free text | Kraken proprietary | +/- integer |
| Example | `d15708c1-dbb6-465d-b77d-47258319cc90` | `OCNNCT-MEB2I-2XGM7L` | `123948576` |
| Enforced Uniqueness | Open orders per client | Open and closed orders | None |
| Assigned By | Client | Kraken | Client |

**Important Note:** The `cl_ord_id` and `userref` are mutually exclusive -- they cannot both be used on the same order.

## Format and Performance

The system supports three format options:

| Format | Description | Example |
|---|---|---|
| Long UUID | 32 hex characters with 4 dashes | `6d1b345e-2821-40e2-ad83-4ecb18a06876` |
| Short UUID | 32 hex characters without dashes | `da8e4ad59b78481c93e589746b0cf91f` |
| Free text | ASCII text up to 18 characters | `meme-20240509-00010` |

Under the covers, the strings are stored as a 128-bit integer for efficiency and performance.

## Example: Order Management with UUID

**Creating an order:**

```json
{
    "method": "add_order",
    "params": {
        "order_type": "limit",
        "side": "buy",
        "limit_price": 60299.9,
        "order_qty": 1.0,
        "symbol": "BTC/USD",
        "cl_ord_id": "0835958d-c526-4ad8-aea8-af54836de47e"
    }
}
```

**Canceling an order:**

```json
{
    "method": "cancel_order",
    "params": {
        "cl_ord_id": [
            "0835958d-c526-4ad8-aea8-af54836de47e"
        ]
    }
}
```

## FIX Protocol Guidelines

In FIX protocol, ClOrdID and OrigClOrdID (Tags 11 and 41) support the formats described above, extending beyond traditional INT32 limitations.

### Timestamp-First v4 UUIDs

These identifiers start with a timestamp, ensuring that each generated UUID is unique and sequential based on the time of creation.

### Implementation Guidelines

For FIX API efficiency, clients should send ClOrdID as either:

- **Ever-Increasing Positive Numbers** (such as `1623448294234000` using microsecond timestamps)
- **Timestamp-First v4 UUIDs** (example: `1b4e28ba-2fa1-11d2-883f-0016d3cca427`)
