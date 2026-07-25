# ADR format

ADRs use sequential numbering **per directory**: `0001-slug.md`, `0002-slug.md`, etc. Create the directory lazily, only when the first ADR is needed.

## Where the ADR lives — by reach, biased toward the Context

Decide based on the scope of the decision:

- **Affects a single Context** → it lives in the Context: `docs/contexts/{slug}/adr/`. This is the default case.
- **It is cross-cutting** (spans 2+ Contexts, or defines the architectural shape of the whole repo) → it lives at the root: `docs/adr/`.
- **When in doubt → Context.** Prefer the narrower reach; promote to cross-cutting only when the cross-cutting nature is evident.

In a **single-context** repo there is only `docs/adr/` at the root — this decision does not arise.

**Glossary before the ADR — always.** A Context can **never** have an ADR before it has a glossary: create/update `docs/contexts/{slug}/CONTEXT.md` before creating the `docs/contexts/{slug}/adr/` directory and the ADR. This forces the glossary to always be considered before the decision, keeping the repo's documentation alive and current as the Context is touched by tasks.

## Template

```md
# {Short decision title}

{1-3 sentences: what the context is, what was decided and why.}
```

That's it. An ADR can be a single paragraph. The value is in recording that a decision *was made* and *why*, not in filling out sections.

## Optional sections

Include these only when they add genuine value. Most ADRs will not need them.

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — useful when decisions are revisited
- **Options considered** — only when the rejected alternatives are worth remembering
- **Consequences** — only when non-obvious downstream effects need highlighting

## Numbering

Numbering is **per directory**: each `adr/` has its own sequence starting at `0001-`. Scan the relevant `adr/` (the Context's, or the root `docs/adr/` if cross-cutting) for the highest existing number and increment by one.

## When to offer an ADR

All three criteria below must be true:

1. **Hard to reverse** — the cost of changing your mind later is significant
2. **Puzzling without context** — a future reader will wonder "why did they do it this way?"
3. **The result of a real trade-off** — there were genuine alternatives and you chose one for specific reasons

If a decision is easy to reverse, skip it — you'll simply reverse it. If it isn't puzzling, nobody will wonder why. If there was no real alternative, there is nothing to record beyond "we did the obvious thing."

### What qualifies

- **Architectural shape.** "We're using a monorepo." "The write model is event-sourced, the read model is projected into Postgres."
- **Integration patterns between contexts.** "Ordering and Billing communicate via domain events, not synchronous HTTP."
- **Technology choices that create lock-in.** Database, message bus, auth provider, deployment target. Not every library — only the ones that would take a quarter to swap out.
- **Boundary and scope decisions.** "Customer data is owned by the Customer context; other contexts reference it by ID only." The explicit 'no's are as valuable as the 'yes'es.
- **Deliberate departures from the obvious path.** "We're using hand-written SQL instead of an ORM because of X." Anything where a reasonable reader would assume the opposite. This stops the next engineer from "fixing" something that was deliberate.
- **Constraints not visible in the code.** "We can't use AWS due to compliance requirements." "Response times must be under 200ms because of the partner API contract."
- **Rejected alternatives when the rejection isn't obvious.** If you considered GraphQL and chose REST for subtle reasons, record it — otherwise someone will suggest GraphQL again in six months.
