# <IssueNumber> - <Title>

**Date:** YYYY-MM-DD
**Branch type:** Feature | Hotfix
**Status:** Draft

---

## Problem

<Description of the problem from the user's point of view. What hurts? What friction exists today? Be specific — avoid generalities like "improve the experience".>

## Solution

<Description of the proposed solution from the user's point of view. What changes? How will the new experience differ from the current one?>

## User Stories

Numbered and thorough list. Cover every relevant actor and scenario.

1. **US-1** — As a <actor>, I want <functionality>, so that <benefit>

## Acceptance Criteria

The issue's contract: it is what the user approves along with the PRD and what the end-of-PRD `code-reviewer` checks, criterion by criterion.

### US-1 — <short story title>

- **AC-1.1** — **Given** <initial state with concrete values>, **when** <action>, **then** <observable result>.
- **AC-1.2** — **Given** ..., **when** ..., **then** ...

Rules for this section:
- One criterion per observable behavior, with concrete values.
- Cover the happy path, edge cases and error path of each story. An edge case or error that does not apply is omitted, not invented.
- **Not acceptance criteria:** build, lint and test suite passing (a precondition of every unit, checked by `verify`); implementation constraints such as "reuse the existing utility" (they go in `## Implementation Decisions` and are checked by the `code-reviewer`).
- IDs are never reused: a removed criterion disappears from the list, and its number does not come back.

## Implementation Decisions

Technical decisions made during the conversation, organized by category:

### Interfaces and Contracts
- Contracts between modules (no file paths)
- API endpoints and data formats

### Architectural Decisions
- Design choices, adopted patterns and their reasons — **only those that did not become an ADR**
- Constraints the code must respect without being observable behavior (e.g. reuse an existing component instead of creating another)
- The paths of the ADRs, created in this session or pre-existing, go in `## Required reading`

### Schema Changes
- Changes to the database or data models

> Avoid specific file paths or code snippets — they go stale fast.
> Exception: if a prototype produced a snippet that encodes a decision better than prose can
> (a state machine, a reducer, a schema, a type shape), include it here with a note that it came
> from a prototype. Trim it to the essentials — not a working demo, just the decision-rich bits.

## Out of Scope

What explicitly is **not** part of this issue.

## Additional Notes

Relevant extra context, identified risks, external dependencies.

## Required reading

Documents the agent must load **before** implementing any step. Includes what was produced in
this session and what already existed and constrains the implementation.

| Document | Why |
|---|---|
| `<path relative to {root}>` | <created in this session / pre-existing — what it determines> |

Rules for this section:
- Paths relative to `{root}`, one per row. **Never** copy the document's content here — content
  goes stale, the path does not.
- A relevant pre-existing ADR carries the same weight as one created now.
- Included: ADRs, the `CONTEXT.md` of the Contexts touched, the session's handoffs, pattern docs
  that apply only to this issue.
- If nothing applies, write `None` — do not leave the table with the example row.

---

## Steps

Each step is a **tracer bullet** (vertical slice): it cuts through all layers end to end, is demonstrable on its own and can be executed autonomously by an agent. Every acceptance criterion appears in the `Criteria covered` of some step.

### Step 01 — <Title>

**Status:** Pending
**Execution type:** AFK | HITL
**Criteria covered:** AC-1.1, AC-1.2, AC-2.1

#### What To Build

<What must work at the end of this step, from the entry point to the observable result — not how each layer should be implemented internally. State what IS and what is NOT included.>

#### Affected repositories and layers

<the repository modified and which of its layers are affected>

#### Blockers

- [Step NN — Title](#step-nn--title)
<If there are no blocking steps, leave this section empty and do not remove it>

#### Implementation Notes

<Non-obvious technical hints that help the agent. Include only when there are decisions
the agent could not infer from the PRD or the codebase on its own — for example,
a silent constraint, an existing counterintuitive behavior, or a library
limitation that affects the design.

Do not over-specify: leave room for the agent to make tactical decisions. These
notes supplement the context, they do not replace the agent's judgment.>

---

### Step 02 — <Title>

...
