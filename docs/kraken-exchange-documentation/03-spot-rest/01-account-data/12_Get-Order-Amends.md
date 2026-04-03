# Get Order Amends

> Source: https://docs.kraken.com/api/docs/rest-api/get-order-amends

## Endpoint

`POST /private/OrderAmends`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/OrderAmends`

## Description

Retrieves an audit trail of amend transactions on the specified order. The list is ordered by ascending amend timestamp.

## Authentication

This is a private endpoint and requires authentication.

- **API Key Permissions Required:** Orders and trades - Query open orders & trades
- **Headers Required:**
  - `API-Key`: Your API key
  - `API-Sign`: Message signature using HMAC-SHA512
  - `Content-Type`: `application/x-www-form-urlencoded`

## Request Parameters

**Content-Type:** `application/x-www-form-urlencoded`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer (int64) | Yes | Nonce used in construction of `API-Sign` header |
| `order_id` | string | No | The Kraken order identifier for the amended order. |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** The first entry contains the original order parameters and has amend_type of `original`.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object | The amend transaction history. |
| `result.count` | integer | The total count of new and amend transactions (i.e. includes the original order). |
| `result.amends` | array |  |
| `result.amends[].amend_id` | string | Kraken amend identifier |
| `result.amends[].amend_type` | string | The type of amend transaction:   * &bull; `original`: original order values on order entry.   * &bull; `user`: user requested amendment.   * &bull; `restated`: engine order maintenance amendment.  Enum: `['original', 'user', 'restated']` |
| `result.amends[].order_qty` | string | Order quantity in terms of the base asset. |
| `result.amends[].display_qty` | string | The quantity show in the book for iceberg orders. |
| `result.amends[].remaining_qty` | string | Remaining un-traded quantity on the order. |
| `result.amends[].limit_price` | string | The limit price restriction on the order. |
| `result.amends[].trigger_price` | string | The trigger price on trigger order types. |
| `result.amends[].reason` | string | Description of the reason for this amend. |
| `result.amends[].post_only` | boolean | Indicates if the transaction was restricted from taking liquidity. |
| `result.amends[].timestamp` | integer | The UNIX timestamp for the amend transaction. |

## Example Response

```json
{
  "response": {
    "error": [],
    "result": {
      "amends": [
        {
          "amend_id": "TSUN4B-EX2XN-WQ6GKG",
          "amend_type": "original",
          "order_qty": "0.01000000",
          "remaining_qty": "0.01000000",
          "limit_price": "61032.8",
          "timestamp": 1724158070287557888
        },
        {
          "amend_id": "TF6VAW-VUWMX-6SXTCH",
          "amend_type": "user",
          "order_qty": "0.01000000",
          "remaining_qty": "0.01000000",
          "limit_price": "61032.7",
          "timestamp": 1724158076936755712
        },
        {
          "amend_id": "TUMY4K-E4MPE-CSL2N3",
          "amend_type": "user",
          "order_qty": "0.01000000",
          "remaining_qty": "0.01000000",
          "limit_price": "61032.6",
          "timestamp": 1.72415821487966e+18
        }
      ],
      "count": 3
    }
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/OrderAmends" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
