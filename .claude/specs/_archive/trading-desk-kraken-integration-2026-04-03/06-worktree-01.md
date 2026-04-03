---
phase: 6
iteration: 01
generated: 2026-04-03
---

# Worktree Plan: Professional Trading Desk with Kraken Exchange Integration

Plan: .claude/specs/trading-desk-kraken-integration/05-plan-01.md

## Batch 1 (sequential prerequisite)

### Worktree 1
- Branch: trading-desk-kraken-integration-01-01
- Path: .worktrees/trading-desk-kraken-integration-01-01
- Phases: 1 (Project Skeleton + Core Primitives)
- Can start: immediately

## Batch 2 (after Batch 1 merges — 3 parallel)

### Worktree 2
- Branch: trading-desk-kraken-integration-02-01
- Path: .worktrees/trading-desk-kraken-integration-02-01
- Phases: 2 (I/O + TLS + HTTP + JSON)
- Can start: after Batch 1 merged into main

### Worktree 3
- Branch: trading-desk-kraken-integration-02-02
- Path: .worktrees/trading-desk-kraken-integration-02-02
- Phases: 6 (OMS + Order Types + Pre-Trade Risk + Event Store)
- Can start: after Batch 1 merged into main (parallel with Worktree 2, 4)

### Worktree 4
- Branch: trading-desk-kraken-integration-02-03
- Path: .worktrees/trading-desk-kraken-integration-02-03
- Phases: 9 (Additional Market Data Protocols — SBE, FAST, ITCH, OUCH, PITCH)
- Can start: after Batch 1 merged into main (parallel with Worktree 2, 3)

## Batch 3 (after Batch 2 merges — 3 parallel)

### Worktree 5
- Branch: trading-desk-kraken-integration-03-01
- Path: .worktrees/trading-desk-kraken-integration-03-01
- Phases: 3 (WebSocket + Kraken REST)
- Can start: after Batch 2 merged into main

### Worktree 6
- Branch: trading-desk-kraken-integration-03-02
- Path: .worktrees/trading-desk-kraken-integration-03-02
- Phases: 5 (FIX Protocol + Kraken FIX Connectivity)
- Can start: after Batch 2 merged into main (parallel with Worktree 5, 7)

### Worktree 7
- Branch: trading-desk-kraken-integration-03-03
- Path: .worktrees/trading-desk-kraken-integration-03-03
- Phases: 8 (Position Tracking + P&L + Risk Calculations)
- Can start: after Batch 2 merged into main (parallel with Worktree 5, 6)

## Batch 4 (after Batch 3 merges — 2 parallel)

### Worktree 8
- Branch: trading-desk-kraken-integration-04-01
- Path: .worktrees/trading-desk-kraken-integration-04-01
- Phases: 4 (Kraken WebSocket Streaming + Market Data + Order Book)
- Can start: after Batch 3 merged into main

### Worktree 9
- Branch: trading-desk-kraken-integration-04-02
- Path: .worktrees/trading-desk-kraken-integration-04-02
- Phases: 11 (Post-Trade + Reconciliation + Tick Store)
- Can start: after Batch 3 merged into main (parallel with Worktree 8)

## Batch 5 (after Batch 4 merges — 3 parallel)

### Worktree 10
- Branch: trading-desk-kraken-integration-05-01
- Path: .worktrees/trading-desk-kraken-integration-05-01
- Phases: 7 (Kraken Order Execution End-to-End)
- Can start: after Batch 4 merged into main

### Worktree 11
- Branch: trading-desk-kraken-integration-05-02
- Path: .worktrees/trading-desk-kraken-integration-05-02
- Phases: 10 (Execution Algorithms + Smart Order Routing)
- Can start: after Batch 4 merged into main (parallel with Worktree 10, 12)

### Worktree 12
- Branch: trading-desk-kraken-integration-05-03
- Path: .worktrees/trading-desk-kraken-integration-05-03
- Phases: 12 (Trading Strategies + Analytics)
- Can start: after Batch 4 merged into main (parallel with Worktree 10, 11)

## Dependency analysis

| Plan Phase | Worktree | Batch | Depends on Plan Phases | Files (directories) |
|-----------|----------|-------|----------------------|---------------------|
| 1 | 1 | 1 | None | build.zig, sdk/core/{memory,time,containers,crypto,tests} |
| 2 | 2 | 2 | 1 | sdk/core/io, sdk/protocol/{tls,http,json} |
| 6 | 3 | 2 | 1 | sdk/domain/{oms,order_types,risk/pre_trade}, sdk/core/event_store |
| 9 | 4 | 2 | 1 | sdk/protocol/{itch,sbe,fast,ouch,pitch} |
| 3 | 5 | 3 | 2 | sdk/protocol/websocket, exchanges/kraken/{spot,futures} |
| 5 | 6 | 3 | 2 | sdk/protocol/fix, exchanges/kraken/spot/fix_client |
| 8 | 7 | 3 | 6 | sdk/domain/{positions,risk/{var,greeks,stress,math}} |
| 4 | 8 | 4 | 3 | exchanges/kraken/{spot,futures}/ws_client, sdk/domain/{market_data,orderbook,bar_aggregator} |
| 11 | 9 | 4 | 8 | sdk/domain/{post_trade,tick_store,parquet_writer} |
| 7 | 10 | 5 | 3,4,5,6 | exchanges/kraken/{spot,futures}/executor, exchanges/kraken/common |
| 10 | 11 | 5 | 4,6 | sdk/domain/{algos,sor} |
| 12 | 12 | 5 | 4,6 | trading/{analytics,strategies} |

## Merge order

1. **Batch 1**: Merge `trading-desk-kraken-integration-01-01` into main
2. **Batch 2**: Create worktrees 2-4 from updated main. After all complete:
   - Merge `trading-desk-kraken-integration-02-01` into main
   - Merge `trading-desk-kraken-integration-02-02` into main
   - Merge `trading-desk-kraken-integration-02-03` into main
3. **Batch 3**: Create worktrees 5-7 from updated main. After all complete:
   - Merge `trading-desk-kraken-integration-03-01` into main
   - Merge `trading-desk-kraken-integration-03-02` into main
   - Merge `trading-desk-kraken-integration-03-03` into main
4. **Batch 4**: Create worktrees 8-9 from updated main. After all complete:
   - Merge `trading-desk-kraken-integration-04-01` into main
   - Merge `trading-desk-kraken-integration-04-02` into main
5. **Batch 5**: Create worktrees 10-12 from updated main. After all complete:
   - Merge `trading-desk-kraken-integration-05-01` into main
   - Merge `trading-desk-kraken-integration-05-02` into main
   - Merge `trading-desk-kraken-integration-05-03` into main

## Notes

- `build.zig` is created in Phase 1 with all module roots (`sdk_core`, `sdk_protocol`, `sdk_domain`, `exchanges_kraken`, `trading`) defined upfront. Subsequent phases add files within these module directories without modifying `build.zig`.
- Batch 2-5 worktrees are created dynamically by Phase 7 (implementation) after each prior batch merges, ensuring they branch from the latest main.
- No two phases within any batch modify the same files.

## Implementation prompt for Phase 7

```sh
/spec.07.implement .claude/specs/trading-desk-kraken-integration/05-plan-01.md .claude/specs/trading-desk-kraken-integration/06-worktree-01.md
```
