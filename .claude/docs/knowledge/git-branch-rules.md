# Branch rules

Naming, creation and management conventions for branches across all repositories in the workspace.

---

## Model in use

Linear flow with a single main branch (`main`):

```
main ──┬──────────────────────────────► main
       └── feature/42-rest-timer-fix ──► Pull Request
```

- Every change starts from `main` and returns to `main` via a **Pull Request** on GitHub.
- There are no `develop` or `release/*` branches, no consolidation branches, and no cherry-pick propagation.
- Working branches are ephemeral: created for an issue, merged, and deleted.

> Some repositories may use `master` instead of `main`. The scripts detect
> automatically which one exists (`GS_MAIN_CANDIDATES` in `lib/config.sh`).

---

## Branch types

| Type | Purpose |
|---|---|
| `feature` | New functionality, improvement or refactor |
| `hotfix` | Urgent fix for something already in production |

Both start from `main`. The distinction is semantic — it signals priority on the
PR, it does not change the base.

---

## Naming

| Situation | Pattern |
|---|---|
| With a linked issue | `feature/<issue>-<slug>` |
| Without a linked issue | `feature/<slug>` |
| Hotfix with an issue | `hotfix/<issue>-<slug>` |
| Hotfix without an issue | `hotfix/<slug>` |

- `<issue>` — the GitHub issue number (e.g. `42`)
- `<slug>` — short kebab-case description (e.g. `rest-timer-fix`)

Examples:

```
feature/42-export-routine-json
feature/eslint-config-cleanup
hotfix/57-fix-crash-on-save
```

---

## Creating a branch

```bash
git checkout main
git pull --rebase origin main
git checkout -b feature/<issue>-<slug>
```

Or, via the `git-process` skill (recommended — it validates preconditions):

```bash
bash {root}/.claude/docs/scripts/git-process/git-create-branch.sh \
  --flow normal --issue 42 --slug rest-timer-fix
```

> The script requires you to be on `main` and for it to be up to date with the
> remote. Uncommitted changes in the working tree are carried over to the new
> branch.

---

## Pushing and integrating

```bash
git push -u origin feature/<issue>-<slug>
gh pr create --fill
```

After the PR is merged, clean up the local branch:

```bash
git checkout main
git pull --rebase origin main
git branch -d feature/<issue>-<slug>
```

---

## Constraints

The agent is expressly forbidden from:

- **Committing directly to `main`/`master`** — every change goes through a working branch
- **Pushing directly to `main`/`master`** — the main branch only receives code via Pull Request
- **Deleting branches directly from the origin** — no `git push origin --delete` is permitted under any circumstance
- **Running `push --force` on any branch** without explicit user approval
