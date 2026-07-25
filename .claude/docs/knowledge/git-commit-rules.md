# Commit rules

Standards and conditions for creating commits across all repositories in the workspace.

---

## Conditions for committing

Only commit when:

- The build passes with no errors
- All tests pass
- The committed functionality is complete (no half-finished implementation)

---

## Message format

```
#<issue> <what was implemented> — <why it was implemented>
```

When there is no linked issue (one-off tweaks in `dotfiles`, notes in
`SecondBrain`, etc.), omit the prefix:

```
<what was implemented> — <why it was implemented>
```

The message must be self-contained: another developer or agent should understand
the reason for the change by reading the commit alone, without consulting the
author or additional documentation.

> The `#<issue>` prefix is recognized by GitHub and becomes an automatic link to
> the corresponding issue.

---

## Closing issues

To close the issue automatically when the PR is merged, use a GitHub keyword in
the **PR body** (not in the commit, to avoid closing it prematurely):

```
Closes #42
```

---

## Rules

- **Atomic commits** — prefer several small, cohesive commits over one large commit with unrelated changes
- **Be brief** — the issue and the PRD exist for deep context; the commit describes the intent of the change

---

## Examples

```
#42 add max-load validation to the set form — the field accepted negative values
#57 extract progression logic into ProgressionCalculator — makes it mockable in routine tests
adjust Neovim window keybinds — they clashed with the Alacritty split shortcut
```
