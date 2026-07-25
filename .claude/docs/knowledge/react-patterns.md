# React implementation rules and patterns

Global rules the agent must follow in any repository built with React. If a repository has specific rules in its `CLAUDE.md` that conflict with this document, the specific rules take precedence.

<!-- TODO -->

## Tests

<!-- TODO: confirm the test framework (Vitest is the default for Vite projects) and its configuration when adding the first suite -->

- **Mandatory** for all pure logic: custom hooks, utility functions, contexts holding state logic
- **Not mandatory** for purely visual components — the code review gate + manual validation cover them
- **Out of scope** for the agent: E2E tests (Cypress/Playwright) — handled outside the implementation flow
- File naming: `.spec.tsx` or `.test.tsx` in the same folder as the file under test
- Isolate dependencies with the test framework's mocks — never rely on real implementations of external services
