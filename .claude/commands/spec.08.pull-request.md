---
name: spec.08.pull-request
description: "Spec Phase 8 — Create a pull request with title, description, and context from the full pipeline"
argument-hint: Path to implementation log from Phase 7 (e.g. `.claude/specs/{feature-slug}/07-implementation-{NN}.md`)
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite, mcp__github__get_issue, mcp__github__update_issue, mcp__github__add_issue_comment, mcp__github__create_pull_request, mcp__github__get_pull_request, mcp__github__get_pull_request_files, mcp__github__create_pull_request_review
---

# Spec Phase 8: Pull Request

You are creating the pull request for the completed feature. You generate a thorough description that gives reviewers full context — reducing PR review to confirmation, not negotiation.

## Prerequisites

If inputs were not provided as parameters, ask:

```text
Please provide the path to the implementation log: .claude/specs/{feature-slug}/07-implementation-{NN}.md
```

Then wait.

Before proceeding, verify the file exists by reading it. Check that the summary section shows all phases complete and all checkpoints passed. If not, tell the engineer:

```text
The implementation log at {path} shows incomplete or failed phases:
{list of incomplete/failed phases}

Please resolve these in Phase 7 before creating the PR.
```

## Process

1. **Identify the branch**:
   - If working from a single branch (no worktrees), run `git branch --show-current`
   - If the feature used multiple worktrees, read the worktree document to get the full list of branches. Ask the engineer which branch to target for the PR — do not guess

2. **Verify worktrees are cleaned up** — run `git worktree list`. If any worktrees for this feature remain, tell the engineer:

   ```text
   These worktrees were not cleaned up by Phase 7:
   {list}
   Please merge and remove them before creating the PR, or confirm they are intentionally left.
   ```

3. **Gather PR information**:
   - Detect the base branch: `git remote show origin | grep 'HEAD branch'` or default to `main`
   - Diff: `gh pr diff` (if PR exists) or `git diff {base-branch}...HEAD`
   - Commits: `git log {base-branch}..HEAD --oneline`
   - Read `.claude/specs/{feature-slug}/03-design-{NN}.md` — note the key decisions from the "Resolved Design Decisions" table and any notable entries from "Patterns to Avoid"
   - Read `.claude/specs/{feature-slug}/05-plan-{NN}.md` — note the edge cases and any breaking changes per phase
   - Read `.claude/specs/{feature-slug}/07-implementation-{NN}.md` — note checkpoint results and any deviations
   - Read any exception files at `.claude/specs/{feature-slug}/07-exceptions-phase-{N}.md`

   These notes feed the **Implementation Summary** section of the PR description (see output template).

4. **Analyze the diff thoroughly** — understand purpose and impact of every change. Identify:
   - User-facing changes (API, UI, behavior)
   - Internal changes (refactors, new abstractions)
   - Breaking changes or migration requirements

5. **Determine the iteration number** — check whether `.claude/specs/{feature-slug}/08-pull-request-01.md` exists. If so, increment.

6. **Write the PR description** to `.claude/specs/{feature-slug}/08-pull-request-{NN}.md` using the template below.

7. **Check for an existing PR**:
   - `gh pr view --json url,number,title,state 2>/dev/null`
   - If a PR exists: `gh pr edit {number} --body-file .claude/specs/{feature-slug}/08-pull-request-{NN}.md`
   - If no PR exists: `gh pr create --title "{PR Title field from the output file}" --body-file .claude/specs/{feature-slug}/08-pull-request-{NN}.md`
   - If `gh` is not available or not authenticated, write the PR body to the file and tell the engineer to create it manually

8. **Tick off the tracking issue** — read `meta.md`, then update the tracking issue body to mark `- [x] Phase 8: Pull Request`. Add a comment to the tracking issue with the PR URL. Also append `- Phase 8 (pull-request): {NN}` under `## Phase iterations` in `meta.md`.

9. **Confirm** — show the PR URL and remind the engineer that code review is the final quality gate. Note that the tracking issue will auto-close when the PR merges (via `Closes: #N` in the PR body). Once the PR is merged, run cleanup:

   ```sh
   /spec.09.cleanup {feature-slug}
   ```

## Output: `.claude/specs/{feature-slug}/08-pull-request-{NN}.md`

```markdown
---
phase: 8
iteration: {NN}
generated: {YYYY-MM-DD}
---

PR Title: {Imperative phrase, ≤70 characters — e.g. "Add tenant-scoped spline reticulation"}

Closes: #{issue-number} (omit if no linked issue)

## What problem does this solve?
{Describe the ticket/feature being implemented and why it matters}

## User-facing changes
{What the user will see or experience differently — "None" if purely internal}

## Implementation summary

**Key design decisions** (from Phase 3):
- {Decision}: {choice made and why — from the Resolved Design Decisions table}

**Edge cases handled** (from Phase 5):
- {Edge case}: {how it was handled}

**Test checkpoints passed** (from Phase 7):
- Phase {N} — `{checkpoint command}`: passed

## Implementation approach
{Key technical decisions made. Note any deviations from the design and why they were made.}

## Exceptions and deviations
{List any exceptions from Phase 7, or "None"}

## How to verify

### Automated
- [ ] {test command}
- [ ] {lint/type-check command}

### Manual
- [ ] {Step-by-step instructions for a reviewer to verify the feature}

## Breaking changes / migration notes
{Any breaking changes, required migrations, or config changes — or "None"}

## Changelog entry
{One-sentence summary in imperative mood, e.g. "Add tenant-scoped spline reticulation to the processing pipeline"}
```

## Rules

- **Be specific** — "Updated `src/services/spline.ts` to add tenant-scoped reticulation" beats "updated backend"
- **Focus on why, not just what** — reviewers already see the diff
- **Include breaking changes or migration notes prominently** if applicable
- **Do not use `git add -A`** or add unrelated files if running any git commands
- **Do not create the PR if checkpoints failed** — the implementation log must show all phases passed
