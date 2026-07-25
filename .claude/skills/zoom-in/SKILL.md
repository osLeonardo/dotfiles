---
name: zoom-in
description: Restricts the agent's focus to a single repository in the multi-repo workspace. Use when the user wants the agent to work exclusively within one repository.
---

# Zoom In

Follow the steps below when this skill is invoked.

## 1. Identify the target repository

Use the argument passed by the user to resolve the repository. Accept:
- The exact directory name (e.g. `gym-app`)
- A partial name (e.g. `gym` → `gym-app`; if the prefix matches more than one repository, ask the user which one)

If no argument was provided **or** the repository cannot be identified with confidence, list the available repositories and ask the user which one to focus on before continuing.

## 2. Activate focus mode

Declare to the user which repository is in focus. From this moment on, adopt the following restrictions for the whole session:

- **Code reads:** only within `{root}/<repo>/`
- **Edits and creations:** only within `{root}/<repo>/`
- **Searches and grep:** restricted to the repository directory
- **Terminal commands:** run in the context of `{root}/<repo>/`

If the user asks for something that requires crossing into another repository, warn them explicitly before leaving focus.

## 3. Load local context

Read `{root}/<repo>/CLAUDE.md` if the file exists. It holds technical conventions, internal structure and local rules — use it as the primary reference while working in this repository.

## 4. Confirm the focus to the user

Reply confirming:
- The name of the repository in focus and its full path
- Its type (per the global CLAUDE.md)
- Whether the local CLAUDE.md was found and loaded

---

To end focus mode and return to the global view, the user must explicitly ask to switch repositories (which re-triggers this flow for the new target) or to return to the global/root folder.
