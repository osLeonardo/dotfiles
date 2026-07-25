---
name: plan-task
description: A planning session that refines your plan against the existing domain model, sharpens the terminology, and updates documentation inline (CONTEXT.md, ADRs) as decisions solidify. Use when the user wants to plan a task or document design decisions.
---

<what-to-do>

Ask me relentless questions about every aspect of this task until we reach a shared understanding. Walk every branch of the design tree, resolving the dependencies between decisions one at a time. For each question, give your recommended answer.

Ask the questions one at a time, waiting for feedback on each one before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

</what-to-do>

<supporting-info>

## Step 0 — Proactive vocabulary extraction

Run this step before any planning question.

1. Identify the repositories affected by the task
2. For each repo, find its `single|multi` classification in the Repository Map of the global `CLAUDE.md` (the `Context: single|multi` line) and route the documentation:
   - **single** → read the root `CONTEXT.md` (if present) — note the already-documented terms
   - **multi** → consult the root `CONTEXT-MAP.md`, identify the Context(s) the task touches (via domains/anchor entities) and read **only** the relevant `docs/contexts/{slug}/CONTEXT.md`. Loading is **incremental**: if the task later runs into another domain/entity, go back to the map and load that Context at that moment.
3. Explore the codebase in the areas relevant to the task
4. Identify **undocumented** terms specific to the project's domain — entities, business concepts, important distinctions (e.g. "internal customer" vs "external customer")
   - Ignore general programming concepts
   - Focus on terms an outside reader would not understand without context
5. IF you found undocumented terms:
   - Report: *"I found [N] relevant terms that aren't documented yet. Want to record them in CONTEXT.md before we continue?"*
   - IF the user confirms → follow the sequence: propose a draft → wait for review → write only after approval
   - IF the user declines → continue to the planning questions

Lazy glossary creation:
- **single** repo with no `CONTEXT.md` → create it at the root when the first term is confirmed.
- **multi** repo → the glossary goes in `docs/contexts/{slug}/CONTEXT.md`. If the Context does not exist yet, it is born when the first term is confirmed, and `CONTEXT-MAP.md` **is born alongside the 1st documented Context** (do not leave a "loose root CONTEXT.md" in a multi repo). Add the new Context's entry to the map in the same turn.

### Passive detection of the classification

Follow the global `single|multi` declaration, but **raise a flag** if the work contradicts it — e.g. a `single` repo whose root glossary has become a patchwork of independent domains that call for separation into Contexts. Any single→multi graduation (or other change to the global `CLAUDE.md`) is **always proposed to the user, never automatic**.

---

## During the planning questions

### Flagging impact on other repositories

IF a design decision under discussion impacts a domain belonging to **another repository** in the Repository Map of the global `CLAUDE.md` (not the repo(s) already identified as affected by the task):

- Flag it **immediately**, before moving to the next question — never save the flag for the end of planning
- Use the format:
  > "This decision impacts the [X] domain of repository [Y]. Confirm this decision before proceeding."
- Identify the impacted domain by cross-referencing the decision under discussion against each repository's **Domains** column in the Repository Map — you do not need to open or read the other repository to flag it; the flag is preventive
- After flagging, wait for the user's acknowledgment before moving to the next question. The user may choose to proceed anyway — the flag is an alert, not a blocker

### New terms that emerge in conversation

IF a relevant term surfaces during the questions that is not in `CONTEXT.md`:
- Propose documenting it immediately, inline
- Follow: cross-reference with the codebase → propose the text → wait for confirmation → write

### Conflicts with the glossary

IF the user uses a term that conflicts with the existing `CONTEXT.md`:
- Point it out immediately: *"The glossary defines X as Y, but you seem to mean Z — which is correct?"*

### Correct vague language

IF the user uses vague or overloaded terms → propose a precise canonical term. *"You're saying 'account' — do you mean the Customer or the User? They're different things."*

### Discuss concrete scenarios

When domain relationships are under discussion, stress-test them with specific scenarios. Invent scenarios that probe edge cases and force the user to be precise about the boundaries between concepts.

### Cross-reference with the code

IF the user states how something works → verify the code agrees. IF there is a contradiction → surface it before recording: *"Your code cancels entire Orders, but you just said partial cancellation is possible — which is right?"*

### Updating CONTEXT.md inline

Mandatory sequence before recording any term or decision:

1. Cross-reference with the codebase — confirm the code agrees
2. Propose the exact text to be inserted — wait for explicit confirmation
3. Write only after approval — apply it in the same turn, do not save it for the end of the session.

Use the format in [context-template.md](../../docs/templates/context-template.md).

`CONTEXT.md` is a glossary and nothing more. No implementation details, no specs, no technical decisions.

### ADRs

Offer to create an ADR **only** when all three criteria are true simultaneously:

1. **Hard to reverse** — changing your mind later carries significant cost
2. **Puzzling without context** — a future reader will wonder "why did they do it this way?"
3. **A real trade-off** — there were genuine alternatives and one was chosen for specific reasons

If any criterion is absent → do not offer an ADR.

**Default ADR format: a single paragraph.** Include optional sections (Options considered, Consequences) only if you can explicitly justify why they are needed. When in doubt, omit.

Use the format in [adr-template.md](../../docs/templates/adr-template.md).

The same cross-reference → proposal → confirmation sequence applies to ADRs.

**ADR location** (multi repo): affects a single Context → `docs/contexts/{slug}/adr/`; cross-cutting (2+ Contexts / repo shape) → root `docs/adr/`; when in doubt → Context. Numbering is per directory. **Glossary before the ADR — always:** never create a Context ADR without `docs/contexts/{slug}/CONTEXT.md` existing/updated first.

---

## Domain file structure

Each repo's `single|multi` classification lives in the Repository Map of the global `CLAUDE.md`.

**Single-context** repo (most of them) — `CONTEXT.md` + `docs/adr/` at the root:

```
/
├── CONTEXT.md
├── docs/
│   └── adr/
│       ├── 0001-event-sourced-orders.md
│       └── 0002-postgres-for-write-model.md
└── src/
```

**Multi-context** repo — `CONTEXT-MAP.md` at the root does the routing; each Context lives in `docs/contexts/{slug}/`. Documentation sits in `docs/` and **does not mirror the code folders**:

```
/
├── CONTEXT-MAP.md                    ← router; born with the 1st Context, grows lazily
├── docs/
│   ├── adr/                          ← cross-cutting ADRs (2+ Contexts)
│   └── contexts/
│       ├── billing/
│       │   ├── CONTEXT.md
│       │   └── adr/                  ← Context ADRs (numbering per directory)
│       └── onboarding/
│           ├── CONTEXT.md
│           └── adr/
└── src/
```

Create files lazily (only when you have something to write) and in line with step 0. In a multi repo, `CONTEXT-MAP.md` is born with the 1st documented Context. See [context-template.md](../../docs/templates/context-template.md) and [context-map-template.md](../../docs/templates/context-map-template.md).

</supporting-info>
