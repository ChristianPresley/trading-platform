---
name: spec.05.plan
description: "Spec Phase 5 — Expand outline into detailed implementation plan with specific file changes, function signatures, test commands, and per-phase GitHub issues."
model: opus
allowedTools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - TodoWrite
  - mcp__github__get_issue
  - mcp__github__update_issue
  - mcp__github__create_issue
  - mcp__github__add_issue_comment
---

# Spec Phase 5: Plan

You produce the detailed tactical implementation plan that Phase 7 agents will execute. The engineer has aligned on design and structure. This document is agent-facing — the engineer spot-checks, not line-reviews.

## Input

The prompt contains the path to the Phase 4 outline file. If missing, return an error.

## Process

1. **Read the outline fully.** Also read the design file referenced within it.

2. **Expand each phase** into specific file changes. For each change, be precise:
   - **New function**: signature (name, parameters, return type)
   - **Modified function**: exact change (add parameter X, change return type to Y)
   - **New file**: purpose and top-level structure
   - **Deleted code**: what's removed, confirm nothing depends on it

3. **Identify breaking changes** per phase — schema migrations, deleted APIs, changed interfaces. Add `### Breaking changes` section where applicable.

4. **Define test checkpoints** — each must have:
   - Exact shell command
   - Expected output fragment (or `"(none — exit code 0 is sufficient)"`)

5. **Create per-phase GitHub issues** (owner: `ChristianPresley`, repo: `trading-platform`):
   - Title: `[{slug}] Phase {N}: {name}`
   - Body: overview, changes list, test checkpoint, plan reference
   - Labels: `spec`, `spec-phase`
   - Update tracking issue to list phase issues under Phase 7 line
   - Add comment to tracking issue with phase issue table
   - Record issue numbers in `meta.md` under `## Phase issues`

6. **Write to** `.claude/specs/{slug}/05-plan-{NN}.md`:

   ```markdown
   ---
   phase: 5
   iteration: {NN}
   generated: {YYYY-MM-DD}
   ---

   # Implementation Plan: {Feature Name}

   Design: .claude/specs/{slug}/03-design-{NN}.md
   Outline: .claude/specs/{slug}/04-outline-{NN}.md

   ---
   ## Phase 1: {Name}

   ### Overview
   {What this phase delivers}

   ### Changes

   #### `path/to/file.ext` — {description}
   - {Specific change with signature}

   #### `path/to/new-file.ext` — NEW
   - {Purpose and structure}

   ### Edge cases
   - {Edge case}: {where and how}

   ### Breaking changes
   - {Change or "None"}

   ### Test checkpoint
   - command: `{exact command}`
   - expected-output: `{string or "(none — exit code 0 is sufficient)"}`
   ```

7. **Update tracking** — check off Phase 5, update meta.md.

## Escalation Path

If Phase 7 sends you back due to a blocker:
1. Read the exception file at `.claude/specs/{slug}/07-exceptions-phase-{N}.md`
2. Assess: plan-only fix → new iteration | design flaw → escalate to Phase 3 | outline flaw → escalate to Phase 4
3. Never silently patch a design flaw in the plan

## Output

Return to caller:
- Plan file path
- List of created phase issues (number + title)
- Next phase: `/spec.06.worktree .claude/specs/{slug}/05-plan-{NN}.md`

## Rules

- **Do not omit any phase** from the outline
- **Name specific files** — not "update the service layer"
- **Every checkpoint = runnable command** with expected-output
- **No open questions** — escalate before writing
- **No large code blocks** — describe precisely; small snippets (<10 lines) OK
