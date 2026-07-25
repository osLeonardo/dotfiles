#!/bin/bash
# Syncs every git repo under {root} to main or master.
# Automatically stashes uncommitted changes before switching branches.

ROOT_DIR="$(cd "$(dirname "$0")/../../../" && pwd)"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

UPDATED=()
STASHES=()
ERRORS=()

mapfile -t REPOS < <(find "$ROOT_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

TOTAL=${#REPOS[@]}
N=0

for REPO_PATH in "${REPOS[@]}"; do
  [ ! -d "$REPO_PATH/.git" ] && continue

  REPO=$(basename "$REPO_PATH")
  N=$((N + 1))

  # Detect the main branch
  if git -C "$REPO_PATH" show-ref --verify --quiet refs/heads/main 2>/dev/null; then
    BRANCH="main"
  elif git -C "$REPO_PATH" show-ref --verify --quiet refs/heads/master 2>/dev/null; then
    BRANCH="master"
  else
    ERRORS+=("$REPO → main branch not found")
    echo "[$N] $REPO ... ✗ main branch not found"
    continue
  fi

  # Stash if there are changes
  if [ -n "$(git -C "$REPO_PATH" status --porcelain 2>/dev/null)" ]; then
    STASH_MSG="sync-main: $REPO - $TIMESTAMP"
    if git -C "$REPO_PATH" stash push --include-untracked -m "$STASH_MSG" > /dev/null 2>&1; then
      STASH_REF=$(git -C "$REPO_PATH" stash list | head -1 | cut -d: -f1)
      STASHES+=("$REPO → $STASH_REF | restore with: git -C \"$REPO_PATH\" stash pop")
      echo "[$N] $REPO ... stash created ($STASH_REF)"
    else
      ERRORS+=("$REPO → failed to create stash")
      echo "[$N] $REPO ... ✗ failed to create stash"
      continue
    fi
  fi

  # Check out the main branch if needed
  CURRENT=$(git -C "$REPO_PATH" branch --show-current 2>/dev/null)
  if [ "$CURRENT" != "$BRANCH" ]; then
    if ! git -C "$REPO_PATH" checkout "$BRANCH" > /dev/null 2>&1; then
      ERRORS+=("$REPO → failed to switch to $BRANCH")
      echo "[$N] $REPO ... ✗ failed to switch to $BRANCH"
      continue
    fi
  fi

  # Pull
  if git -C "$REPO_PATH" pull > /dev/null 2>&1; then
    UPDATED+=("$REPO")
    echo "[$N] $REPO ... ✓ updated"
  else
    ERRORS+=("$REPO → pull failed")
    echo "[$N] $REPO ... ✗ pull failed"
  fi
done

echo ""

if [ ${#ERRORS[@]} -eq 0 ] && [ ${#STASHES[@]} -eq 0 ]; then
  echo "✓ ${#UPDATED[@]} repositories updated."
  exit 0
fi

echo "=== Updated (${#UPDATED[@]}) ==="
for r in "${UPDATED[@]}"; do echo "  $r"; done

if [ ${#STASHES[@]} -gt 0 ]; then
  echo ""
  echo "=== Stashes created (${#STASHES[@]}) ==="
  for s in "${STASHES[@]}"; do echo "  $s"; done
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo ""
  echo "=== Errors (${#ERRORS[@]}) ==="
  for e in "${ERRORS[@]}"; do echo "  $e"; done
  exit 1
fi
