---
name: add-test
description: Increases unit test coverage in a module, file or layer that has none, independently of any issue. Use when the user wants to add retroactive tests to existing code as an ongoing quality effort — not to test freshly implemented code from a task, which is implement-task's responsibility.
---

## Quick references

| What I need | What I must read |
|---|---|
| General testing patterns | `{root}/.claude/docs/knowledge/coding-rules.md` |
| C#/.NET testing patterns | `{root}/.claude/docs/knowledge/csharp-patterns.md` |
| Angular testing patterns | `{root}/.claude/docs/knowledge/angular-patterns.md` |
| React testing patterns | `{root}/.claude/docs/knowledge/react-patterns.md` |

---

## Overview

This skill **does not change production code** — it only writes retroactive tests for existing, uncovered code. It does not follow TDD (there is no Red → Green → Refactor, since the code already exists and must not change).

---

## Prerequisites

| Field | Source | If missing |
|---|---|---|
| Target module, file or layer | User | Ask the user |

---

## Step 1 — Map what is missing coverage

1. Find the repo's `single|multi` classification in the Repository Map of the global `CLAUDE.md` and read the relevant `CONTEXT.md` (see the routing in `implement-task`), if needed to understand the target code's domain
2. Read the repository language's testing patterns (see Quick references) and `coding-rules.md`
3. Map, within the scope indicated by the user, what currently exists without tests
4. Present the mapping to the user: the list of uncovered files/functions/methods within the requested scope

---

## Step 2 — Propose test cases

1. For each mapped item, propose the test scenarios, including edge cases
2. Wait for explicit approval before writing any test

---

## Step 3 — Write the tests

1. Implement only the approved tests, following the naming and structural conventions of the repository's language
2. Run the written tests and confirm they all pass against the existing code
3. Present a summary of what was covered and the list of test files created

---

## Untestable code

IF, during mapping or while writing the tests, you find code that would need refactoring to become testable (e.g. dependencies coupled via singletons, functions mixing side effects with pure logic):

- **Do not refactor** — that is the `refactor` skill's scope, not this one
- Flag the case to the user, indicating what blocks coverage and suggesting a `refactor` session address it before (or after) the coverage is added
- Continue covering whatever is possible in the current scope without the refactor

---

## Constraints

- Does not change production code under any circumstance — it only writes tests for existing code
- Does not run any git command
- Never installs or updates packages without explicit approval
- Does not write any test before explicit approval of the cases proposed in Step 2
