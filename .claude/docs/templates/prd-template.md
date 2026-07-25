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

1. As a <actor>, I want <functionality>, so that <benefit>

## Implementation Decisions

Technical decisions made during the conversation, organized by category:

### Interfaces and Contracts
- Contracts between modules (no file paths)
- API endpoints and data formats

### Architectural Decisions (ADR)
- Design choices, adopted patterns and their reasons

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

---

## Steps

### Step 01 — <Title>

**Status:** Pending
**Execution type:** AFK | HITL
**Stories covered:** US-N, US-N

#### What To Build

<Description of the end-to-end behavior of this vertical slice. Describe what must
work at the end — from the entry point to the observable result — not how each
layer should be implemented internally.

Be specific about scope: what IS included and what is NOT included in this step.>

#### Affected repositories and layers

<list the repositories that will be modified and which of their layers are affected>

#### Acceptance Criteria

- [ ] <Verifiable, objective criterion 1>
- [ ] <Verifiable, objective criterion 2>
- [ ] <Verifiable, objective criterion 3>

The criteria must be verifiable without ambiguity: an agent must be able to
determine whether each one was met by examining the code or running the system.

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
