---
name: spec.02.research
description: "Spec Phase 2 — Objective, fact-based codebase research driven by Phase 1 questions"
argument-hint: Path to questions file from Phase 1 (e.g. `.claude/specs/{feature-slug}/01-questions-{NN}.md`).
allowed-tools: Read, Write, Glob, Grep, Bash, Agent, TodoWrite, mcp__github__get_issue, mcp__github__update_issue
---

# Spec Phase 2: Research

You are producing an objective, factual research document about the codebase. You have NO knowledge of what is being built — you only answer the questions you were given. You do NOT suggest implementation approaches.

## CRITICAL RULE

**Do NOT read the original ticket.** You were intentionally given questions without it. This keeps your output purely factual. If the ticket path is mentioned, ignore it.

## Prerequisites

If no questions file path was provided as a parameter, ask:

```text
Please provide the path to the questions file from Phase 1 (e.g. .claude/specs/my-feature/01-questions-01.md).
Do NOT provide the original ticket — this phase runs without it by design.
```

Then wait.

Before proceeding, verify the file exists by reading it. If it does not exist, stop and tell the engineer:

```text
The questions file was not found at {path}. Please run Phase 1 first (/spec.01.questions) or provide the correct path.
```

## Process

1. **Read the questions file fully.** Note the feature slug and all questions.

2. **Decompose** — for each question, identify what needs to be explored (specific files, directories, patterns).

3. **Spawn parallel Explore agents** — use the `Agent` tool to investigate each question concurrently. Launch all agents in a single message (parallel calls). **Agent count guidance**: if there are more than 6 questions, group related questions into pairs and spawn one agent per pair (max 6 agents total) — spawning more than 6 parallel agents produces diminishing returns and can overwhelm context. Use this invocation template for each:

   ```yaml
   subagent_type: "Explore"
   prompt: |
     Research the following question about this codebase:

     QUESTION: {exact question text from the questions file}

     Instructions:
     - Find all relevant files and read the key sections
     - Trace data flows end-to-end where applicable
     - Identify patterns, conventions, and integration points
     - Report FACTS ONLY — file paths, line numbers, function names, data structures, call chains
     - Do NOT suggest implementation approaches or improvements
     - Every claim must include a file:line reference
   ```

   If a question is broad, decompose it into 2–3 targeted sub-questions and spawn one agent per sub-question.

   **Agent isolation**: Agents must not message each other. If an agent's findings touch territory covered by another question, the agent notes this as a coverage gap rather than attempting to answer the other question. After all agents complete, spawn a second round of targeted agents to fill any cross-dependent gaps.

4. **Handle agent failures** — if an agent returns an error or produces no findings:
   - Re-spawn it once with a more targeted prompt
   - If it fails again, note the gap in the research document and flag it to the engineer

5. **Wait for all agents to complete** before synthesizing.

6. **Validate coverage** — verify that every question from Phase 1 has a corresponding section with at least one finding. If any question has no findings, do targeted manual investigation using Grep and Read before proceeding. If a question truly cannot be answered after investigation, tag it `UNCOVERED: {reason}` in the Coverage gaps section. Before writing the output file, report coverage: `{N} of {M} questions covered, {X} gaps`.

7. **Synthesize** — compile findings into the research document. Every statement must be a fact about the current codebase with a file path reference. No opinions, no "we should", no "the best approach".

8. **Determine the iteration number** — check whether `.claude/specs/{feature-slug}/02-research-01.md` already exists. If so, find the highest existing number and increment.

9. **Write the research file** to `.claude/specs/{feature-slug}/02-research-{NN}.md`.

10. **Tick off the tracking issue** — read `meta.md`, then update the tracking issue body to mark `- [x] Phase 2: Research`. Also append `- Phase 2 (research): {NN}` under `## Phase iterations` in `meta.md` (add the section if it doesn't exist).

11. **Confirm** — tell the engineer where the file was written. If any questions had no findings or only partial findings, list them explicitly and ask whether to dig deeper before proceeding. Then show the next command:

    ```sh
    /spec.03.design .claude/specs/{feature-slug}/02-research-{NN}.md
    ```

## Output: `.claude/specs/{feature-slug}/02-research-{NN}.md`

```markdown
---
phase: 2
iteration: {NN}
generated: {YYYY-MM-DD}
---

# Research: {Feature Name}

Questions source: .claude/specs/{feature-slug}/01-questions-{NN}.md

## {Question 1 as a heading}

- {Fact with `file:line` reference}
- {Fact with `file:line` reference}
- {Data flow or pattern observed with `file:line` reference}

## {Question 2 as a heading}

...

## Cross-cutting observations

- {Shared pattern or convention visible across multiple areas, with `file:line`}
- {Integration point between components, with `file:line`}
- {Existing test coverage and patterns in the relevant area, with `file:line`}

## Coverage gaps

- {Any questions with no findings, and why}
```

## What good research contains

- File paths and line numbers for all claims
- Data flow traces through the relevant parts of the system
- Existing patterns and conventions (not evaluations of them)
- Dependencies and integration points
- Current test coverage in the relevant area

## What research must NOT contain

- Opinions ("this is a good/bad pattern")
- Implementation suggestions ("we should add X")
- Anything about what is being built — only what exists today
