# Branch Cleanup

Checkout `dev`, pull latest, and delete local and remote branches that have been merged (including squash-merged).

## Steps

1. Run `git branch --show-current` to check the current branch. If there are uncommitted changes, warn the user and abort.
2. Run `git checkout dev && git pull` to switch to dev and pull latest.
3. Run `git fetch --prune` to clean up stale remote tracking refs.
4. Find regular-merged local branches:
   ```
   git branch --merged dev | grep -v '^\*\|main\|dev\|prod'
   ```
   Delete these with `git branch -d <branch>`.
5. Find squash-merged local branches. For each remaining local branch (excluding `main`, `dev`, `prod`), check if it has a merged PR on GitHub:
   ```
   gh pr list --head <branch> --state merged --json number --jq 'length'
   ```
   If the count is > 0 and there are no open PRs, delete with `git branch -D <branch>` (squash-merged branches require `-D` since git doesn't recognise them as merged).
6. Find stale remote branches. List all remote branches excluding protected ones:
   ```
   git branch -r | grep 'origin/' | grep -v 'origin/main\|origin/dev\|origin/prod\|origin/HEAD'
   ```
   For each, check if its PR is merged and has no open PRs:
   ```
   gh pr list --head <branch> --state merged --json number --jq 'length'
   gh pr list --head <branch> --state open --json number --jq 'length'
   ```
   Delete any with merged PRs and no open PRs: `git push origin --delete <branch>`
7. Report a summary of what was deleted, grouped by local and remote.

## Rules

- Never delete `main`, `dev`, or `prod` branches.
- Use `-d` for regular-merged branches, `-D` for squash-merged branches (verified via `gh pr list --state merged`).
- Do not delete branches that have open PRs — always check with `gh pr list --head <branch> --state open` before deleting.
- If no branches need cleanup, say so.
