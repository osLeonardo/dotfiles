---
name: document-task
description: Generates the issue closeout document (Pull Request body or completion comment) at the end of an implementation. Use whenever the user finishes an implementation and needs to document what was done — even if they don't explicitly mention "document-task" or the skill name.
---

Generate the issue closeout document based on what was implemented. Save it in `{root}/.claude/docs/tasks/`.

---

## Sources of information

Consult every available source, in this order of priority:

1. **Current session context** — what was implemented, discussed and decided. This is the primary source.
2. **Handoffs generated during the implementation** — look in `.claude/docs/handoffs/` by issue number.
3. **ADRs generated during the implementation** — look in the ADR directories of the affected repositories.
4. **The task's PRD** — use as a secondary source for planned business rules. Look in `.claude/docs/prd/`. The PRD does not necessarily reflect what was actually implemented — use judgment.

If a source does not exist, proceed with the others without interrupting.

IF any critical information is missing from every source → ask the user before generating the file. Do not assume or invent.

---

## Document fields

Five fields are mandatory. One is optional.

**Definition of done** — an objective, direct completion criterion. One or two sentences. Describes the result, not the process.

**Details** — describes how the implemented functionality should behave: what the user sees, what happens on each action, which business rules apply (new and existing). Clear enough for someone to validate the change without reading the code. This is the most important field. Pay particular attention to business rules (new and existing ones affected), error behavior and edge cases, and alternative flows.

**Technical details** — code and architecture decisions made during the implementation. Organize by repository when the change affects more than one. Includes: adopted patterns, structures created, integrations made, decisions that are not obvious from the code. In simple or small tasks, this may be merged with Details into a single section — use sparingly.

**Traceability** — lists the functionality affected by the change, new and existing. These are not links to commits. It is a functional impact map that indicates what may have been affected beyond the direct scope.

**Tests performed** — a brief description of the scenarios tested. A simple list, one scenario per line.

**Notes** *(optional)* — use only when there is relevant information that does not fit the fields above. Examples: new environment variables, specific infra configuration, pending external dependencies, manual steps required before or after deploy. Omit the entire section if there is nothing to add.

---

## File format

Markdown, so it can be pasted directly into the Pull Request body or as an issue comment. Use `##` for section titles and hyphens for lists. No introductory or closing prose outside the fields.

When there is a linked issue, include `Closes #<issue>` on the document's last line — GitHub closes the issue automatically when the PR is merged.

**Template:** [task-template.md](../../docs/templates/task-template.md)

---

## File name and destination

Name: `task-{ID}.md`, where `{ID}` is the GitHub issue number.

IF the ID is not available in context, ask the user. If the user does not provide one, use a descriptive kebab-case slug based on the task's topic (e.g. `task-export-routine-json.md`).

Destination: `{root}/.claude/docs/tasks/`

Confirm the full path of the generated file to the user.

> Generating the file **does not** publish anything. Opening the PR or commenting on the issue is an external action — only do it when the user explicitly asks.
