# CONTEXT.md format

## Structure

```md
# {Context name}

{One or two sentences describing what this context is and why it exists.}

## Language

{The domains/terms that make up this context, each with a brief description.}

**Order**:
{One or two sentences describing the term}
_Avoid_: Purchase, transaction

**Invoice**:
A payment request sent to the customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account

## Relationships

{How the domains/terms above relate to each other. Use the bold names and
express cardinality where it is obvious. Also include references to other
Contexts here when this one depends on them.}

- A **Customer** places N **Orders**.
- Each **Order** generates one or more **Invoices** after delivery.
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others as aliases to avoid.
- **Flag conflicts explicitly.** If a term is used ambiguously, highlight it under "Flagged ambiguities" with a clear resolution.
- **Keep definitions lean.** One or two sentences at most. Define what it *IS*, not what it does.
- **Show relationships.** Use bold term names and express cardinality where it is obvious.
- **Include only terms specific to the project's own context.** General programming concepts (timeouts, error types, utility patterns) do not belong here, even if the project uses them extensively. Before adding a term, ask: is this a concept unique to this context, or a general programming concept? Only the former belongs here.
- **Group terms into subsections** when natural clusters emerge. If all terms belong to a single cohesive area, a flat list is enough.
- **Write a sample dialogue.** A conversation between a developer and a domain expert that demonstrates how the terms interact naturally and clarifies the boundaries between related concepts.

## Where it lives

This file is the **glossary of one Context** — nothing more. Routing between Contexts is the responsibility of `CONTEXT-MAP.md` (see `context-map-template.md`).

**Single-context repo (most of them):** one `CONTEXT.md` at the repo root, plus `docs/adr/` at the root.

**Multi-context repo:** one `CONTEXT.md` per Context, at `docs/contexts/{slug}/CONTEXT.md`, accompanied by its own `docs/contexts/{slug}/adr/`. The documentation lives in `docs/` and **does not mirror the code folders** — the same `docs/contexts/` convention serves a layered repo (most of them, C#) or a sliced one. In that case, a `CONTEXT-MAP.md` at the root routes `task/file → Context`.

Each repo's `single|multi` classification lives **only** in the Repository Map of the global `CLAUDE.md` (single source).

How the skill decides:

- The `single|multi` classification comes from the Repository Map in the global `CLAUDE.md`.
- In a **multi** repo, consult `CONTEXT-MAP.md` to route to the right Context and load **only** its `CONTEXT.md` (incremental loading — see `context-map-template.md`). If the map does not exist yet, it **is born with the 1st documented Context**.
- In a **single** repo there is one root `CONTEXT.md`; create it lazily when the first term is resolved.
