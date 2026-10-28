# Logic branch

## When to use

- "I'm not sure the workout state machine handles the case where X and then Y."
- "Can this data model represent the case where..."
- "I want to feel out what the API should look like before writing it."
- Any situation where the user wants to **press buttons and watch the state change**.

If the question is "what should this look like" — wrong branch. Use the UI branch.

## L1 — State the question

Before writing code, write down the question the prototype answers. One paragraph, in a comment at the top of the main file or in a `README.md` inside the prototype folder. A Logic prototype that answers the wrong question is pure waste — make the question explicit so it can be checked later.

## L2 — Pick the language

Use the language of the repository being explored. That way the validated logic module moves into the real code without translation, and the prototype brings no new package manager or runtime into the repo.

- **TypeScript repository** (the default in this workspace) — run without a build step using `tsx` (check whether it's already in the project before installing): `pnpm exec tsx prototype/<name>/index.ts`, or `npx tsx prototype/<name>/index.ts` if it isn't installed. In a pnpm workspace monorepo, run it from the repo root so imports from workspace packages resolve.
- **Any other language** — a throwaway console entry point in `prototype/<name>/`, run with the language's native runner. Before creating it, make sure the repo's existing build won't pick it up (e.g. a .NET SDK project at the repo root includes every `.cs` file below its folder, so the prototype would end up in its build).

## L3 — Isolate the logic in a portable module

Put the real logic — the part that answers the question — behind a small, pure interface that can be lifted into the real code later. The surrounding terminal is throwaway; the logic module shouldn't be.

The right shape depends on the question:

- **Pure reducer** — `(state, action) => state`. Good when actions are discrete events and state is a single value.
- **State machine** — explicit states and transitions. Good when "which actions are valid right now" is part of the question.
- **Pure functions** over a simple data type. Good when there's no implicit state — only transformations.

Keep it pure: no I/O, no terminal code, no console writes for control flow. The terminal imports and calls the module; nothing flows the other way.

This is what makes the prototype useful beyond its own lifetime. Once the question is answered, the validated reducer / machine / set of functions can be transplanted into the real module — the terminal shell gets deleted.

## L4 — Build the smallest terminal that exposes the state

Build it as a **lightweight TUI**: on every cycle, clear the screen (`console.clear()` in TypeScript, or the language's equivalent) and re-render the whole frame. The user should always see a stable view, not a growing scrollback.

Each frame has two parts, in this order:

1. **Current state**, formatted to be readable and diff-friendly (one field per line, or pretty-printed JSON). Use **bold** (`\x1b[1m`) for field names or section headers and **dim** (`\x1b[2m`) for less important context (timestamps, IDs, derived values). Reset with `\x1b[0m`. No styling library — plain ANSI is enough.
2. **Keyboard shortcuts**, listed at the bottom: `[s] start set  [c] complete set  [k] skip exercise  [t] tick rest timer  [q] quit`. Bold on the key, dim on the description.

Behavior:
1. Initialize the state — a single in-memory object. Render the first frame on startup.
2. Read one keystroke (or one line) at a time, dispatch it to a handler that updates the state.
3. Re-render the full frame after every action — replace, don't append.
4. Loop until quit.

The whole frame must fit on one screen.

## L5 — Run with one command

In a TypeScript repository, add a script to the repo's `package.json`:
```json
"prototype:<name>": "tsx prototype/<name>/index.ts"
```

Confirm with the user before modifying `package.json`.

In a repository without a `package.json`, put the run command at the top of the prototype's `README.md`.

## L6 — Hand it to the user

Give the user the run command. They'll drive it on their own; the interesting moments are when they say "wait, that shouldn't be possible" or "huh, I assumed X would be different" — those are the bugs in the *idea*, which is the whole point. If the user wants new actions, add them. Prototypes evolve.

## L7 — Capture the answer

Once the prototype has done its job, go to the [Closing step](SKILL.md#closing-step--capture-the-answer-and-clean-up) in `SKILL.md`.

## Anti-patterns

- **Don't mix logic and terminal.** If the reducer or state machine references console output, prompts or terminal escape codes, it's no longer portable. Keep the terminal as a thin shell over a pure module.
- **Don't ship the terminal shell to production.** The shell is optimized for being driven by hand from a terminal. The logic module behind it is the part worth keeping.
