---
name: bug-fix
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent
description: Fixes bugs reported in issues against already-implemented functionality. Use whenever the user wants to fix a bug — even if they describe the problem in their own words, without explicitly mentioning "bug" or the file path.
---

## Quick references

| What I need | What I must read |
|---|---|
| Implement code | `{root}/.claude/docs/knowledge/coding-rules.md` |
| Write or change tests | `{root}/.claude/docs/knowledge/testing-rules.md` |

---

## Overview

This skill is a lean variant of `implement-task`, calibrated for bug fixing — without the overhead of planning a new feature.

When the bug refers to work that has **not been merged yet**, this skill reuses the existing PRD and branch. When the original work has already been merged into `main`, the fix gets its own branch (`feature/<issue>-<slug>` or `hotfix/<issue>-<slug>`), created via `git-process`.

---

## Prerequisites

Check the fields below before starting. For any missing field that cannot be inferred, **stop and ask the user** before continuing.

| Field | Source | If missing |
|---|---|---|
| Bug description | The bug issue's body (see below), or the user in their own words; the user may complement the issue | Ask the user |
| Bug issue number | Provided by the user or obtained via `gh issue list --label bug` | Ask the user — optional, but request it explicitly |
| Originating work | The issue/PRD that introduced the behavior, inferred from the handoff/PRD in context | Ask the user; proceed without it if it genuinely does not exist |
| Corresponding PRD | `.claude/docs/prd/<issue>-*.md` | If not found, ask the user where it is or request its contents |
| Originating work's handoffs (if any) | `.claude/docs/handoffs/<issue>-*` | **Optional** — look for **all** files whose name starts with the originating issue number and **read each one in full** in Step 1. Proceed normally if none exist |

When the bug issue number is known, read it with `gh issue view <number> --json title,body,labels` and use its body as the bug description. Images are not analyzed. If `gh` fails, ask the user for the description.

---

## Step 1 — Recover context

1. Read the originating work's PRD (`.claude/docs/prd/<issue>-*.md`), if it exists
2. Read the originating work's handoffs found in the prerequisites, if any, plus any other the user references
3. Confirm you understand the original functionality the bug relates to before proceeding

---

## Step 2 — Record the bug

Fill in [bug-template.md](../../docs/templates/bug-template.md) with the bug description (and the user's complement, if any), referencing the source issue identified in Step 1.

Save it to `{root}/.claude/docs/bugs/<issue>-<slug>.md` (create the folder if it does not exist).

Present the filled-in artifact to the user before proceeding.

---

## Step 3 — Confirm the scope of the fix

Before implementing anything:

1. Present your reading of the problem and the root cause hypothesis, if already identifiable
2. List the repositories and layers likely to be affected
3. Confirm with the user whether the fix goes on a new branch (original work already merged) or on the existing branch
4. Wait for explicit confirmation of the scope before advancing to the implementation

This does not replace `plan-task` — it is a targeted scope confirmation, proportional to the size of a fix. If during this stage it becomes clear the fix requires broad design decisions (not just a targeted adjustment), signal to the user that the situation may benefit from a `plan-task` session first.

---

## Step 4 — Read the repositories' documentation

For each affected repository identified in Step 3, follow `{root}/.claude/skills/common/read-repo-docs.md`, routing by the bug's domains and entities.

---

## Step 5 — Implement (TDD)

Read `coding-rules.md` and `testing-rules.md` in full (see Quick references) before writing a single line.

### Cycle

1. **Red** — write the regression test that reproduces the described bug and confirm it fails against the current code
2. **Green** — write the minimum code to make the test pass
3. **Refactor** — improve the code following the rules without breaking the tests
4. **Verification (`verify`)** — follow `{root}/.claude/skills/common/verify.md`

There is no upfront approval of test cases: the bug's scope was already confirmed in the previous step.

### Gate — Code review

> **Before presenting the summary**, invoke the `code-reviewer` subagent (`{root}/.claude/agents/code-reviewer.md`) passing: the paths of the bug artifact and of the originating PRD (if any), the list of changed files, the affected repositories and the paths of the applicable pattern docs (`coding-rules.md`, `testing-rules.md` + each stack's `*-patterns.md`). Include its return **in full** in the summary, `BLOCKER` findings first, ending with its `VERDICT:` line — the user decides what becomes a fix. A bug fix is a closed unit, so the review happens here rather than at the end of a PRD.

5. Present a summary of what was fixed, including the identified root cause
6. Wait for explicit approval

**Only after explicit Gate approval:**
- IF there is an originating PRD → record the fix in it as a new step, at the end of `## Steps`, already finished. The PRD remains the record of what was delivered for the issue, and the bug's content lives only in the artifact — do not duplicate it. Follow the template's step structure (`What To Build`, `Affected repositories and layers` and, if any, `Implementation Notes`), with this header:

  ```
  ### Step NN — Bug #<issue>: <short title>

  **Status:** Finished
  **Bug:** #<issue> — see `.claude/docs/bugs/<file>.md` (behavior, root cause, approved fix; do not duplicate here).
  ```
- List every changed file

---

## Execution modes

Follow `{root}/.claude/skills/common/mandatory-stops.md`.

---

## Constraints

Same constraints as `implement-task`:

- Do not run any git command — the `git-process` skill handles that
- Never mark the fix as finished without all tests passing
- Never install or update packages without explicit approval, even in AFK mode
- Do not create a new GitHub issue without the user explicitly asking
