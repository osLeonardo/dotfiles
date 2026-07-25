---
name: handoff
description: Compacts the current conversation into a handoff document so another agent can continue the work.
argument-hint: "What will the next session be used for?"
---

Write a handoff document summarizing the current conversation so a new agent can continue the work. Save it in the `{root}/.claude/docs/handoffs` directory.

**File naming:**
- If the issue number is available in the session (via PRD, step, bug or explicit mention), the name **must** start with `<issue>-` followed by a short suffix describing the focus — pattern `<issue>-*` (e.g. `42-load-progression-refactor.md`). That prefix is what lets `implement-task` automatically locate all of the issue's handoffs.
- If there is no issue number in the session, use a name that clearly references what the session was doing (e.g. `routine-loading-slowness-investigation.md`).

Include a "suggested skills" section in the document, suggesting skills the agent should invoke when loading the handoff file.

Do not duplicate content already captured in other artifacts (PRDs, plans, ADRs, issues, commits, diffs). Reference them by path relative to `{root}`, or by URL, instead.

Strip any sensitive information, such as API keys, passwords or personally identifiable information.

If the user passed arguments, treat them as a description of the next session's focus and adapt the document accordingly — the argument guides the **structure** of the generated document, not just what gets mentioned in it.

---

## Structure by session type

Identify which skill was active when the session was interrupted (or what the conversation most closely resembles, if no formal skill was in use) and build the document around the matching structure below. If the session fits none of the types below, use a generic summary structure.

### Interrupted `plan-task` session

Focus the document on:
- **Decisions already made** — a short list, referencing the `CONTEXT.md`/ADR where they were recorded (do not duplicate the text)
- **Pending decisions** — what is still open in the design tree
- **Unanswered questions** — questions the agent already asked that went unanswered
- **Next question** — what the next question would have been, so the new agent picks up exactly where it left off

### Interrupted `implement-task` session

Focus the document on:
- **Step in progress** — a reference to the step and the PRD (relative path); do not copy the step's content
- **Current state of the code** — what has been written, and which TDD stage it is in (Red, Green or Refactor)
- **Tests** — which pass and which fail at the moment of interruption
- **Concrete next step** — the exact action the new agent should take on resuming, not a generic "continue the implementation"

### Interrupted `bug-fix` session

Focus the document on:
- **Bug description** — a reference to the file created from `bug-template.md` (relative path); do not duplicate it
- **Root cause hypothesis** — what was investigated and the current hypothesis, even if unconfirmed
- **What has already been tried** — approaches explored and discarded, and why, so the new agent does not repeat the same path

### Interrupted `refactor` session

Focus the document on:
- **Refactor scope** — a reference to the approved plan; do not duplicate it
- **Characterization tests** — which already exist and whether they safely capture the current behavior
- **Refactor state** — what has already been moved/changed and what remains
- **Observable behavior** — any points of attention about what must remain identical

### Exploratory session or no formal skill active

Use a generic structure: conversation context, decisions made, and suggested next steps for future sessions.
