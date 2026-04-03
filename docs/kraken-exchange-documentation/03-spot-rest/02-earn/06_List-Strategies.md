# List Earn Strategies

> Source: https://docs.kraken.com/api/docs/rest-api/list-strategies

## Endpoint
`POST /0/private/Earn/Strategies`

## Description
List available Earn strategies along with their parameters. Results are restricted to strategies available in the user's geographic region.

## Authentication
Requires a valid API key. No specific permission is required beyond a valid key.

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `asset` | string | No | Filter strategies by asset (e.g., `XBT`, `ETH`, `DOT`). If omitted, strategies for all assets are returned. |
| `lock_type` | array of strings | No | Filter by lock type. Allowed values: `flex`, `bonded`, `instant`, `timed`. |
| `cursor` | string | No | Cursor for pagination (not yet implemented; all data returned in first page). |
| `limit` | integer | No | Number of results per page (not yet implemented). |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object. |
| `result.items` | array of objects | Array of earn strategy objects. |
| `result.next_cursor` | string | Cursor for next page (not yet implemented). |

### Strategy Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique strategy ID (e.g., `ESXUM7H-SJHQ6-KOQNNI`). |
| `asset` | string | Asset for this strategy (e.g., `DOT`, `ETH`). |
| `lock_type` | object | Lock type configuration. |
| `lock_type.type` | string | Lock type: `flex`, `bonded`, `instant`, or `timed`. |
| `lock_type.payout_frequency` | integer | Payout frequency in seconds. |
| `lock_type.bonding_period` | integer | Bonding period in seconds (for `bonded` type). |
| `lock_type.bonding_period_variable` | boolean | Whether the bonding period can vary. |
| `lock_type.bonding_rewards` | boolean | Whether rewards accrue during the bonding period. |
| `lock_type.unbonding_period` | integer | Unbonding period in seconds (for `bonded` type). |
| `lock_type.unbonding_period_variable` | boolean | Whether the unbonding period can vary. |
| `lock_type.unbonding_rewards` | boolean | Whether rewards accrue during the unbonding period. |
| `lock_type.exit_queue_period` | integer | Exit queue period in seconds (e.g., for ETH staking). |
| `apr_estimate` | object | APR estimate information. |
| `apr_estimate.low` | string | Low end of APR estimate (as a decimal, e.g., `0.04` for 4%). |
| `apr_estimate.high` | string | High end of APR estimate. |
| `user_min_allocation` | string | Minimum allocation amount for the user. |
| `allocation_fee` | string | Fee charged on allocation (typically `0`). |
| `deallocation_fee` | string | Fee charged on deallocation (typically `0`). |
| `auto_compound` | object | Auto-compound configuration. |
| `auto_compound.type` | string | Auto-compound type: `enabled`, `disabled`, or `optional`. |
| `can_allocate` | boolean | Whether the user is eligible to allocate to this strategy. |
| `can_deallocate` | boolean | Whether the user is eligible to deallocate from this strategy. |
| `allocation_restriction_info` | array of strings | Reasons the user cannot allocate (if `can_allocate` is `false`). |
| `user_cap` | string | Maximum amount the user can allocate to this strategy, or `null` if no cap. |
| `yield_source` | object | Information about the yield source. |
| `yield_source.type` | string | Yield source type (e.g., `staking`, `off_chain`). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/Earn/Strategies" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "items": [
      {
        "id": "ESXUM7H-SJHQ6-KOQNNI",
        "asset": "DOT",
        "lock_type": {
          "type": "bonded",
          "payout_frequency": 604800,
          "bonding_period": 0,
          "bonding_period_variable": false,
          "bonding_rewards": true,
          "unbonding_period": 2419200,
          "unbonding_period_variable": false,
          "unbonding_rewards": false,
          "exit_queue_period": 0
        },
        "apr_estimate": {
          "low": "0.07",
          "high": "0.11"
        },
        "user_min_allocation": "0.01",
        "allocation_fee": "0",
        "deallocation_fee": "0",
        "auto_compound": {
          "type": "enabled"
        },
        "can_allocate": true,
        "can_deallocate": true,
        "allocation_restriction_info": [],
        "yield_source": {
          "type": "staking"
        }
      }
    ],
    "next_cursor": null
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- **Tier Requirements:** Earn products generally require Intermediate verification tier. Users not meeting tier restrictions will have `can_allocate` set to `false` with reasons in `allocation_restriction_info`.
- **Lock Types:**
  - `instant` -- Flexible deallocation with no unbonding period.
  - `bonded` -- Includes a bonding and/or unbonding period before funds become available after deallocation.
  - `flex` -- "Kraken Rewards" on eligible spot balances; account-wide configuration, no explicit allocation needed.
  - `timed` -- Fixed time period lock.
- **Pagination:** Paging is not yet implemented; the endpoint currently returns all data in the first page.
- Strategies are region-specific; available strategies may vary based on the user's geographic location.
