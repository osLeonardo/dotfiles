---
name: implement-task
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
description: Implements a PRD step with TDD, from the tests through the code review gate. Use whenever the user wants to execute a step, implement something from the step queue, or asks the agent to implement a new feature — even if the user does not explicitly mention "step" or the file path. To fix a bug, use bug-fix; for a refactor with no new behavior, use refactor; to run several steps in parallel, use agent-implement-prd.
---

## Quick references

| What I need | What I must read |
|---|---|
| Implement code | `{root}/.claude/docs/knowledge/coding-rules.md` |
| Write or change tests | `{root}/.claude/docs/knowledge/testing-rules.md` |

---

## Prerequisites

Check the fields below before starting. For any missing field that cannot be inferred, **stop and ask the user** before continuing.

| Field | Source | If missing |
|---|---|---|
| Step file to implement | User argument | Show the menu |
| Issue number | Number in the PRD file title | Ask the user |
| Branch type (`Feature` or `Hotfix`) | `Branch type` field in the PRD file | Infer from the matching PRD; if not inferable, ask |
| Execution mode (`AFK` or `HITL`) | `Execution type` field in the step header in the PRD file; a user instruction at invocation takes precedence | Assume HITL |
| Session handoffs (if any) | `.claude/docs/handoffs/<issue>-*` | **Optional** — look for **all** files whose name starts with the issue number (pattern `<issue>-*`, e.g. `42-*`) and **read each one in full** before Step 2. Proceed normally if none exist or none are found |

---

## Step 1 — Select the step

Follow `{root}/.claude/skills/common/select-step.md`.

---

## Step 2 — Read the repositories' documentation

First read, in full, every document listed under `## Required reading` in the PRD. Then, for each repository in the step's `Affected repositories and layers`, follow `{root}/.claude/skills/common/read-repo-docs.md`.

IF the repo has no `CLAUDE.md`: create it (lazily), infer the test command from the project type (`package.json`, `*.csproj`, `pyproject.toml`, `go.mod`) and record it in the file.

---

## Step 3 — Mark as Implementing

In the PRD file, in the selected step's section, change `Status: Pending` → `Status: Implementing` for the selected step only.

---

## Step 4 — Implement (TDD)

Read `coding-rules.md` and `testing-rules.md` in full (see Quick references) before writing a single line.

**There is no upfront approval of test cases.** They derive from the criteria listed in the step's `Criteria covered` — defined in the PRD's `## Acceptance Criteria` section and approved along with it. Use `testing-rules.md` to decide what to test, at which boundary, at which level and how many cases.

> In a PRD written before this format (acceptance criteria inside the step itself, no `Criteria covered` field), the step's own `Acceptance Criteria` play this role.

### Cycle

The unit of the cycle is the **acceptance criterion**, not the individual test.

1. **Red** — write the tests for one criterion, at the boundary where the behavior is observable, and confirm they fail
2. **Green** — write the code that satisfies them
3. Repeat 1 and 2 for the next criterion, until all are covered
4. **Clean up** — improve the code following the rules without breaking the tests
5. **Verification (`verify`)** — follow `{root}/.claude/skills/common/verify.md`

How many tests each criterion gets is your call, guided by `testing-rules.md`. The order only guarantees that no test is born after the code it should have driven.

### Gate — Code review

6. Present:
   - a summary of what was implemented
   - the tests written and which criterion (`AC-N.M`) each one covers
   - behaviors found outside the step's scope, if any, kept apart from the rest
   - broad refactors left out of the cycle, if any
7. Wait for explicit approval

**Only after explicit Gate approval:** follow `{root}/.claude/skills/common/close-step.md`. When this is the last step of the PRD, closing includes the independent review by the `code-reviewer`.

---

## Execution modes

Follow `{root}/.claude/skills/common/mandatory-stops.md` — it defines the AFK/HITL behavior and the stops that apply in both modes.

---

## Constraints

- One step per invocation
- Do not run any git command
- Never mark a step `Finished` without all tests passing
- Never install or update packages without explicit approval, even in AFK mode
