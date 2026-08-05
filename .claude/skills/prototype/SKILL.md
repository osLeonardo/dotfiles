---
name: prototype
description: Builds a throwaway prototype to validate a decision before opening a PRD. Uses two branches — an interactive terminal app for logic or state-machine questions, or UI variants switchable in the browser for appearance questions. Use when the user wants to prototype, validate a data model, test a state machine, explore layout options, or says "prototype this", "let me test it first", "show me how it'd look", "not sure this logic works". Use instead of plan-task when the blocking question is specifically about logic/state-machine behavior or UI appearance — not about domain terminology or higher-level architectural decisions, which stay with plan-task.
argument-hint: "What question does the prototype need to answer?"
---

# Prototype

A prototype is **throwaway code that answers a question**. The question determines the format.

---

## Step 0 — Identify the branch

Identify which question is being answered — from the user's argument, from the surrounding code, or by asking if the user is available:

- **"Does this logic / state model make sense?"** → **Logic branch**. Build an interactive terminal app that pushes the state machine through cases that are hard to reason about on paper.
- **"What should this look like?"** → **UI branch**. Generate radically different UI variants on a single route, switchable via a floating bar in the browser.

The two branches produce very different artifacts — getting this wrong wastes the whole prototype. If the question is genuinely ambiguous and the user isn't available, prefer whichever branch best matches the surrounding code (backend module → Logic; page or component → UI) and state the assumption at the top of the prototype.

---

## Rules valid for both branches

1. **Throwaway from day one, and marked as such.** The prototype lives inside the repository being explored, in a `prototype/` folder at the repo root — next to the code it's testing, without inventing new structure. The folder or route name must make it obvious it's a prototype, not production.

2. **One command to run.** Use the project's existing task runner (`pnpm dev`, `pnpm run prototype:<name>`, `ng serve`, etc.). The user should be able to start it without thinking.

3. **No persistence by default.** State lives in memory. If the question explicitly involves persistence, use a local file with an obvious "PROTOTYPE — safe to delete" name.

4. **No polish.** No tests, no error handling beyond what keeps the prototype running, no abstractions. The goal is to learn fast and delete.

5. **Expose the state.** After every action (Logic) or on every variant switch (UI), show the full relevant state so the user can see what changed.

6. **Delete or absorb when done.** Once the prototype answers the question, delete it or fold the validated decision into the real code — don't leave it rotting in the repo.

7. **`.gitignore` on first use.** The first time you create a prototype in a repository, add a `prototype/` entry to that repo's `.gitignore`. Confirm with the user before making any change to `.gitignore`.
