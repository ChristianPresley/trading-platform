---
name: spec.04.outline
description: "Spec Phase 4 — High-level structured outline: phases, ordering, testing checkpoints, key signatures"
argument-hint: Path to design file from Phase 3 (e.g. `.claude/specs/{feature-slug}/03-design-{NN}.md`)
allowed-tools: Read, Write, Glob, Grep, Bash, AskUserQuestion, TodoWrite, mcp__github__get_issue, mcp__github__update_issue
---

# Spec Phase 4: Outline

You are producing a high-level structured outline — the sprint plan that defines HOW we get to the design. This is ~2 pages. It is NOT the full implementation plan. Think C header files, not C source files.

## Prerequisites

If inputs were not provided as parameters, ask:

```text
Please provide:
1. Path to research document (.claude/specs/{feature-slug}/02-research-{NN}.md)
2. Path to design document (.claude/specs/{feature-slug}/03-design-{NN}.md)
```

Then wait.

Before proceeding, verify both files exist by reading them. If either is missing, stop and tell the engineer which file is missing and which phase produces it.

## Process

1. **Read all inputs fully** before proceeding.

2. **Plan vertical slices** — each phase must deliver an end-to-end testable increment. Do NOT plan horizontal layers (all DB first, then all service, then all API, etc.).

3. **Draft the outline** and present it to the engineer using `AskUserQuestion`:

   Present your proposed phase ordering as the question context, then offer:
   - Option 1: "Approve this ordering (Recommended)" — proceed to write the file
   - Option 2: "Reorder phases" — engineer specifies a new ordering
   - Option 3: "Add / remove phases" — engineer specifies what to add or drop
   - Option 4: "Help me evaluate" — agent explains the rationale for the ordering in depth before re-asking

   Re-present the updated outline after each change until the engineer approves.

4. **Approval** means an explicit affirmative ("yes", "approved", "lgtm", "looks good") — silence is not approval.

5. **Determine the iteration number** — check whether `.claude/specs/{feature-slug}/04-outline-01.md` already exists. If so, find the highest existing number and increment.

6. **Write the outline** to `.claude/specs/{feature-slug}/04-outline-{NN}.md`.

7. **Tick off the tracking issue** — read `meta.md`, then update the tracking issue body to mark `- [x] Phase 4: Outline`. Also append `- Phase 4 (outline): {NN}` under `## Phase iterations` in `meta.md`.

8. **Confirm** — tell the engineer the file was written and show the next command:

   ```sh
   /spec.05.plan .claude/specs/{feature-slug}/04-outline-{NN}.md
   ```

## Vertical slice rule (CRITICAL)

Each phase must touch all the layers needed to make it work end-to-end and independently testable:

```text
WRONG — horizontal:
  Phase 1: all database migrations
  Phase 2: all service layer
  Phase 3: all API endpoints
  Phase 4: all frontend — nothing testable until the very end

RIGHT — vertical:
  Phase 1: mock API + frontend wired up — testable!
  Phase 2: real service layer behind the mock — testable!
  Phase 3: database + wire to service — testable!
  Phase 4: production hardening — testable!
```

## Test checkpoint types

Each phase must have at least one test checkpoint. Acceptable types:

- **Automated** — a runnable command (e.g. `dotnet test`, `npm test -- --filter SplineTests`)
- **Integration** — a command that exercises real dependencies (e.g. `curl` against a locally running service)
- **Manual** — step-by-step instructions for a human to verify (use only if automation is not possible for this phase)

Prefer automated over manual. If a phase can only have a manual checkpoint, note why.

## Output: `.claude/specs/{feature-slug}/04-outline-{NN}.md` (~2 pages)

```markdown
---
phase: 4
iteration: {NN}
generated: {YYYY-MM-DD}
---

# Outline: {Feature Name}

Design: .claude/specs/{feature-slug}/03-design-{NN}.md

## Overview
{2-3 sentence summary of the implementation strategy}

## Phase 1: {Descriptive Name}
**Delivers**: {What is testable at the end of this phase}
**Layers touched**: {e.g. API (mock), Frontend — or DB migration, Service, API}

### Key types / signatures introduced
{Just the interface or function signature, not the implementation}

### Test checkpoint
- Type: {Automated | Integration | Manual}
- {How to verify this phase is working before proceeding}

---

## Phase 2: {Descriptive Name}
**Delivers**: ...
**Layers touched**: ...
**Depends on**: Phase 1

### Key types / signatures introduced
...

### Test checkpoint
- Type: {Automated | Integration | Manual}
- ...

---

{Repeat for each phase}

## Dependencies
- Phase N must complete before Phase M because: {reason}
```

## Rules

- **Signatures only** — no full function bodies, no error handling code, no SQL queries
- **Every phase has a test checkpoint** — no phase is complete without a way to verify it
- **No phase should be untestable** for more than a few hundred lines of code
- **~2 pages is a target, not a hard limit** — if the outline genuinely needs more, flag it as a potential scoping concern before writing
