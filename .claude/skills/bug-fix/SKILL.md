---
name: bug-fix
description: Fixes bugs reported in issues against already-implemented functionality. Use whenever the user wants to fix a bug — even if they describe the problem in their own words, without explicitly mentioning "bug" or the file path.
---

## Quick references

| What I need | What I must read |
|---|---|
| Implement code | `{root}/.claude/docs/knowledge/coding-rules.md` |

---

## Overview

This skill is a lean variant of `implement-task`, calibrated for bug fixing — without the overhead of planning a new feature.

When the bug refers to work that has **not been merged yet**, this skill reuses the existing PRD and branch. When the original work has already been merged into `main`, the fix gets its own branch (`feature/<issue>-<slug>` or `hotfix/<issue>-<slug>`), created via `git-process`.

---

## Prerequisites

Check the fields below before starting. For any missing field that cannot be inferred, **stop and ask the user** before continuing.

| Field | Source | If missing |
|---|---|---|
| Bug description | The user, in their own words | Ask the user |
| Bug issue number | Provided by the user or obtained via `gh issue list --label bug` | Ask the user — optional, but request it explicitly |
| Originating work | The issue/PRD that introduced the behavior, inferred from the handoff/PRD in context | Ask the user; proceed without it if it genuinely does not exist |
| Corresponding PRD | `.claude/docs/prd/<issue>-*.md` | If not found, ask the user where it is or request its contents |
| Original session's handoff (if any) | `.claude/docs/handoffs/` | Optional — proceed without it if it does not exist or is not found |

---

## Step 1 — Recover context

1. Read the originating work's PRD (`.claude/docs/prd/<issue>-*.md`), if it exists
2. IF the user references, or there exists, a handoff from the original session → read it too
3. Confirm you understand the original functionality the bug relates to before proceeding

---

## Step 2 — Record the bug

Fill in [bug-template.md](../../docs/templates/bug-template.md) with the description provided by the user, referencing the source issue identified in Step 1.

Save it to `{root}/.claude/docs/bugs/<issue>-<slug>.md` (create the folder if it does not exist).

Present the filled-in artifact to the user before proceeding.

---

## Step 3 — Confirm the scope of the fix

Before implementing anything:

1. Present your reading of the problem and the root cause hypothesis, if already identifiable
2. List the repositories and layers likely to be affected
3. Confirm with the user whether the fix goes on a new branch (original work already merged) or on the existing branch
4. Wait for explicit confirmation of the scope before advancing to Gate 1

This does not replace `plan-task` — it is a targeted scope confirmation, proportional to the size of a fix. If during this stage it becomes clear the fix requires broad design decisions (not just a targeted adjustment), signal to the user that the situation may benefit from a `plan-task` session first.

---

## Step 4 — Read the repositories' documentation

For each affected repository identified in Step 3, follow the same routing as `implement-task`:

1. Find the repo's `single|multi` classification in the Repository Map of the global `CLAUDE.md` and route accordingly:
   - **single**: read `CONTEXT.md` and `docs/adr/` at the root
   - **multi**: consult `CONTEXT-MAP.md`, route by the bug's domains/anchor entities and read **only** the `docs/contexts/{slug}/CONTEXT.md` and `docs/contexts/{slug}/adr/` of the relevant Contexts (plus the root `docs/adr/` for cross-cutting ADRs)
2. Read the repo's `CLAUDE.md`

IF there is a contradiction between the code and `CONTEXT.md` → surface it to the user before proceeding.

---

## Step 5 — Implement (TDD)

Read `coding-rules.md` in full (see Quick references) before writing a single line.

### Gate 1 — Test cases

1. Propose the test scenarios — you must include a regression test that reproduces the described bug
2. Wait for explicit approval — do not write any test before that
3. **Red** — write the approved tests, confirm the regression test fails against the current code
4. **Green** — write the minimum code to make the tests pass
5. **Refactor** — improve the code following `coding-rules.md` without breaking tests
6. **Verification** — run all tests in the affected repositories
   - IF any fail → go back to Refactor

### Gate 2 — Code review

7. Present a summary of what was fixed, including the identified root cause
8. Wait for explicit approval

**Only after explicit Gate 2 approval:**
- Update the originating PRD with what was done (a new entry referencing the bug artifact — do not duplicate the artifact's content in the PRD)
- List every changed file

---

## Constraints

Same constraints as `implement-task`:

- Do not run any git command — the `git-process` skill handles that
- Never mark the fix as finished without all tests passing
- Never install or update packages without explicit approval, even in AFK mode
- Do not create a new GitHub issue without the user explicitly asking
