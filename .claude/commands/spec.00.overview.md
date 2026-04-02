---
name: spec.00.overview
description: "Spec Pipeline — Overview of all 8 phases and how to invoke them in sequence. Use when the user wants to understand the spec pipeline, see the phase map, or get guidance on which phase to run next."
argument-hint: Optional feature description to get phase-specific guidance.
allowed-tools: Read, Glob
---

# Spec Pipeline: Overview

The spec pipeline is an 8-phase structured workflow for taking a feature from raw idea to merged pull request. Each phase produces a versioned artifact that feeds the next. Phases are designed to be re-runnable: each writes to a new numbered iteration so prior work is never overwritten.

## When to use this pipeline

Use the pipeline if **any** of these are true:

- The feature touches more than 2 files or subsystems
- There is design ambiguity that needs alignment before coding
- Independent implementation phases could run in parallel
- You need codebase understanding before touching anything
- The PR needs to give reviewers full context without a walkthrough

**If none apply** (< 1 day, 1–2 files, clear design) — skip the pipeline and implement directly.

## Phase Map

```text
/spec.01.questions   →  Research query plan
/spec.02.research    →  Factual codebase findings
/spec.03.design      →  Interactive design alignment
/spec.04.outline     →  Vertical slice structure + test checkpoints
/spec.05.plan        →  Detailed per-file implementation steps
/spec.06.worktree    →  Isolated git worktrees for parallel work
/spec.07.implement   →  Autonomous parallel implementation + auto-merge
/spec.08.pull-request → PR description + gh pr create
/spec.09.cleanup     →  Archive spec directory after PR merges
```

## Phase-by-phase guide

### Phase 1 — Questions (`/spec.01.questions`)

**Input**: Issue or feature description (paste it directly or provide a file path)
**Output**: `.claude/specs/{feature-slug}/01-questions-{NN}.md`
**Purpose**: Generates targeted research questions that a researcher answers without knowing what is being built. Keeps research objective.

### Phase 2 — Research (`/spec.02.research`)

**Input**: Path to Phase 1 questions file
**Output**: `.claude/specs/{feature-slug}/02-research-{NN}.md`
**Purpose**: Spawns parallel Explore agents to answer each question with codebase facts (file paths, line numbers, call chains). No opinions or suggestions.

### Phase 3 — Design (`/spec.03.design`)

**Input**: Path to Phase 2 research file
**Output**: `.claude/specs/{feature-slug}/03-design-{NN}.md`
**Purpose**: Interactive design discussion. Agent surfaces options and trade-offs; engineer makes decisions. Document is written only after explicit approval.

### Phase 4 — Outline (`/spec.04.outline`)

**Input**: Paths to Phase 2 research + Phase 3 design files
**Output**: `.claude/specs/{feature-slug}/04-outline-{NN}.md`
**Purpose**: Structures implementation into vertical slices — each phase delivers an end-to-end testable increment. Defines test checkpoint types per phase.

### Phase 5 — Plan (`/spec.05.plan`)

**Input**: Path to Phase 4 outline file
**Output**: `.claude/specs/{feature-slug}/05-plan-{NN}.md`
**Purpose**: Expands each outline phase into specific file changes with exact function signatures, modifications, and runnable test commands with expected output.

### Phase 6 — Worktree (`/spec.06.worktree`)

**Input**: Path to Phase 5 plan file + feature slug
**Output**: `.claude/specs/{feature-slug}/06-worktree-{NN}.md` + git worktrees under `.worktrees/`
**Purpose**: Analyzes the plan for parallelism and creates isolated git worktrees for independent phases. Confirms with engineer before modifying git state.

### Phase 7 — Implement (`/spec.07.implement`)

**Input**: Paths to Phase 5 plan + Phase 6 worktree files
**Output**: `.claude/specs/{feature-slug}/07-implementation-{NN}.md`
**Purpose**: Fully autonomous orchestration. Spawns `bypassPermissions` sub-agents per worktree, enforces checkpoints with up to 3 auto-recovery attempts, auto-merges batches, and cleans up worktrees. Only escalates genuine blockers.

### Phase 8 — Pull Request (`/spec.08.pull-request`)

**Input**: Path to Phase 7 implementation log
**Output**: `.claude/specs/{feature-slug}/08-pull-request-{NN}.md` + GitHub PR
**Purpose**: Reads the full pipeline (design → implementation log) to produce a thorough PR description. Creates or updates the PR via `gh`.

### Phase 9 — Cleanup (`/spec.09.cleanup`)

**Input**: Feature slug
**Purpose**: Verifies the PR is merged, then archives the spec directory. Run this after the PR is confirmed merged to keep the repo tidy.

## Spec directory structure

```text
.claude/specs/{feature-slug}/
  01-questions-{NN}.md
  02-research-{NN}.md
  03-design-{NN}.md
  04-outline-{NN}.md
  05-plan-{NN}.md
  06-worktree-{NN}.md
  07-implementation-{NN}.md
  07-exceptions-phase-{N}.md   ← written on escalation
  08-pull-request-{NN}.md
```

## Re-running a phase

Each phase checks for existing iterations and increments. To re-run Phase 3 after the engineer changes their mind:

```sh
/spec.03.design .claude/specs/{feature-slug}/02-research-01.md
```

This writes `03-design-02.md` — the original is preserved.

## Iteration vs. starting over

- **Iterate** (same slug, new iteration number): design changed, plan updated, new blocker found
- **Start over** (new slug): the feature scope fundamentally changed — derive a new slug in Phase 1

## Prerequisites checklist

Before running Phase 6, verify `.worktrees/` is in `.gitignore`. Before running Phase 7, verify `gh` is installed and authenticated (`gh auth status`).
