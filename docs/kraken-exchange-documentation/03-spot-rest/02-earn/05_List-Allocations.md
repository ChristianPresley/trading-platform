# List Earn Allocations

> Source: https://docs.kraken.com/api/docs/rest-api/list-allocations

## Endpoint
`POST /0/private/Earn/Allocations`

## Description
List all current Earn allocations for the user. The response includes fund state information (bonding, allocated, exit_queue, unbonding), next reward payment timing, and total balances by state. Results can be filtered to hide zero-balance entries and converted to a preferred currency denomination.

## Authentication
Requires a valid API key with the following permission:
- `Query Funds`

## Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `nonce` | integer | Yes | Nonce used in authentication. A unique, always-increasing unsigned 64-bit integer. |
| `ascending` | boolean | No | Sort allocations in ascending order. Default: `false` (descending). |
| `converted_asset` | string | No | Denomination currency for the `converted` values (e.g., `USD`, `EUR`). If omitted, converted values are not included. |
| `hide_zero_allocations` | boolean | No | If `true`, hide strategies with zero allocations. Default: `false` (show all, including historical zero-balance allocations). |

## Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `error` | array of strings | Array of error messages. Empty if no errors. |
| `result` | object | Result object. |
| `result.items` | array of objects | Array of allocation objects. |
| `result.converted_asset` | string | The denomination currency (if `converted_asset` was specified). |
| `result.total_allocated` | string | Total allocated amount across all strategies. |
| `result.total_rewarded` | string | Total rewards earned across all strategies. |

### Allocation Object Fields

| Field | Type | Description |
|-------|------|-------------|
| `strategy_id` | string | The earn strategy ID. |
| `native_asset` | string | The native asset of the strategy (e.g., `ETH`, `DOT`). |
| `amount_allocated` | object | Breakdown of allocated amounts by state. |
| `amount_allocated.bonding` | object | Amount currently in the bonding phase. |
| `amount_allocated.bonding.native` | string | Amount in native asset units. |
| `amount_allocated.bonding.converted` | string | Amount in converted currency (if requested). |
| `amount_allocated.bonding.allocation_count` | integer | Number of separate allocations in this state. |
| `amount_allocated.bonding.allocations` | array of objects | Individual allocation entries. |
| `amount_allocated.allocated` | object | Amount fully allocated and earning rewards. |
| `amount_allocated.allocated.native` | string | Amount in native asset units. |
| `amount_allocated.allocated.converted` | string | Amount in converted currency. |
| `amount_allocated.allocated.allocation_count` | integer | Number of separate allocations. |
| `amount_allocated.allocated.allocations` | array of objects | Individual allocation entries. |
| `amount_allocated.exit_queue` | object | Amount in the exit queue (e.g., ETH unstaking). |
| `amount_allocated.exit_queue.native` | string | Amount in native asset units. |
| `amount_allocated.exit_queue.converted` | string | Amount in converted currency. |
| `amount_allocated.exit_queue.allocation_count` | integer | Number of separate allocations. |
| `amount_allocated.unbonding` | object | Amount currently in the unbonding phase. |
| `amount_allocated.unbonding.native` | string | Amount in native asset units. |
| `amount_allocated.unbonding.converted` | string | Amount in converted currency. |
| `amount_allocated.unbonding.allocation_count` | integer | Number of separate allocations. |
| `amount_allocated.total` | object | Total amount across all states. |
| `amount_allocated.total.native` | string | Total amount in native asset units. |
| `amount_allocated.total.converted` | string | Total amount in converted currency. |
| `total_rewarded` | object | Total rewards earned for this strategy. |
| `total_rewarded.native` | string | Rewards in native asset units. |
| `total_rewarded.converted` | string | Rewards in converted currency. |
| `payout_period` | object | Information about the next reward payout. |
| `payout_period.estimated_reward` | object | Estimated next reward amount. |
| `payout_period.estimated_reward.native` | string | Estimated reward in native asset units. |
| `payout_period.estimated_reward.converted` | string | Estimated reward in converted currency. |
| `payout_period.period_start` | string | RFC3339 timestamp of the current payout period start. |
| `payout_period.period_end` | string | RFC3339 timestamp of the current payout period end. |
| `pending` | object | Pending allocation/deallocation amounts (if any operation is in progress). |

## Example Request

```bash
curl -X POST "https://api.kraken.com/0/private/Earn/Allocations" \
  -H "API-Key: YOUR_API_KEY" \
  -H "API-Sign: YOUR_API_SIGN" \
  -d "nonce=1616492376594&hide_zero_allocations=true&converted_asset=USD"
```

## Example Response

```json
{
  "error": [],
  "result": {
    "converted_asset": "ZUSD",
    "items": [
      {
        "strategy_id": "ESXUM7H-SJHQ6-KOQNNI",
        "native_asset": "DOT",
        "amount_allocated": {
          "bonding": {
            "native": "0.0000000000",
            "converted": "0.0000",
            "allocation_count": 0,
            "allocations": []
          },
          "allocated": {
            "native": "100.0000000000",
            "converted": "650.0000",
            "allocation_count": 1,
            "allocations": [
              {
                "native": "100.0000000000",
                "converted": "650.0000"
              }
            ]
          },
          "exit_queue": {
            "native": "0.0000000000",
            "converted": "0.0000",
            "allocation_count": 0
          },
          "unbonding": {
            "native": "0.0000000000",
            "converted": "0.0000",
            "allocation_count": 0
          },
          "total": {
            "native": "100.0000000000",
            "converted": "650.0000"
          }
        },
        "total_rewarded": {
          "native": "2.5000000000",
          "converted": "16.2500"
        },
        "payout_period": {
          "estimated_reward": {
            "native": "0.1500000000",
            "converted": "0.9750"
          },
          "period_start": "2024-01-01T00:00:00Z",
          "period_end": "2024-01-08T00:00:00Z"
        }
      }
    ],
    "total_allocated": "650.0000",
    "total_rewarded": "16.2500"
  }
}
```

## Error Codes

| Error | Description |
|-------|-------------|
| `EGeneral:Invalid arguments` | Invalid or missing required parameters. |
| `EGeneral:Permission denied` | API key does not have the required permission. |
| `EAPI:Invalid nonce` | Nonce is not valid. |

## Notes

- Bonding/unbonding periods may or may not yield rewards depending on the strategy configuration (see `bonding_rewards` and `unbonding_rewards` in strategy details).
- ETH in the `exit_queue` state continues earning rewards.
- (Un)bonding time estimates improve 1-2 minutes after allocation changes as the system recalculates.
- No pagination is currently implemented; all results are returned in a single response.
- Zero-balance historical allocations are shown by default. Use `hide_zero_allocations=true` to filter them out.
- The `pending` field reflects any in-progress allocation or deallocation operations.
