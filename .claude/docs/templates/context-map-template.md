# CONTEXT-MAP.md format

`CONTEXT-MAP.md` is the **lightweight router** of a multi-context repository. It sits at the **repo root** and is the only context artifact **always loaded** into memory. Its job is to map `task/file → Context` so the agent loads **only** the `CONTEXT.md` of the Context(s) the task actually touches — never everything.

## When it exists

- **Multi-context repo:** `CONTEXT-MAP.md` **is born alongside the 1st documented Context** (there is no "loose root CONTEXT.md" phase). It grows lazily, one entry per Context, as new Contexts are touched.
- **Single-context repo:** it has **no** `CONTEXT-MAP.md`. It gets by with `CONTEXT.md` + `docs/adr/` at the root.

Each repo's `single|multi` classification lives **only** in the Repository Map of the global `CLAUDE.md` (single source).

## Structure

```md
# Context Map — {repo}

## Contexts

### {Context} — {one line on what it is}
- **Glossary:** docs/contexts/{slug}/CONTEXT.md
- **Domains:** {domains from CLAUDE.md covered by this Context}
- **Anchor entities:** {non-obvious classes; optional}
- **ADRs:** docs/contexts/{slug}/adr/

## Cross-cutting ADRs

docs/adr/ — decisions spanning 2+ Contexts
```

## Routing anchors

Each Context entry carries anchors that help match a task to the right Context:

- **Domains** — the **primary** anchor. These are the domains from the Repository Map in the global `CLAUDE.md`. They are stable and match the task description directly. **Each domain belongs to exactly one Context** (no overlap) — this is a prerequisite for deterministic routing.
- **Anchor entities** — **optional and non-exhaustive**. List only the **non-obvious** class names, whose name does not give away the Context (e.g. `CustomerAvailableLimit.cs` represents the `Available Limit` domain, but the name doesn't say so). These are **search seeds**, not a file manifest.

## Rules

- **Listing an entity in the map ≠ reading the file.** The anchor is just text in the map. *Which files* form a Context is discovered **dynamically at task time** (grep/navigation starting from the glossary vocabulary + anchor entities) — never a hand-maintained manifest, which would go stale.
- **Incremental loading, not a single gate.** Do not load everything at the start of the task. Load the Context(s) the task appears to touch; if, mid-work, a domain/entity/file surfaces that is not covered by the already-loaded Contexts, **consult the map and load the new Context at that moment**, then carry on.
- **Keep it lean.** One line per Context in the description. The map is a router, not documentation — the detail (terms and their relationships) lives in each Context's `CONTEXT.md`.
- **It grows lazily.** Add a Context's entry when it is documented for the first time. A valid Context **cannot** exist without a glossary.
