---
phase: 6
iteration: 01
generated: 2026-04-04
---

# Worktree Plan: Complete and Extensive Synthetics for Demo Mode

Plan: .claude/specs/demo-mode-synthetics/05-plan-01.md

## Batch 1 (sequential)

### Worktree 1
- Branch: demo-mode-synthetics-01-01
- Path: .worktrees/demo-mode-synthetics-01
- Phases: 1, 2, 3, 4 (sequential)
- Can start: immediately

## Dependency analysis

All 4 phases share `trading/desk/engine.zig`. Phases 1, 3, 4 also share `trading/desk/messages.zig`. Each phase builds on the prior:

| Phase | Files Modified | Depends On |
|-------|---------------|------------|
| Phase 1 | build.zig, synthetic.zig, engine.zig, messages.zig | — |
| Phase 2 | matching_engine.zig (NEW), engine.zig | Phase 1 (8 instruments) |
| Phase 3 | engine.zig, messages.zig | Phase 2 (matching engine, OMS) |
| Phase 4 | engine.zig, messages.zig | Phase 3 (algos for TCA) |

No parallelism possible — single worktree, all phases sequential.

## Merge order
1. After all 4 phases complete in the worktree, merge `demo-mode-synthetics-01-01` into main

## Implementation prompt for Phase 7

```sh
/spec.07.implement .claude/specs/demo-mode-synthetics/05-plan-01.md .claude/specs/demo-mode-synthetics/06-worktree-01.md
```
