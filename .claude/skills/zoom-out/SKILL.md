---
name: zoom-out
description: Returns the agent's focus to the multi-repo root folder ({root}), ending any scope restriction set by zoom-in. Use when the user wants to leave focus mode on a specific repository and return to the global workspace view.
---

# Zoom Out

If a focus mode is active, end it and return the scope to the root folder — `{root}`, the parent directory of `.claude/` where the agent was started.

From now on:
- **Code reads:** may span any repository inside `{root}/`
- **Edits and creations:** may happen in any repository inside `{root}/`
- **Searches and grep:** unrestricted within `{root}/`
- **Terminal commands:** run in the context of `{root}/`

Confirm to the user that focus mode has ended and the scope is the full workspace again.
