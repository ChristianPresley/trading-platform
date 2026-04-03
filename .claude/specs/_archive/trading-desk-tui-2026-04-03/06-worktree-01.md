---
phase: 6
iteration: 01
generated: 2026-04-03
---

# Worktree Plan: Trading Desk TUI Application

Plan: .claude/specs/trading-desk-tui/05-plan-01.md

## Dependency Analysis

All 7 plan phases share `trading/desk/main.zig` (modified in every phase) and `build.zig` (modified in Phase 1). Each phase depends on the output of the previous phase. No parallelism is possible.

| Phase | Files modified |
| --- | --- |
| Phase 1 | `trading/desk/main.zig` (NEW), `build.zig` |
| Phase 2 | `trading/desk/terminal.zig` (NEW), `trading/desk/main.zig` |
| Phase 3 | `trading/desk/layout.zig` (NEW), `trading/desk/renderer.zig` (NEW), `trading/desk/main.zig` |
| Phase 4 | `trading/desk/messages.zig` (NEW), `trading/desk/engine.zig` (NEW), `trading/desk/main.zig` |
| Phase 5 | `trading/desk/synthetic.zig` (NEW), `trading/desk/panels/*.zig` (NEW), `trading/desk/engine.zig`, `trading/desk/main.zig` |
| Phase 6 | `trading/desk/input.zig` (NEW), `trading/desk/panels/order_entry_panel.zig` (NEW), `trading/desk/main.zig` |
| Phase 7 | `.vscode/tasks.json` (NEW), `.vscode/launch.json` (NEW) |

## Batch 1 (sequential — all phases)

### Worktree 1
- Branch: `trading-desk-tui-01-01`
- Path: `.worktrees/trading-desk-tui-01`
- Phases: 1, 2, 3, 4, 5, 6, 7 (all sequential)
- Can start: immediately

## Merge order
1. Complete all 7 phases sequentially in `trading-desk-tui-01-01`
2. Create PR to merge `trading-desk-tui-01-01` into `main`

## Implementation prompt for Phase 7

/spec.07.implement .claude/specs/trading-desk-tui/05-plan-01.md .claude/specs/trading-desk-tui/06-worktree-01.md
