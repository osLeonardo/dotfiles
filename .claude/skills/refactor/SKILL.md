---
name: refactor
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
description: Performs a pure refactor of existing code, with no new feature — infra improvements and structural quality, keeping observable behavior identical. Works either from a refactoring step in a PRD (instead of implement-task) or standalone, independent of any issue, with the user pointing at the module, file or area. Use when the user wants to reorganize, clean up, decouple or simplify existing code without changing what it does, even if they don't say "refactor". If the change alters behavior, it belongs to implement-task or bug-fix.
---

## Quick references

| What I need | What I must read |
|---|---|
| How to refactor safely | `{root}/.claude/docs/knowledge/refactor-patterns.md` |
| Implement code | `{root}/.claude/docs/knowledge/coding-rules.md` |
| Assess the existing tests | `{root}/.claude/docs/knowledge/testing-rules.md` |

---

## Overview

The skill has two modes:

- **PRD step** — replaces `implement-task` in the final stage of the `plan-task` → `spec-task` → `refactor` flow, for pure refactoring steps — typically originating from mapped infra improvements. The planning flow stays the same; only the implementation stage changes, because `implement-task`'s overhead (aimed at new features) is excessive for a refactor.
- **Standalone** — ongoing refactoring, independent of any issue or PRD, like `add-test`. The user points at the module, file or area, and the plan approved at Gate 1 plays the role of the step.

In both modes, the goal of a refactor is always: **map what exists, propose the change, guarantee observable behavior does not change.**

---

## Prerequisites

Check the fields below before starting. For any missing field that cannot be inferred, **stop and ask the user** before continuing.

| Field | Mode | Source | If missing |
|---|---|---|---|
| Refactoring step file | PRD step | User argument | Show the menu |
| Issue number | PRD step | Number in the PRD file title | Ask the user |
| Branch type (`Feature` or `Hotfix`) | PRD step | `Branch type` field in the PRD file | Infer from the matching PRD; if not inferable, ask |
| Execution mode (`AFK` or `HITL`) | Both | `Execution type` field in the step header in the PRD file; a user instruction at invocation takes precedence | Assume HITL |
| Session handoffs (if any) | PRD step | `.claude/docs/handoffs/<issue>-*` | **Optional** — look for **all** files whose name starts with the issue number and **read each one in full** in Step 2. Proceed normally if none exist |
| Target module, file or area | Standalone | User | Ask the user |

---

## Step 1 — Identify the mode

- The user pointed at a PRD or a step, or the request matches a pending refactoring step → **PRD step**: follow `{root}/.claude/skills/common/select-step.md`.
- The user pointed at a module, file or area, with no PRD → **Standalone**.
- Unclear → ask which of the two.

---

## Step 2 — Map what exists

Before proposing any change:

1. In PRD step mode, first read, in full, the documents listed under `## Required reading` in the PRD and the issue's handoffs, if any. Then, in both modes, for each affected repository, follow `{root}/.claude/skills/common/read-repo-docs.md`.
2. Read `refactor-patterns.md` in full (see Quick references)
3. Map the current code in the area to be refactored: structure, responsibilities, existing test coverage
4. Determine whether the area has enough test coverage to guarantee observable behavior during the refactor

---

## Step 3 — Mark as Implementing

PRD step mode only. In standalone mode there is no PRD to mark: go to Step 4.

In the PRD file, in the selected step's section, change `Status: Pending` → `Status: Implementing` for the selected step only.

---

## Step 4 — Propose the refactor

### Gate 1 — Refactoring plan

1. Present the mapping from Step 2: what exists today and why it needs to change
2. Propose the refactor: what changes structurally, what stays observable and identical
3. IF the area lacks sufficient test coverage → propose the necessary characterization tests (see `refactor-patterns.md`)
4. Wait for explicit approval — do not change any production code before that

### Execution

5. **If needed** — write the approved characterization tests and confirm they capture the current behavior before any change
6. Perform the refactor per the approved plan, following `coding-rules.md` and `refactor-patterns.md`
7. **Verification (`verify`)** — follow `{root}/.claude/skills/common/verify.md`. The suite covers the characterization tests and the pre-existing ones. In a refactor, a failure that comes from your change means observable behavior changed: go back to the refactor and fix it, or, if the behavior change is intentional, stop and tell the user this is no longer a pure refactor.

### Gate 2 — Code review

In standalone mode, the refactor is a closed unit, so the independent review happens here, as in `bug-fix`. **Before presenting the summary**, invoke the `code-reviewer` subagent (`{root}/.claude/agents/code-reviewer.md`) passing: the plan approved at Gate 1 as the requirement, the list of changed files, the affected repositories and the applicable pattern docs (`coding-rules.md`, `testing-rules.md`, `refactor-patterns.md` and each stack's `*-patterns.md`). Ask it to pay special attention to what must have stayed identical: the observable behavior. Include its return **in full** in the summary, `BLOCKER` findings first, ending with its `VERDICT:` line — the user decides what becomes a fix.

8. Present a summary of what was refactored and confirmation that the characterization tests still pass unchanged
9. Wait for explicit approval

**Only after explicit Gate 2 approval:**

- **PRD step** — follow `{root}/.claude/skills/common/close-step.md`. When this is the last step of the PRD, closing includes the independent review by the `code-reviewer`. In it, include `refactor-patterns.md` among the pattern docs and ask the reviewer to pay special attention to what must have stayed identical: the observable behavior.
- **Standalone** — list every changed file and suggest `git-process`. With no linked issue, the branch follows the no-issue pattern in `git-branch-rules.md` (`feature/<slug>`).

---

## Execution modes

Follow `{root}/.claude/skills/common/mandatory-stops.md`. In a refactor, also stop at any sign that the proposed change alters observable behavior (it stops being a pure refactor).

---

## Constraints

- One step per invocation, in PRD step mode
- Do not run any git command
- Never mark a step `Finished`, nor declare a standalone refactor done, without all tests passing
- Never install or update packages without explicit approval, even in AFK mode
- Never introduce new behavior — any change to observable behavior must be flagged to the user and handled outside this skill's scope
