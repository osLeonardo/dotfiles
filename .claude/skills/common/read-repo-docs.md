# Read the repositories' documentation

Used by: `implement-task`, `refactor`, `bug-fix`, `add-test`, `plan-task`, `spec-task`, `step-agent`.

For each affected repository:

1. Find the repo's `single|multi` classification in the Repository Map of the global `CLAUDE.md` and route accordingly:
   - **single**: read `CONTEXT.md` and `docs/adr/` at the root
   - **multi**: consult `CONTEXT-MAP.md`, route by the task's domains/anchor entities and read **only** the `docs/contexts/{slug}/CONTEXT.md` and `docs/contexts/{slug}/adr/` of the relevant Contexts (plus the root `docs/adr/` for cross-cutting ADRs)
2. Read the repo's `CLAUDE.md`

When the skill asks for the glossary only, read just the `CONTEXT.md` files from this routing, if they exist.

**Incremental loading (multi repo):** on running into a domain, entity or file not covered by the already-loaded Contexts, consult `CONTEXT-MAP.md` and load that Context at that moment, before proceeding. Loading is not a single gate at the start.

IF there is a contradiction between the code and `CONTEXT.md` → surface it to the user before proceeding.

Use the glossary's canonical terms throughout the generated code and documentation. In a conflict between the local `CLAUDE.md` and the global rules, the local `CLAUDE.md` wins.
