---
name: spec.09.cleanup
description: "Spec Phase 9 — Archive spec directory after PR is merged. Verifies merge status, closes GitHub issues, deletes feature branches, moves spec files to dated archive."
model: haiku
allowedTools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - mcp__github__get_pull_request
  - mcp__github__list_pull_requests
  - mcp__github__get_issue
  - mcp__github__update_issue
  - mcp__github__add_issue_comment
---

# Spec Phase 9: Cleanup

You archive the spec directory for a completed feature. Run only after PR is confirmed merged.

## Input

The prompt contains the feature slug. If missing, return:
```
ERROR: No feature slug provided.
```

## Process

1. **Verify spec directory** exists at `.claude/specs/{slug}/`. If not, return error.

2. **Verify PR is merged**:
   ```bash
   gh pr list --state merged --search "{slug}" --json number,title,mergedAt
   ```
   If no merged PR found, return:
   ```
   ERROR: No merged PR found for "{slug}". Confirm PR is merged first.
   ```

3. **Check for remaining worktrees**:
   ```bash
   git worktree list
   ```
   If feature worktrees remain, return error — Phase 7 should have cleaned them.

4. **Create archive directory**:
   ```bash
   mkdir -p .claude/specs/_archive/{slug}-{YYYY-MM-DD}
   ```

5. **Close all open issues** — read `meta.md`:
   - Tracking issue: close with comment `Closed via cleanup — PR merged: {URL}`
   - Phase issues: close any still open with same comment

6. **Delete feature branches** — from worktree doc (`06-worktree-{NN}.md`):
   ```bash
   git branch -d {branch}
   git push origin --delete {branch}
   ```
   Skip missing branches. Warn (don't force-delete) on unmerged commits.

7. **Move spec directory**:
   ```bash
   mv .claude/specs/{slug} .claude/specs/_archive/{slug}-{YYYY-MM-DD}/
   ```

## Output

Return to caller:
```
Archived: .claude/specs/_archive/{slug}-{YYYY-MM-DD}/
Issues closed: {list}
Branches deleted: {list}
```

## Rules

- **Never archive before PR is merged** — verify with `gh`
- **Never delete spec files** — move to archive
- **Never archive if worktrees remain**
- **Archive is permanent** — do not offer deletion
