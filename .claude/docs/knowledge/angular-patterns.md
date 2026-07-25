# Angular implementation rules and patterns

Global rules the agent must follow in any repository built with Angular. If a repository has specific rules in its `CLAUDE.md` that conflict with this document, the specific rules take precedence.

<!-- TODO -->

## Tests

- **Mandatory** for all pure logic: services, pipes, guards, resolvers
- **Not mandatory** for components — template tests with `TestBed` are brittle and low value; the code review gate + manual validation cover them
- **Out of scope** for the agent: E2E tests (Cypress/Playwright) — handled outside the implementation flow
- Framework: Jasmine + Karma (configured by the Angular CLI — do not install alternative frameworks without approval)
- File naming: `name.service.spec.ts`, `name.pipe.spec.ts`, `name.guard.spec.ts`
- Test case naming: `should_ExpectedBehavior_WhenCondition`
  - e.g. `should_ReturnEmpty_WhenListIsNull`
- Isolate dependencies with `jasmine.createSpyObj` or stub providers in `TestBed` — never rely on real implementations of external services
- One `describe` per class; one `it` per verifiable behavior
- File structure: keep the `.spec.ts` in the same folder as the file under test
