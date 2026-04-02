---
name: spec.09.cleanup
description: "Spec Phase 9 — Archive spec directory after PR is confirmed merged"
argument-hint: Feature slug (e.g. `tenant-scoped-spline-reticulation`)
allowed-tools: Read, Write, Glob, Grep, Bash, mcp__github__get_pull_request, mcp__github__list_pull_requests, mcp__github__get_issue, mcp__github__update_issue, mcp__github__add_issue_comment
---

# Spec Phase 9: Cleanup

You are archiving the spec directory for a completed feature. Run this only after the PR has been confirmed merged. The spec files are moved to a dated archive so the `.claude/specs/` directory stays clean without losing the design history.

## Prerequisites

If no feature slug was provided as a parameter, ask:

```text
Please provide the feature slug (e.g. tenant-scoped-spline-reticulation).
You can find it in the filename of any spec file under .claude/specs/.
```

Then wait.

## Process

1. **Verify the spec directory exists** at `.claude/specs/{feature-slug}/`. If it does not, stop and tell the engineer.

2. **Verify the PR is merged** before touching anything:

   ```bash
   gh pr list --state merged --search "{feature-slug}" --json number,title,mergedAt
   ```

   If no merged PR is found, tell the engineer:

   ```text
   No merged PR found for slug "{feature-slug}". Please confirm the PR is merged before running cleanup.
   If the PR was merged manually or the slug doesn't match the branch name, provide the PR number and I will verify directly with: gh pr view {number} --json state,mergedAt
   ```

   Do NOT proceed until a merged PR is confirmed.

3. **Check for remaining worktrees**:

   ```bash
   git worktree list
   ```

   If any worktrees for this feature remain, tell the engineer and stop:

   ```text
   These worktrees still exist for {feature-slug}:
   {list}
   Phase 7 should have cleaned these up. Remove them before archiving:
   git worktree remove .worktrees/{name}
   ```

4. **Create the archive directory**:

   ```bash
   mkdir -p .claude/specs/_archive/{feature-slug}-{YYYY-MM-DD}
   ```

   Use today's date.

5. **Verify all issues are closed** — read `meta.md`:

   a. Check the `tracking-issue` number, then call `mcp__github__get_issue`. If `state` is not `"closed"`, close it manually via `mcp__github__update_issue` with `state: "closed"` and add a comment:

      ```text
      Closed via spec.09 cleanup — PR merged: {PR URL}
      ```

   b. Check `## Phase issues` in `meta.md`. For each phase issue number, call `mcp__github__get_issue`. Close any still-open issues with the same comment format.

6. **Delete the feature branches** — read the worktree document (`.claude/specs/{feature-slug}/06-worktree-{NN}.md`) to get each branch name, then delete locally and remotely:

   ```bash
   git branch -d {branch-name}
   git push origin --delete {branch-name}
   ```

   Skip branches that don't exist. If a branch has unmerged commits (not expected at this stage), warn the engineer and skip rather than force-deleting.

7. **Move the spec directory into the archive**:

   ```bash
   mv .claude/specs/{feature-slug} .claude/specs/_archive/{feature-slug}-{YYYY-MM-DD}/
   ```

8. **Confirm** — tell the engineer:

   ```text
   Spec files for {feature-slug} archived to:
   .claude/specs/_archive/{feature-slug}-{YYYY-MM-DD}/

   The design history is preserved. The active .claude/specs/ directory is now clean.
   ```

## Rules

- **Never archive before the PR is merged** — verify with `gh` first
- **Never delete spec files** — move them to the archive; design decisions may be referenced later
- **Never archive if worktrees remain** — worktrees with unmerged changes would be abandoned
- **Archive is permanent** — do not offer to delete the archive directory
