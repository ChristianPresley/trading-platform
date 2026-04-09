---
phase: 6
iteration: 01
generated: 2026-04-04
---

# Worktree Plan: Upgrade to Zig Nightly and Add zcov

Plan: .claude/specs/zig-nightly-and-zcov/05-plan-01.md

## Batch 1 (sequential — all phases share build.zig)

### Worktree 1
- Branch: zig-nightly-and-zcov-01-01
- Path: .worktrees/zig-nightly-and-zcov-01
- Phases: 1, 2, 3, 4 (sequential)
- Can start: immediately

## Merge order
1. Merge zig-nightly-and-zcov-01-01 into main (single merge — all work is on one branch)

## Implementation prompt for Phase 7

```sh
/spec.07.implement .claude/specs/zig-nightly-and-zcov/05-plan-01.md .claude/specs/zig-nightly-and-zcov/06-worktree-01.md
```
