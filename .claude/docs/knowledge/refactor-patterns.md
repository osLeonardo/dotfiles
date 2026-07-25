# Refactoring rules and patterns

Global rules the agent must follow in any pure refactor (no new feature) in any repository in the workspace. Repository-specific rules live in that repo's `CLAUDE.md` and take precedence over this document in case of conflict.

This document complements `coding-rules.md` — it does not replace it. Every rule on style, comments, tests and confirmation defined there still applies here.

## Quick references

| What I need | What I must read before refactoring |
|---|---|
| Refactor backend code in C#/.NET | `docs/knowledge/csharp-patterns.md` |
| Refactor an Angular frontend | `docs/knowledge/angular-patterns.md` |
| Refactor a React frontend | `docs/knowledge/react-patterns.md` |

---

## What makes a refactor safe

A refactor is safe only when the system's **observable behavior** remains identical before and after the change. Observable behavior includes:

- Inputs and outputs of public functions and endpoints
- Externally visible side effects (persistence, published messages, calls to other services)
- Error messages and status codes returned to the consumer

The following do *not* count as observable behavior: internal variable names, file organization, a class's internal structure — as long as nothing external depends on them.

If the proposed change alters any observable behavior, it is not a pure refactor. It is a functional change and must follow the `plan-task` → `spec-task` → `implement-task` flow, not `refactor`.

---

## Characterization tests

Write characterization tests **whenever the area being refactored has no existing test coverage**.

A characterization test captures the code's current behavior as it is today — not as it should be. It does not validate whether the behavior is correct; it validates that the behavior did not change after the refactor.

Mandatory sequence when there is no coverage:

1. Map the observable inputs and outputs of the section to be refactored
2. Write tests that capture the current behavior (including known bugs, if any — a characterization test does not fix, it only documents)
3. Confirm the characterization tests pass against the code **before** any change
4. Only then start the refactor
5. At the end, those same characterization tests must still pass unchanged

If during mapping you notice the code has a bug, **do not fix it in the same refactor** — flag it to the user and handle it as a separate bug (`bug-fix`) or its own issue. Mixing a bug fix into a refactor makes the diff impossible to review safely.

---

## What to never do without test coverage

- **Moving logic between layers** (e.g. Core → Infrastructure, or service → controller) without characterization tests covering the input/output behavior of the moved logic
- **Changing the execution order** of side effects (e.g. the order of calls to multiple repositories or external services) without coverage capturing that order, if it is observable
- **Consolidating or splitting public methods** without coverage exercising every existing path
- **Swapping the implementation of an external dependency** (e.g. changing serialization library, changing database driver) without tests capturing the current output format

In these cases, writing the characterization test is not optional — it is the first step of the refactor, not a stage that can be skipped out of haste.

---

## Stack-specific conventions

### C#/.NET

- Preserve the layer separation defined in `csharp-patterns.md` — a refactor is not a license to violate the dependency rules between the project's layers
- When moving domain logic to its corresponding layer, make sure the destination class does not break the dependency rules between layers
- Characterization tests in C# follow the same naming convention as `csharp-patterns.md` (`Scenario_ExpectedResult`) and use Moq to isolate dependencies, never a real database

### Angular

- Refactors that move logic from a component into a service must maintain the service coverage required by `angular-patterns.md`
- Template tests with `TestBed` remain non-mandatory after the refactor, per `angular-patterns.md`

### React

- Refactors that extract logic from a component into a custom hook make that hook subject to the mandatory testing defined in `react-patterns.md`, even if the original component had no test
- Purely visual components remain exempt from testing after the refactor

---

## Cross-reference

For language-specific naming conventions, file structure and test frameworks, see:

- `docs/knowledge/csharp-patterns.md`
- `docs/knowledge/angular-patterns.md`
- `docs/knowledge/react-patterns.md`

This document covers only **how to refactor safely**. The code conventions for the end result remain those of the documents above.
