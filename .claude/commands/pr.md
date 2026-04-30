# Create PR

Create a pull request for the current branch targeting `dev`.

## Steps

1. Run `git branch --show-current` to confirm the current branch. Abort if on `dev` or `main`.
2. Run `git status` to check for uncommitted changes. If there are staged or unstaged changes, ask the user whether to commit them first.
3. Run `git log --oneline dev..HEAD` to summarize the commits that will be in this PR.
4. Run `git diff --stat dev..HEAD` to summarize files changed.
5. Push the branch: `git push -u origin $(git branch --show-current)`
6. Create the PR with `gh pr create --base dev`. Generate a concise title (under 70 chars) and body with:
   - `## Summary` — 1-3 bullet points derived from the commit log and diff
   - `## Test plan` — checklist of how to verify the changes
   - Attribution footer
7. Output the PR URL.

## Rules

- Always target `dev` unless the user specifies a different base branch via arguments.
- Never merge the PR automatically — only create it.
- If CI is mentioned in the arguments, wait for CI to pass using `gh pr checks --watch` before reporting success.

ARGUMENTS: $ARGUMENTS
