# Spot REST Earn

> Source: https://docs.kraken.com/api/docs/guides/spot-rest-earn

## Overview

The earn API allows interacting with all of Kraken's yield generating products. It replaces the old `/staking` part of the API.

The different available earn products are represented by earn strategies, corresponding to the legacy `Staking/Assets`. `Stake`/`Unstake` are replaced by `Allocate`/`Deallocate`.

## Available Endpoints

- **Strategies** - list all earn strategies for which you are eligible or have a balance.
- **Allocations** - lists the balance in your earn account for each strategy. Requires the `Query Funds` API key permission.
- **Allocate/Deallocate** - allocate/deallocate to an earn strategy through an async operation. Requires the `Earn Funds` API key permission.
- **AllocateStatus/DeallocateStatus** - verifies the state of the last allocation/deallocation. Requires the `Earn Funds` or `Query Funds` API key permission.

## Examples

### Determine Which Funds Are Earning Rewards

1. Call `Strategies` to obtain information about the relevant strategy. The `lock_type` field shows whether bonding/unbonding funds are earning yield. The relevant fields are `bonding_rewards`/`unbonding_rewards`.
2. Call `Allocations` for the relevant strategy. From the previous step, for strategies where bonding/unbonding does not earn yield, subtract these balances from `amount_allocated.total` to determine which balances are currently earning.

### Get Allocatable Balance

Call `/0/private/BalanceEx`, subtract `hold_trading` amount. Remaining balance is available for allocation to a strategy.

### Geo Restrictions

Some earn strategies are not available in all geographic regions. `Strategies` will return only strategies available to the caller.
