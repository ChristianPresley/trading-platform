---
name: spec.06.worktree
description: "Spec Phase 6 — Create git worktrees for isolated, parallel implementation"
argument-hint: Path to plan file(s) from Phase 5 (e.g. `.claude/specs/{feature-slug}/05-plan-{NN}.md`)
allowed-tools: Read, Write, Glob, Grep, Bash, AskUserQuestion, TodoWrite, mcp__github__get_issue, mcp__github__update_issue
---

# Spec Phase 6: Worktree

You are setting up isolated git worktrees for the implementation phase. You will analyze the plan for parallelism opportunities and create one or more worktrees.

## Prerequisites

If inputs were not provided as parameters, ask:

```text
Please provide:
1. Path to the plan file (e.g. .claude/specs/{feature-slug}/05-plan-{NN}.md)
2. Feature slug (e.g. {feature-slug})
```

Then wait.

Before proceeding, verify the plan file exists by reading it. If it does not exist, stop and tell the engineer:

```text
The plan file was not found at {path}. Please run Phase 5 first (/spec.05.plan) or provide the correct path.
```

Also verify the `.worktrees/` directory is listed in `.gitignore`. If it is not, tell the engineer:

```text
.worktrees/ is not in .gitignore. Please add it before proceeding to avoid accidentally committing worktree directories.
```

## Process

1. **Read the plan fully**.

2. **Determine the iteration number** — check whether `.claude/specs/{feature-slug}/06-worktree-01.md` already exists. If so, increment.

3. **Analyze the plan phases** for parallelism. Phases can run in parallel if ALL of the following are true:
   - They modify no files in common (even in different methods — the same file counts as shared)
   - Neither phase's output is consumed by the other as input
   - Their test checkpoints are independent

   When in doubt, keep phases sequential. The cost of an unexpected merge conflict is higher than the cost of sequential execution.

   **Dependency matrix** — build this table from the plan before deciding on batches:

   | Phase   | Files modified  |
   |---------|-----------------|
   | Phase 1 | {list files}    |
   | Phase 2 | {list files}    |

   Any two phases that share a file **must** be sequential — do not parallelize them regardless of other factors.

4. **Determine branch names** using the format `{feature-slug}-{batch}-{NN}`:
   - `{feature-slug}` from the plan path
   - `{batch}` is the batch number (01, 02, etc.)
   - `{NN}` is the worktree number within the batch (01, 02, etc.)
   - Example: `tenant-spline-reticulation-01-01`, `tenant-spline-reticulation-01-02`

5. **Present the worktree plan** to the engineer using `AskUserQuestion`:

   Show the proposed batches and branches as context, then offer:
   - Option 1: "Approve and create worktrees (Recommended)" — proceed with creation
   - Option 2: "Merge some parallel work" — reduce parallelism for simpler merging
   - Option 3: "Split into more worktrees" — increase parallelism if engineer sees more independence
   - Option 4: "Help me evaluate the parallelism" — agent explains the dependency analysis before re-asking

   Approval means an explicit affirmative — silence is not approval.

6. **Create worktrees** after confirmation. First, check for existing worktrees from a prior run:

   ```bash
   git worktree list
   ```

   If worktrees for this feature already exist (re-running after a Phase 7 failure), ask the engineer using `AskUserQuestion`:
   - Option 1: **Reuse existing** — continue from where implementation left off (branches unchanged)
   - Option 2: **Reset to main** — discard uncommitted changes and reset branches to latest main
   - Option 3: **Delete and recreate** — full clean slate (all work on those branches is lost)

   Do NOT proceed silently — resetting or deleting discards potentially recoverable work.

   For each worktree being created fresh:

   ```bash
   git worktree add .worktrees/{feature-slug}-{NN} -b {branch-name}
   ```

7. **Write the worktree document** to `.claude/specs/{feature-slug}/06-worktree-{NN}.md`.

8. **Tick off the tracking issue** — read `meta.md`, then update the tracking issue body to mark `- [x] Phase 6: Worktree`. Also append `- Phase 6 (worktree): {NN}` under `## Phase iterations` in `meta.md`.

9. **Confirm** — list the created worktrees with their paths and branches, then show the next command:

   ```sh
   /spec.07.implement .claude/specs/{feature-slug}/05-plan-{NN}.md .claude/specs/{feature-slug}/06-worktree-{NN}.md
   ```

## Output: `.claude/specs/{feature-slug}/06-worktree-{NN}.md`

```markdown
---
phase: 6
iteration: {NN}
generated: {YYYY-MM-DD}
---

# Worktree Plan: {Feature Name}

Plan: .claude/specs/{feature-slug}/05-plan-{NN}.md

## Batch 1 (parallel)

### Worktree 1
- Branch: {branch-name}
- Path: .worktrees/{feature-slug}-01
- Phases: {phase numbers from the plan}
- Can start: immediately

### Worktree 2
- Branch: {branch-name}
- Path: .worktrees/{feature-slug}-02
- Phases: {phase numbers from the plan}
- Can start: immediately (parallel with Worktree 1)

## Batch 2 (after Batch 1 merges)

### Worktree 3
- Branch: {branch-name}
- Path: .worktrees/{feature-slug}-03
- Phases: {phase numbers}
- Can start: after Batch 1 branches are merged into main

## Merge order
1. Merge {branch-1} into main
2. Merge {branch-2} into main (resolve any conflicts)
3. After both are merged, create Worktree 3 from updated main

## Implementation prompt for Phase 7

/spec.07.implement .claude/specs/{feature-slug}/05-plan-{NN}.md .claude/specs/{feature-slug}/06-worktree-{NN}.md
```

## Rules

- **One worktree per parallelizable unit of work** — do not over-parallelize; prefer fewer worktrees over more
- **Always confirm before creating** — worktree creation modifies the git state
- **Use `.worktrees/` as the container directory** — verify it is in `.gitignore` before creating
- **Document the merge order explicitly** — Phase 7 needs this to sequence batch completion correctly
