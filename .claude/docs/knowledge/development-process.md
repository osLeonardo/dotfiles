# Development process

Reference document on how work flows through this workspace: task tracking,
development flow and use of Claude Code. The agent should read it whenever there
is doubt about the process or when it needs to determine which skill applies at a
given moment.

---

## Tools

### GitHub Issues

All work tracking happens in **GitHub Issues**, in the corresponding repository.
It is the source of truth for what is pending, in progress and done.

**Organization:**

| Resource | Use |
|---|---|
| **Issue** | Unit of work. Describes the problem or desired functionality and its acceptance criteria |
| **Labels** | Classify the issue: `feature`, `bug`, `chore`, `refactor`, `docs`, `hotfix` |
| **Milestone** | Groups issues related to a larger goal (e.g. a release, an epic) |
| **Pull Request** | Links the code to the issue. Closes the issue automatically via `Closes #<n>` in the body |

Issues too large for a single branch should be broken into smaller issues before
implementation starts.

The `gh` CLI is the preferred way to interact with issues and PRs:

```bash
gh issue list --state open
gh issue view 42
gh pr create --fill
```

---

## Development flow

### Overview

```
  Starting a task
  ├── Read the issue (gh issue view <n>) or paste the description into the chat
  ├── plan-task  → collaborative planning with Claude
  └── spec-task  → generates the PRD with implementation steps

  Implementation
  ├── git-process → creates the working branch from main
  ├── implement-task (one step at a time)
  ├── agent-implement-prd → parallel step execution via subagents
  ├── document-task → generates the issue closeout text / PR body
  ├── Session interrupted → handoff → a new session resumes
  └── Parallel steps (manual) → multiple terminals with independent sessions

  Closing out
  ├── git-process → tests, push and Pull Request creation
  └── Merging the PR closes the issue automatically

  ONGOING (independent of any issue)
  ├── add-test → retroactive unit test coverage
  └── refactor → infra improvements and pure refactors
```

### Detailed walkthrough

**1. Starting a task**

Read the issue (`gh issue view <n>`) or paste the description straight into the
chat, then start a session with the `plan-task` skill. Claude asks questions
about every aspect of the task, explores the codebase, updates `CONTEXT.md` and
proposes ADRs when needed. At the end of planning, invoke the `spec-task` skill,
which synthesizes the conversation and generates the **PRD** — a single file
containing the requirements document and the partitioned implementation steps.

> The PRD is stored locally in `.claude/docs/prd/`. It is not committed or shared
> automatically.

**2. Implementation**

Invoke the `implement-task` skill for each step of the PRD. The flow follows
mandatory TDD:
1. Claude proposes the test scenarios → you approve (**Gate 1**)
2. Claude writes the tests (Red) → writes the minimum code (Green) → refactors (Refactor)
3. Claude runs all tests in the affected repositories
4. Claude presents a summary of what was implemented → you approve (**Gate 2**)
5. The step is marked as finished in the PRD

Steps with no dependency between them can be implemented in parallel in two ways:

- **Orchestrated:** invoke `agent-implement-prd` passing the PRD. The agent identifies which steps can run simultaneously, dispatches a subagent (`step-agent`) for each, and only notifies you when a gate requires a decision. The subagents pause autonomously at architectural gates, Gate 1 (test cases) and Gate 2 (code review).
- **Manual:** open multiple terminals, each with an independent Claude Code session running `implement-task`, all reading the same PRD from disk.

**3. Interrupted sessions**

When a session must end before the work is complete, invoke the `handoff` skill,
passing the goal of the next session as an argument. The generated document
compacts the current state so a new agent can continue. When resuming, ask Claude
to read the handoff and the corresponding PRD before continuing.

**4. Closing out**

With all steps complete, use `git-process` to run the tests, push the branch and
open the Pull Request. Invoke `document-task` to generate the text describing
what was done — use it as the PR body or as a closing comment on the issue.
Include `Closes #<issue>` in the PR body so the issue closes automatically on
merge.

**5. Bug fixing**

Bugs get their own issue with the `bug` label. Use the `bug-fix` skill: the flow
is similar to `implement-task` but calibrated for correction — it takes the
problem description, recovers context from the original session's handoff and PRD
when they exist, confirms the scope, and implements using TDD.

**6. Hotfix**

The process with Claude is identical to a normal feature (plan → spec →
implement). The only difference is the branch label (`hotfix/...`) and the merge
priority.

---

## Available skills

| Skill | When to use |
|---|---|
| `plan-task` | To start planning a task. The first skill to invoke in a new development session |
| `spec-task` | After planning, to generate the PRD with implementation steps |
| `implement-task` | To implement each PRD step individually |
| `agent-implement-prd` | To execute multiple PRD steps in parallel via subagents, notifying you only when a gate requires a decision |
| `bug-fix` | To fix bugs reported in issues |
| `refactor` | For pure refactors with no new feature (e.g. infra improvements) |
| `add-test` | To increase unit test coverage in modules without coverage, independent of any issue |
| `document-task` | To generate the issue closeout text / PR body at the end of an implementation |
| `git-process` | To create a branch, commit, run tests, push and open the PR |
| `handoff` | To compact a session's context and pass it to another |
| `sync-main` | To update every repository in the workspace to its main branch |
| `zoom-in` / `zoom-out` | To restrict or release the agent's focus to a single repository |

---

## Supporting documentation

All knowledge documentation lives in `.claude/docs/knowledge/`. Files are loaded
on demand — not all at once. The global `CLAUDE.md` and each repository's
`CLAUDE.md` indicate which files to read in each situation.

| Document | Contents |
|---|---|
| `coding-rules.md` | Global implementation rules, TDD, code style |
| `csharp-patterns.md` | Patterns for C#/.NET repositories |
| `angular-patterns.md` | Patterns for Angular repositories |
| `react-patterns.md` | Patterns for React repositories |
| `ui-ux-patterns.md` | Frontend styling patterns |
| `git-branch-rules.md` | Branch naming and flow |
| `git-commit-rules.md` | Commit format and conditions |
| `refactor-patterns.md` | Best practices for safe refactoring |

---

## Rules the agent must always respect

- **Never commit or push directly to `main`/`master`**
- **Never run `push --force`** without explicit approval
- **Never delete branches from the origin**
- **Never open or merge a Pull Request** without explicit user confirmation
- **Never mark a step as finished without all tests passing**
- **Never install or update packages without explicit user approval**
- **Never make architectural decisions without user approval** — propose an ADR and wait
- **Always communicate in English** unless explicitly instructed otherwise
- **Always stop and consult the user** before removing files, making breaking changes, or any irreversible action

---

## Frequently asked questions

**Where do I start when I pick up an issue?**
Read the issue with `gh issue view <n>` (or paste the description into the chat)
and start a session with the `plan-task` skill. It will guide the planning by
asking questions about the task.

**Do I need to create the PRD manually?**
No. The PRD is generated automatically by the `spec-task` skill at the end of
planning with `plan-task`.

**How does parallel implementation work?**
Two ways. The recommended one is `agent-implement-prd`: pass the PRD as an
argument and it dispatches a subagent for each independent step, notifying you
only when a gate requires a decision. Alternatively, open a terminal per step
manually — each terminal has its own independent Claude Code session, all reading
the same PRD from disk.

**What do I do when a session gets interrupted?**
Invoke the `handoff` skill, passing the focus of the next session as an argument.
In the following session, ask Claude to read the handoff and the PRD before
continuing.

**How do I document what was done?**
Invoke `document-task`. It synthesizes what was implemented in the session —
using the conversation context, handoffs, ADRs and the PRD as sources — and
generates a file in `.claude/docs/tasks/` ready to paste as the PR body or an
issue comment.

**The repository I'm working in has no tests. What do I do?**
Claude writes tests for any new code it creates. For existing code without
coverage, use the `add-test` skill — it is independent of any issue and can be
run at any time.

**Where are the code patterns Claude should follow?**
In `.claude/docs/knowledge/`. Each `CLAUDE.md` (global and per repository)
indicates which files to read in each situation — you don't need to point them
out manually.
