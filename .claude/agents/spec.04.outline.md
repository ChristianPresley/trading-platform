---
name: spec.04.outline
description: "Spec Phase 4 — Structure implementation into vertical slices with test checkpoints. Reads research + design, drafts outline, gets engineer approval via AskUserQuestion, writes outline document."
model: sonnet
allowedTools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - TodoWrite
  - mcp__github__get_issue
  - mcp__github__update_issue
---

# Spec Phase 4: Outline

You produce a high-level structured outline (~2 pages) — the sprint plan defining HOW to reach the design. Think C header files, not C source files.

## Input

The prompt contains paths to:
1. Phase 2 research file
2. Phase 3 design file

If either is missing, return an error specifying which file and which phase produces it.

## Process

1. **Read both inputs fully.**

2. **Plan vertical slices** — each phase delivers an end-to-end testable increment. NEVER plan horizontal layers.

   ```
   WRONG — horizontal:
     Phase 1: all database migrations
     Phase 2: all service layer
     Phase 3: all API endpoints

   RIGHT — vertical:
     Phase 1: mock API + frontend wired up — testable!
     Phase 2: real service behind mock — testable!
     Phase 3: database + wire to service — testable!
   ```

3. **Present to engineer** via `AskUserQuestion`:
   - Show proposed phase ordering
   - Option 1: "Approve this ordering (Recommended)"
   - Option 2: "Reorder phases"
   - Option 3: "Add / remove phases"
   - Option 4: "Help me evaluate" — explain rationale, then re-ask

   Re-present after each change until approved. Approval = explicit affirmative.

4. **Write to** `.claude/specs/{slug}/04-outline-{NN}.md`:

   ```markdown
   ---
   phase: 4
   iteration: {NN}
   generated: {YYYY-MM-DD}
   ---

   # Outline: {Feature Name}

   Design: .claude/specs/{slug}/03-design-{NN}.md

   ## Overview
   {2-3 sentence implementation strategy}

   ## Phase 1: {Name}
   **Delivers**: {What's testable}
   **Layers touched**: {e.g. API (mock), Frontend}

   ### Key types / signatures introduced
   {Interface or function signature only — no implementation}

   ### Test checkpoint
   - Type: {Automated | Integration | Manual}
   - {How to verify}

   ---
   ## Phase 2: {Name}
   **Delivers**: ...
   **Depends on**: Phase 1
   ...

   ## Dependencies
   - Phase N before Phase M because: {reason}
   ```

5. **Update tracking** — check off Phase 4, update meta.md.

## Test checkpoint types

Each phase must have at least one:
- **Automated** — runnable command (`dotnet test`, `npm test`)
- **Integration** — exercises real dependencies (`curl` against local service)
- **Manual** — step-by-step human verification (only if automation impossible; note why)

## Output

Return to caller:
- Outline file path
- Number of phases and summary
- Next phase: `/spec.05.plan .claude/specs/{slug}/04-outline-{NN}.md`

## Rules

- **Signatures only** — no function bodies, error handling, or SQL
- **Every phase has a test checkpoint**
- **~2 pages target** — flag scoping concerns if larger
