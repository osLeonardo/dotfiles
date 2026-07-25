---
name: refactor
description: Performs a pure refactor of existing code, with no new feature — focused on infra improvements and structural quality. Use instead of implement-task when the step introduces no new behavior and only reorganizes, cleans up or improves existing code while keeping observable behavior identical.
---

## Quick references

| What I need | What I must read |
|---|---|
| How to refactor safely | `{root}/.claude/docs/knowledge/refactor-patterns.md` |
| Implement code | `{root}/.claude/docs/knowledge/coding-rules.md` |

---

## Overview

This skill replaces `implement-task` in the final stage of the `plan-task` → `spec-task` → `refactor` flow, for pure refactoring steps — typically originating from mapped infra improvements. The full planning flow stays the same; only the implementation stage changes, because `implement-task`'s overhead (aimed at new features) is excessive for a refactor.

The goal of a refactor is always: **map what exists, propose the change, guarantee observable behavior does not change.**

---

## Prerequisites

Check the fields below before starting. For any missing field that cannot be inferred, **stop and ask the user** before continuing.

| Field | Source | If missing |
|---|---|---|
| Refactoring step file | User argument | Show the menu |
| Issue number | Number in the PRD file title | Ask the user |
| Branch type (`Feature` or `Hotfix`) | `Branch type` field in the PRD file | Infer from the matching PRD; if not inferable, ask |
| Execution mode (`AFK` or `HITL`) | `Execution type` field in the step header in the PRD file; a user instruction at invocation takes precedence | Assume HITL |

---

## Step 1 — Select the step

Same behavior as `implement-task`:

```
IF the user specified a step (title, number or PRD file):
  1. Locate the step in `.claude/docs/prd/`
  2. Read the file
  3. IF all blockers have Status: Finished → Step 2
     ELSE → show the menu (blocked steps marked as unavailable)
IF no step identified → show the menu
IF the user's request falls outside the step pattern → show the menu
```

Execute only one step per invocation. Wait for the choice before continuing.

---

## Step 2 — Map what exists

Before proposing any change:

1. Read the affected repositories' documentation, following the same routing as `implement-task`:
   - Find the repo's `single|multi` classification in the Repository Map of the global `CLAUDE.md`
   - **single**: read `CONTEXT.md` and `docs/adr/` at the root
   - **multi**: consult `CONTEXT-MAP.md`, route by the step's domains/anchor entities and read **only** the relevant Contexts
2. Read `refactor-patterns.md` in full (see Quick references)
3. Map the current code in the area to be refactored: structure, responsibilities, existing test coverage
4. Determine whether the area has enough test coverage to guarantee observable behavior during the refactor

IF there is a contradiction between the code and `CONTEXT.md` → surface it to the user before proceeding.

---

## Step 3 — Mark as Implementing

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
7. **Verification** — run all tests (characterization + pre-existing) in the affected repositories
   - IF any fail → observable behavior changed; go back to the refactor and fix it, or, if the behavior change is intentional, stop and tell the user this is no longer a pure refactor

### Gate 2 — Code review

8. Present a summary of what was refactored and confirmation that the characterization tests still pass unchanged
9. Wait for explicit approval

**Only after explicit Gate 2 approval:**
- Change `Status: Implementing` → `Status: Finished` in the selected step's section in the PRD
- List every changed file

---

## Execution modes

| Mode | Behavior |
|---|---|
| **AFK** | Runs autonomously from start to finish |
| **HITL** | Pauses at any decision with more than one reasonable approach |

In **both modes**, you must stop and wait for the user at:
- Removal of an entire file
- Architectural decisions → read `.claude/docs/templates/adr-template.md` and present it to the user
- Installing or updating an external package
- A breaking change to a module's public interface
- Any irreversible action
- Any sign that the proposed change alters observable behavior (it stops being a pure refactor)

---

## Constraints

- One step per invocation
- Do not run any git command
- Never mark a step `Finished` without all tests passing
- Never install or update packages without explicit approval, even in AFK mode
- Never introduce new behavior — any change to observable behavior must be flagged to the user and handled outside this skill's scope
