---
phase: 6
iteration: 01
generated: 2026-04-03
---

# Worktree Plan: SDK GUI + Headless Mode

Plan: .claude/specs/sdk-gui-headless-mode/05-plan-01.md

## Batch 1 (sequential)

### Worktree 1
- Branch: sdk-gui-headless-mode-01-01
- Path: .worktrees/sdk-gui-headless-mode-01
- Phases: 1 (Engine Module Extraction + Candle Pipeline)
- Can start: immediately

## Batch 2 (parallel, after Batch 1 merges)

### Worktree 2
- Branch: sdk-gui-headless-mode-02-01
- Path: .worktrees/sdk-gui-headless-mode-02
- Phases: 2 (Headless Executable)
- Can start: after Batch 1 branch is merged into main

### Worktree 3
- Branch: sdk-gui-headless-mode-02-02
- Path: .worktrees/sdk-gui-headless-mode-03
- Phases: 3 (Renderer Enhancement + Theme System)
- Can start: after Batch 1 branch is merged into main (parallel with Worktree 2)

## Batch 3 (sequential, after Batch 2 merges)

### Worktree 4
- Branch: sdk-gui-headless-mode-03-01
- Path: .worktrees/sdk-gui-headless-mode-04
- Phases: 4 (Candlestick Chart + Layout Restructure), 5 (Sparklines, Depth Visualization + Animations)
- Can start: after Batch 2 branches are merged into main

## Merge order
1. Merge sdk-gui-headless-mode-01-01 into main (Batch 1)
2. Rebase Batch 2 worktrees onto updated main
3. Merge sdk-gui-headless-mode-02-01 into main (Phase 2 — no conflicts expected)
4. Merge sdk-gui-headless-mode-02-02 into main (Phase 3 — no conflicts expected, no shared files with Phase 2)
5. Rebase Batch 3 worktree onto updated main
6. Merge sdk-gui-headless-mode-03-01 into main (Phases 4+5)

## Implementation prompt for Phase 7

```sh
/spec.07.implement .claude/specs/sdk-gui-headless-mode/05-plan-01.md .claude/specs/sdk-gui-headless-mode/06-worktree-01.md
```
