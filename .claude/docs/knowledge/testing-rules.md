# Testing rules

Global testing rules for every repository in the workspace. Complements `coding-rules.md` and takes precedence over it on anything related to tests. Repository-specific rules live in that repo's `CLAUDE.md` and take precedence over this document.

## Quick references

| What I need | What I must read |
|---|---|
| Write a test in C#/.NET | `docs/knowledge/csharp-patterns.md` |
| Write a test in Angular | `docs/knowledge/angular-patterns.md` |
| Write a test in React | `docs/knowledge/react-patterns.md` |

---

## What a good test is

A good test verifies **behavior** through the public interface, never implementation details.
The code can change completely; the test should not have to change with it.

A good test:

- describes **what** the system does, not **how** it does it
- survives refactoring — same observable behavior, the test stays green
- uses the vocabulary of the glossary (`CONTEXT.md`) of the Context under test
- has one logical assertion

---

## Test boundary

The **test boundary** is the public edge where behavior is observed without reaching into the
code's internals. Every test lives at a boundary.

The agent picks the boundary during implementation, and it reaches the user at the code review
gate along with everything else — the user disagrees there, with the code in front of them. It is
not a closed list approved up front: if the behavior to verify is only observable at a boundary
that was not anticipated, test it there.

Boundaries, from outermost to innermost:

- HTTP endpoint (controller or route handler)
- public method of an application service
- public method of a domain service or a validator
- frontend component or custom hook through its public API: props/inputs, outputs/callbacks,
  returned values, user interaction

Not boundaries: a private method, an internal collaborator, internal state, or the database
accessed from outside the interface.

Choosing the boundary well is what puts the testing effort on the behavior the user observes,
instead of spreading it across the code's internals. The boundary is never a reason to leave an
acceptance criterion untested: if the agreed behavior is only observable somewhere else, that
somewhere else is the right boundary.

---

## When to write a test

**Write one when the code answers yes to at least one of these:**

1. **Does it branch?** `if`, `switch`, ternary or null-check where the paths produce different results
2. **Does it transform a value?** Calculation, parsing, formatting, aggregation, sorting, conversion
3. **Does it decide on state?** Authorization, validation, limits, availability, eligibility
4. **Is it an edge contract consumed by another system?** Endpoint, payload, event, schema
5. **Is it the regression of a fixed bug?** Always, no exceptions

**Do not write one when all three are true:**

1. The body is a pass-through or delegation, with no decision of its own
2. The only possible failure is one the compiler already catches
3. The only possible assertion is "I verified that I called the mock"

**General detector:** if the test only breaks when the **shape** of the code changes, and never
when its **behavior** changes, do not write it.

---

## How many test cases

File layout and naming for each stack live in the `*-patterns.md` docs (see Quick references).
The question here is how many cases go in for a given method or unit.

**One case per distinct behavior of the method**, not one case per input combination. Two inputs
produce the same behavior when they go through the same decision path and lead to the same kind
of result — in that case, a single case.

When the behavior is identical and only the value changes, use a parameterized input (`it.each`
in Vitest/Jest, `[Theory]` with `InlineData` in xUnit) instead of several cases.

**An edge case goes in when it is the value where the behavior changes** — the limit itself
(e.g. the maximum number of exercises in a routine), a workout scheduled for today, the empty list
when empty is a valid business state.

**Edge cases by symmetry do not go in.** `null`, empty string and zero only become a case when the
domain admits that value at that point. A non-nullable parameter in an internal call gets no
`null` test.

---

## Anti-patterns

### Coupled to the implementation

Tests a private method, or verifies **only** that a dependency was called, without checking with
what data or what result came out. **The signal:** the test breaks on a refactor in which the
behavior did not change.

Verifying the mock is not the problem — it is part of the test. The problem is the empty
verification, which passes the same even when the value is wrong.

```ts
// BAD — only confirms the call; passes even with the wrong value
it('completeWorkout calls the repository', () => {
  service.completeWorkout(workout);
  expect(historyRepository.save).toHaveBeenCalledTimes(1);
});

// GOOD — checks the result and what was persisted
it('should_RecordTotalVolume_WhenWorkoutIsCompleted', () => {
  const entry = service.completeWorkout(workout); // 3 sets x 10 reps x 50 kg

  expect(entry.totalVolumeKg).toBe(1500);
  expect(historyRepository.save).toHaveBeenCalledWith(
    expect.objectContaining({ totalVolumeKg: 1500 }),
  );
});
```

### Tautological

The assertion recomputes the expected value the same way the code does, so the test passes by
construction and can never disagree with the implementation.

**This is the highest-risk anti-pattern when the test is written by an agent** — it has just
written the implementation and has the formula fresh in mind.

```ts
// BAD — the expected value is recomputed the way the code computes it
const expected = sets.reduce((sum, set) => sum + set.reps * set.weightKg, 0);
expect(calculateTotalVolume(sets)).toBe(expected);

// GOOD — the expected value is a known, independent literal
expect(calculateTotalVolume(sets)).toBe(900); // 10 x 50 + 8 x 50
```

The expected value comes from an independent source: a known literal, an example worked out by
hand, or the specification. **Never from the same calculation the implementation performs.**

### Side-channel verification

The test goes around the interface to check the result.

```ts
// BAD — reaches into the database from outside to verify
await service.createRoutine(routine);
const row = db.prepare('SELECT * FROM routines WHERE id = ?').get(routine.id);
expect(row).toBeDefined();

// GOOD — verifies through the interface itself
await service.createRoutine(routine);
const saved = await service.getRoutine(routine.id);
expect(saved.name).toBe(routine.name);
```

---

## Mocks

Mock the dependencies external to what is under test: repositories and database access, external
providers, other services' APIs, time, randomness, e-mail, queues and the file system. The mocking
tool for each stack is in its `*-patterns.md` — **a unit test never hits a real database**.

Verifying the interaction with the mock is part of the test. What is not enough is verifying
**only** the interaction, without checking the result (see *Coupled to the implementation*).
