---
name: sync-config
description: Compares this `.claude/` tree against another `.claude/` tree from a different workspace (a work repo, another machine, a shared team template) and ports over whatever is worth adopting — skills, knowledge docs, templates, scripts — rewritten in generic form. Use when the user wants to pull improvements made to a similar Claude Code setup elsewhere into this personal workspace, or asks to "sync", "port" or "update" this `.claude/` from another one.
---

## Quick references

| What I need | What I must read |
|---|---|
| This workspace's language/terminology defaults | `{root}/.claude/CLAUDE.md` |
| Current branch/commit model (for terminology alignment) | `{root}/.claude/docs/knowledge/git-branch-rules.md`, `git-commit-rules.md` |
| Current workflow model (for terminology alignment) | `{root}/.claude/docs/knowledge/development-process.md` |

---

## Overview

This skill never copies a file verbatim. The other `.claude/` tree may encode conventions from a different, non-personal context — a ticketing system, a QA role, a multi-repo branch model, an organization or product name. This workspace's own docs (`CLAUDE.md`, `git-branch-rules.md`, `git-commit-rules.md`, `development-process.md`) are the **source of truth** for what terminology and mechanics are valid here. Anything ported must be rewritten to match them, not the other way around.

The three outcomes for any given difference are:
- **Adopt as-is** — a structural or mechanical improvement with no source-specific baggage (e.g. a clearer gate wording, a missing edge case in a step).
- **Adopt, genericized** — the underlying mechanic is useful but the wording carries source-specific terms, names, or examples that need rewriting.
- **Skip** — the difference only exists because the source workspace has a mechanic this workspace doesn't (a role, a ceremony, a multi-repo flow) and forcing it in would contradict this workspace's own documented model.

Never guess silently on which bucket a difference falls into when it's not obvious — surface the judgment call to the user instead of picking one.

---

## Prerequisites

| Field | Source | If missing |
|---|---|---|
| Path to the other `.claude/` directory | User | Ask the user |

---

## Step 1 — Inventory the differences

1. Walk `skills/`, `agents/`, `docs/knowledge/`, `docs/templates/`, `docs/scripts/` in both trees
2. Build three buckets:
   - **New** — exists in the source, not here (by name or by close equivalent — check for renames before calling something new)
   - **Changed** — exists in both, but content differs beyond superficial formatting
   - **Source-only mechanic** — a concept in the source with no file-level counterpart here (e.g. an entire orchestration pattern folded into one script), noted for awareness even without a single file to diff
3. Present the inventory as a flat list grouped by bucket — file path, one-line description of what differs, nothing else yet
4. Wait for the user to pick which items to process now (default to all if they don't narrow it down)

---

## Step 2 — Process one item at a time

For each item selected in Step 1, repeat this full cycle before moving to the next — never batch multiple items into one write:

1. Read the source file in full, and this workspace's equivalent if one exists
2. Re-read this workspace's own conventions docs (see Quick references) if not already fresh in context
3. **Evaluate relevance** — does the mechanic behind this difference apply to this workspace's model (single repo per project, GitHub issues, no QA role, no multi-tier branch/ceremony model, English-only)?
   - If not applicable: mark **Skip**, state the one-line reason, move to the next item without writing anything
   - If applicable: continue
4. **Genericize** — rewrite so that:
   - All prose is in English, matching this workspace's tone and heading structure (`Quick references` / `Overview` / `Prerequisites` / `Step N` / `Constraints`)
   - Any organization, product, internal-tool, or person name is replaced with a generic descriptor, or removed if it adds no information without the name
   - Terminology matches what this workspace already uses (check the conventions docs — don't invent new terms for concepts that already have a name here)
   - Illustrative examples use whatever example domain this workspace's other docs already use, for consistency, rather than a new one per file
   - Structural skeleton (headers, gate placement, table shape) is preserved — only content changes, not the skill's shape
5. Present the result — full content for a new file, a diff-style before/after for a changed one
6. Wait for explicit approval before writing
7. On approval, write the file. If the source name doesn't fit this workspace's naming (check for an existing rename precedent, e.g. a `-main` vs `-master` style difference), use the fitting name and say so

---

## Constraints

- Never write a file without an explicit approval gate for that specific item, even when several items were pre-selected in Step 1
- Never carry over a company, product, or person name — if unsure whether a term is generic or identifying, ask rather than assume
- Never introduce a role, ceremony, or multi-repo mechanic that contradicts this workspace's own documented model, even if the source relies on it — skip it and say why
- Does not run any git command — leave committing the result to `git-process`
- Does not modify the source `.claude/` tree under any circumstance — read-only on that side
