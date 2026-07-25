# Code implementation rules

Global rules the agent must follow in any repository in the workspace. Repository-specific rules live in that repo's `CLAUDE.md` and take precedence over this document in case of conflict.

## Quick references

| What I need | What I must read before implementing |
|---|---|
| Modify backend code in C#/.NET | `docs/knowledge/csharp-patterns.md` |
| Modify any 'Frontend' repo | `docs/knowledge/ui-ux-patterns.md` |
| Modify an Angular frontend | `docs/knowledge/angular-patterns.md` |
| Modify a React frontend | `docs/knowledge/react-patterns.md` |

---

## Identity and role

- The user defines *WHAT* to do and validates the decisions
- You decide *HOW* to implement it, writing the code and the tests
- You must never consider a task finished unless all tests in all affected repositories are passing
- If an architectural decision has to be made, read `{root}/.claude/docs/templates/adr-template.md` and then inform the user
- You must never make architectural decisions without user approval.

Before writing, modifying or removing any code, follow this sequence:

1. **Understand** — confirm you understand the full scope of the task and its constraints
2. **Plan** — list the files that will be created, modified or removed before touching any of them
3. **Implement** — follow the rules in this document and the repository's conventions
4. **Review** — once done, verify that no rule was violated before reporting it as finished

**Explain only when the decision is not obvious.** Do not generate explanatory prose for self-explanatory code.

### Implementation workflow

You must use a mandatory TDD flow. Follow the sequence below without skipping steps:
1. Write the test cases (Red)
2. Write the minimum code needed for the tests to pass (Green)
3. Fix and improve the code following the rules and without breaking the tests (Refactor)
4. Run all tests in the affected layers/repositories/projects
5. If any test fails, repeat steps 3 and 4 iteratively until every test passes

---

## Rules

The rules below must be followed for any code being written and/or removed.

### Code style

- **Functions:** 4–20 lines. Beyond 20, split into smaller functions
- **Files:** 500 lines maximum. Beyond that, split by responsibility
- **One responsibility per function**, one per module (SRP)
- **Specific, unique names** — avoid generic `data`, `handler`, `manager`, `utils`. Prefer names that return fewer than 5 results in a codebase grep
- **No code duplication** — extract shared logic into its own function or module
- **Early returns** instead of nested ifs — 2 levels of indentation maximum
- **Explicit types** — no `any` (TypeScript), no `dynamic` (C#), no functions without a return type
- **Exception messages** must include the value that caused the error and the expected format

### Comments

The default is **no comments**. Write one only when **all** of the criteria below are true:

1. The *why* behind the decision is not obvious from the code
2. The absence of the comment could confuse a future reader
3. The reason is a hidden constraint, a subtle invariant, a workaround for a specific bug, or surprising behavior

Additional rules:
- Do not remove existing comments during refactors — they carry intent and history
- Write docstrings on public functions: describe their intent in one line + a usage example

### Tests

- Every new function gets a test
- Every fixed bug gets a regression test
- Tests must be F.I.R.S.T: *fast, independent, repeatable, self-validating, timely*

### External dependencies

- Inject dependencies via constructor or parameter — never via a global import or an implicit singleton
- Wrap third-party libraries behind an interface owned by the project
- Do not install or update packages without first communicating, justifying the need and waiting for user approval

### Structure

- Follow the conventions of the frameworks and languages in each repo's stack
- Prefer small, focused modules over god files
- Use predictable directories: controllers, services, entities, DTOs, src, libs, tests

### Formatting

- Use the language's default formatter. Do not debate formatting beyond that.

---

## When to ask for confirmation

Stop and consult the user before proceeding in the following cases:

- Removing an entire file
- Architectural decisions
- Installing or updating any external package/library
- A change that breaks a module's public interface (breaking change)
- Any irreversible action that cannot be undone with a simple revert
