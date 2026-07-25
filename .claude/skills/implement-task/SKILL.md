---
name: implement-task
description: Implements the code for a PRD step assigned to the agent. Use whenever the user wants to execute a step, implement something from the step queue, or asks the agent to implement a feature — even if the user does not explicitly mention "step" or the file path.
---

## Quick references

| What I need | What I must read |
|---|---|
| Implement code | `{root}/.claude/docs/knowledge/coding-rules.md` |

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

```
IF the user specified a step (title, number or PRD file):
  1. Locate the step in `.claude/docs/prd/`
  2. Read the file
  3. IF all blockers have Status: Finished → Step 2
     ELSE → show the menu (blocked steps marked as unavailable)
IF no step identified → show the menu
IF the user's request falls outside the step pattern → show the menu
```

**Menu format:**
```
Which step do you want to implement?

[context] <description of the out-of-pattern request>
          → <what the agent plans to do>

[01] <Title>
[02] <Title>

Blocked steps (unavailable):
  [03] <Title> — waiting on step 01
```

Execute only one step per invocation. Wait for the choice before continuing.

---

## Step 2 — Read the repositories' documentation

For each repository in the step's `Affected repositories and layers`:

1. Find the repo's `single|multi` classification in the Repository Map of the global `CLAUDE.md` and route accordingly:
   - **single**: read `CONTEXT.md` and `docs/adr/` at the root
   - **multi**: consult `CONTEXT-MAP.md`, route by the step's domains/anchor entities and read **only** the `docs/contexts/{slug}/CONTEXT.md` and `docs/contexts/{slug}/adr/` of the relevant Contexts (plus the root `docs/adr/` for cross-cutting ADRs)
2. Read the repo's `CLAUDE.md`
   - If it does not exist: create it (lazily), infer the test command from the project type (`package.json`, `*.csproj`, `pyproject.toml`, `go.mod`) and record it in the file

**On-demand re-read trigger (multi repo):** if, during implementation, you run into a domain/entity/file not covered by the already-loaded Contexts, **consult `CONTEXT-MAP.md` and load that Context at that moment** before proceeding — loading is incremental, not a single gate at the start.

IF there is a contradiction between the code and `CONTEXT.md` → surface it to the user before proceeding.

Use the glossary's canonical terms throughout the generated code. In a conflict between the local `CLAUDE.md` and the global rules, the local `CLAUDE.md` wins.

---

## Step 3 — Mark as Implementing

In the PRD file, in the selected step's section, change `Status: Pending` → `Status: Implementing` for the selected step only.

---

## Step 4 — Implement (TDD)

Read `coding-rules.md` in full (see Quick references) before writing a single line.

### Gate 1 — Test cases

1. Propose the test scenarios, including edge cases
2. Wait for explicit approval — do not write any test before that
3. **Red** — write the approved tests
4. **Green** — write the minimum code to make the tests pass
5. **Refactor** — improve the code following `coding-rules.md` without breaking tests
6. **Verification** — run all tests in the affected repositories
   - IF any fail → go back to Refactor

### Gate 2 — Code review

7. Present a summary of what was implemented
8. Wait for explicit approval

**Only after explicit Gate 2 approval:**
- Change `Status: Implementing` → `Status: Finished` in the selected step's section in the PRD
- List every changed file
- Suggest the user invoke the `document-task` skill to generate the issue closeout text / Pull Request body

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

---

## Constraints

- One step per invocation
- Do not run any git command
- Never mark a step `Finished` without all tests passing
- Never install or update packages without explicit approval, even in AFK mode
