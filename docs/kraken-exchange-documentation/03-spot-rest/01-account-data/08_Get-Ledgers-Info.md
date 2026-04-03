# Query Ledgers

> Source: https://docs.kraken.com/api/docs/rest-api/get-ledgers-info

## Endpoint

`POST /private/QueryLedgers`

**Base URL:** `https://api.kraken.com/0`

**Full URL:** `https://api.kraken.com/0/private/QueryLedgers`

## Description

Retrieve information about specific ledger entries.

## Authentication

This is a private endpoint and requires authentication.

- **API Key Permissions Required:** Data - Query ledger entries
- **Headers Required:**
  - `API-Key`: Your API key
  - `API-Sign`: Message signature using HMAC-SHA512
  - `Content-Type`: `application/x-www-form-urlencoded`

## Request Parameters

**Content-Type:** `application/x-www-form-urlencoded`

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer (int64) | Yes | Nonce used in construction of `API-Sign` header |
| `id` | string | Yes | Comma delimited list of ledger IDs to query info about (20 maximum) |
| `trades` | boolean | No | Whether or not to include trades related to position in output Default: `False` |
| `rebase_multiplier` | string, nullable | No | Optional parameter for viewing xstocks data.  - `rebased`: Display in terms of underlying equity. - `base`: Display in terms of SPV tokens.  Enum: `['rebased', 'base']` Default: `rebased` |

## Response Fields

**HTTP 200:** Ledgers info retrieved.

| Field | Type | Description |
|-------|------|-------------|
| `result` | object |  |
| `result.ledger_id` | object | Ledger Entry |
| `result.ledger_id.refid` | string | Reference Id of the parent transaction (trade, deposit, withdrawal, etc.) that caused the ledger entry. |
| `result.ledger_id.time` | number | Unix timestamp of ledger |
| `result.ledger_id.type` | string | Type of ledger entry Enum: `['none', 'trade', 'deposit', 'withdrawal', 'transfer', 'margin', 'adjustment', 'rollover', 'spend', 'receive', 'settled', 'credit', 'staking', 'reward', 'dividend', 'sale', 'conversion', 'nfttrade', 'nftcreatorfee', 'nftrebate', 'custodytransfer']` |
| `result.ledger_id.subtype` | string | Additional info relating to the ledger entry type, where applicable |
| `result.ledger_id.aclass` | string | Asset class |
| `result.ledger_id.asset` | string | Asset |
| `result.ledger_id.amount` | string | Transaction amount |
| `result.ledger_id.fee` | string | Transaction fee |
| `result.ledger_id.balance` | string | Resulting balance |
| `error` | array |  |
| `error[]` | string | Kraken API error |

## Example Response

```json
{
  "error": [],
  "result": {
    "L4UESK-KG3EQ-UFO4T5": {
      "refid": "TJKLXF-PGMUI-4NTLXU",
      "time": 1688464484.1787,
      "type": "trade",
      "subtype": "",
      "aclass": "currency",
      "asset": "ZGBP",
      "amount": "-24.5000",
      "fee": "0.0490",
      "balance": "459567.9171"
    }
  }
}
```

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/QueryLedgers" \
  -H "API-Key: YourAPIKey" \
  -H "API-Sign: YourSignature" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "nonce=1616492376594"
```

## Notes

### Note on Staking/Earn Assets

Kraken has begun migrating assets from the legacy Staking system to a new Earn system. The following asset symbol extensions may appear in balances and ledger entries:

| Extension | Description |
|-----------|-------------|
| `.S` | Staked assets (legacy, read-only) |
| `.M` | Opt-in rewards balances (legacy, read-only) |
| `.B` | Balances in new yield-bearing products |
| `.F` | Balances earning automatically in Kraken Rewards |
| `.T` | Tokenized assets |

**Note:** Assets with `.S` and `.M` extensions are read-only. To interact with these balances, use the base asset (e.g., `USDT` to transact with `USDT` and `USDT.F` balances).

- This endpoint uses the `POST` method with form-encoded body parameters.
- The `nonce` parameter is required for all private endpoints and must be an increasing unsigned 64-bit integer.
- Rate limiting applies to this endpoint. Refer to Kraken's rate limit documentation for details.
