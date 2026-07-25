---
name: spec-task
description: Turns the current conversation's context into a structured PRD and generates granular steps ready for implementation by AI agents. Use whenever the user wants to create a PRD, generate implementation steps, document a development plan, convert a technical discussion into executable tickets, or formalize requirements into steps for agents.
---

# Spec Tasks

Converts a session's context into structured documentation: a single file per issue containing the PRD and the steps ready for the agent to implement.

The flow has two confirmation gates (PRD and steps) before creating any file.

**Template:** [prd-template.md](../../docs/templates/prd-template.md)

---

## Prerequisites

Check the fields below before starting. For any missing field that cannot be inferred from the conversation, **stop and ask the user** before continuing.

| Field | Source | If missing |
|---|---|---|
| Issue | User or conversation context | Ask the user |
| Branch type | User or conversation context (`Feature` or `Hotfix`) | Ask the user |
| Slug | User, or inferred from the issue title (kebab-case) | Infer from the title; confirm with the user |
| Context of what to implement | Current conversation | Ask the user |

---

## Process

### 1. Explore the repository (if needed)

IF the conversation has not yet explored the codebase in the affected areas:
- Identify existing architectural patterns in the area
- Load the glossary according to the repo's `single|multi` classification in the global `CLAUDE.md`:
  - **single** → read the root `CONTEXT.md` (if it exists)
  - **multi** → consult `CONTEXT-MAP.md`, route by domains/anchor entities and read **only** the relevant `docs/contexts/{slug}/CONTEXT.md`. If new areas surface during generation, load the corresponding Contexts **incrementally**.

Use the correct domain vocabulary throughout the generated documentation.

---

### 2. Generate the PRD

Synthesize the conversation's context into a PRD following [prd-template.md](../../docs/templates/prd-template.md). **Do not interview the user** — work with what is already in context.

Fill in `Issue`, `Branch type` and `Slug` with the values from the prerequisites.

Save to `{root}/.claude/docs/prd/<issue>-YYYY-MM-DD.md`. Create the directory if it does not exist.

---

### 3. Gate 1 — Confirm the PRD

Tell the user:
- The path where the file was saved
- A summary: problem, solution, number of user stories

Wait for explicit confirmation. Iterate until approved. **Do not move on to the steps without approval.**

---

### 4. Propose the step plan

Plan the steps as **tracer bullets** (vertical slices): each step cuts through ALL layers end to end (schema → service → API → frontend → tests), is demonstrable on its own, and can be executed autonomously by an agent.

Present to the user:

```
1. **[Title]** — AFK | HITL
   Blocked by: none | step N
   Stories covered: US-1, US-3
   Summary: one sentence on what this step delivers
```

Ask:
- Is the granularity right?
- Are the dependencies right?
- Any step to split or merge?
- Are the AFK/HITL markings right?

Iterate until explicitly approved.

---

### 5. Gate 2 — Write the steps into the file

After the plan is approved, add the `## Steps` section to the issue file created in Step 2.

Write the steps in dependency order (blockers first). Each step follows the `### Step NN — <Title>` structure from the template.

Mandatory fields in each step:
- `Status`: `Pending`
- `Execution type`: AFK or HITL per the approved plan
- `Stories covered`: list of covered USs
- Blockers: anchor reference `[Step NN — Title](#step-nn--title)` for blocking steps

---

### 6. Present the execution order

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
