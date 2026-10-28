# Close the step

Used by: `implement-task`, `refactor`.

Only after explicit approval of the code review gate:

- Change `Status: Implementing` → `Status: Finished` in the selected step's section in the PRD
- List every changed file
- IF the PRD still has another step with `Status: Pending` or `Implementing` → report what is left. ELSE → proceed to the Independent review below

## Independent review — end of the PRD

Runs when the finished step is the last one in the PRD (no other step with `Status: Pending` or `Implementing`).

1. Invoke the `code-reviewer` subagent (`{root}/.claude/agents/code-reviewer.md`), passing:
   - the PRD path
   - the consolidated list of files changed across **all** of the PRD's steps
   - the affected repositories
   - the paths of the applicable pattern docs (`coding-rules.md`, `testing-rules.md` + each stack's `*-patterns.md`)
2. Present the reviewer's return to the user **in full**, `BLOCKER` findings first, ending with its `VERDICT:` line. Do not filter or summarize. IF the verdict is `nothing to report` → say so and move on to item 4
3. **The user decides what becomes a fix** — do not fix anything on your own
4. Once the review is closed, suggest `document-task` to generate the issue closeout text / Pull Request body, followed by `git-process`

> The reviewer is read-only and runs with a clean context. It does not replace the tests — which have already passed at this point — but looks for what a green test run does not catch: adherence to the requirement, domain vocabulary and conceptual duplication across steps.
