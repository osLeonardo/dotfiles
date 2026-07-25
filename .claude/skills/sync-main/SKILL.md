---
name: sync-main
description: Syncs every git repository in the workspace to its main branch (main, or master as a fallback). Use this skill whenever the user wants to update all repos to the main branch, sync the whole workspace, do a bulk checkout, or make sure every repository is on an up-to-date main branch.
---

Run the script below and show its output to the user:

```bash
bash {root}/.claude/docs/scripts/sync-main.sh
```

IF the script does not exist at `.claude/docs/scripts/sync-main.sh` → tell the user and stop.

IF there are errors in the output → explain what failed in each repo and suggest corrective actions.
