---
name: spec-task
allowed-tools: Read, Write, Edit, Glob, Grep
description: Turns the current conversation's context into a structured PRD, with acceptance criteria and steps ready for implementation by AI agents. Use whenever the user wants to create a PRD, generate implementation steps, document a development plan, convert a technical discussion into executable tickets, or formalize requirements into steps for agents.
---

# Spec Tasks

Converts a session's context into structured documentation: a single file per issue containing the PRD and the steps ready for the agent to implement.

The flow has a single confirmation gate: the user approves the complete PRD — acceptance criteria and steps — at once.

**Template:** [prd-template.md](../../docs/templates/prd-template.md)

---

## Prerequisites

Check the fields below before starting. For any missing field that cannot be inferred from the conversation, **stop and ask the user** before continuing.

| Field | Source | If missing |
|---|---|---|
| Issue | User or conversation context | Ask the user |
| Branch type | User or conversation context (`Feature` or `Hotfix`) | Ask the user |
| Context of what to implement | Current conversation | Ask the user |

---

## Process

### 1. Explore the repository (if needed)

IF the conversation has not yet explored the codebase in the affected areas:
- Identify existing architectural patterns in the area
- Load the glossary following `{root}/.claude/skills/common/read-repo-docs.md` — glossary only, loading new Contexts if new areas surface during generation

Use the correct domain vocabulary throughout the generated documentation.

---

### 2. Generate the PRD

Synthesize the conversation's context into a PRD following [prd-template.md](../../docs/templates/prd-template.md). **Do not interview the user** — work with what is already in context.

Fill in the issue number in the title and the `Branch type` with the values from the prerequisites.

Write `## Acceptance Criteria` following the rules of that section in the template. Behavior that cannot be made verifiable with what is in context does not become a criterion: it stays out of the file and is taken to the gate (Step 3).

Fill in `## Required reading` with the documents the implementing agent needs to load: ADRs created in this session, pre-existing ADRs that constrain the implementation, the `CONTEXT.md` of the Contexts touched and related handoffs. Only paths and the reason for each — never the content.

Plan the steps as **tracer bullets** (vertical slices): each step cuts through ALL layers end to end (schema → service → API → frontend → tests), is demonstrable on its own, and can be executed autonomously by an agent. Write them in dependency order (blockers first), each following the `### Step NN — <Title>` structure from the template, with:
- `Status`: `Pending`
- `Execution type`: `AFK` or `HITL`
- `Criteria covered`: IDs of the criteria the step delivers — every criterion in the PRD appears in some step
- `Blockers`: anchor reference `[Step NN — Title](#step-nn--title)` for blocking steps

Save to `{root}/.claude/docs/prd/<issue>-YYYY-MM-DD.md`. Create the directory if it does not exist.

---

### 3. Gate — Confirm the PRD

Tell the user:
- The path where the file was saved
- A summary: problem, solution, number of user stories and of acceptance criteria
- Steps: title, execution type, criteria covered, blockers and a one-sentence summary of what each delivers
- Behaviors that could not be turned into a verifiable criterion — a missing value, rule or product decision — one per line, with what is missing and who decides

The PRD is not approved with a non-verifiable criterion pending: each one becomes a verifiable criterion or goes explicitly into `## Out of Scope`. If the answer depends on someone outside the session, record the open item in `## Additional Notes` and come back to this gate when the answer arrives.

Ask about the step plan:
- Is the granularity right?
- Are the dependencies right?
- Any step to split or merge?
- Are the AFK/HITL markings right?

Wait for explicit confirmation. Iterate until approved — adjustments to criteria, steps and AFK/HITL markings happen here, in the same file. **Do not move on without approval.**

---

### 4. Present the execution order

Report:
- The file path
- The number of steps created

Present the execution order respecting blockers:

```
Execution order:

Step 01 — <Title> (AFK | ⚠ HITL)
Step 02 — <Title> (AFK | ⚠ HITL) — waits on Step 01
Step 03 — <Title> (AFK | ⚠ HITL)
```

HITL steps highlighted with `⚠ HITL` — the user must supervise the execution.
