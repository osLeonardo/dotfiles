# Select the step

Used by: `implement-task`, `refactor`.

```
IF the user specified a step (title, number or PRD file):
  1. Locate the step in `{root}/.claude/docs/prd/`
  2. Read the file
  3. IF all blockers have Status: Finished → move on to the skill's next step
     ELSE → show the menu (blocked steps marked as unavailable)
IF no step identified → show the menu
IF the user's request falls outside the step pattern → show the menu
```

**Menu format:**
```
Which step do you want to implement?

[context] <description of the out-of-pattern request>
          → <what the agent plans to do>

[01] <Title>
[02] <Title>

Blocked steps (unavailable):
  [03] <Title> — waiting on step 01
```

Execute only one step per invocation. Wait for the choice before continuing.
