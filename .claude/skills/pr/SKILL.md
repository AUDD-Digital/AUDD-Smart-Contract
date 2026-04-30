# Create PR Skill

1. Confirm current branch is a feature branch (never `dev` or `main`): `git branch --show-current`
2. Ensure all intended changes are committed: `git status`
3. **Cascade check for data-shape changes.** If the PR touches any DTO, interface, enum, entity field, or shared type:
   - List the changed identifiers
   - `grep -r` each one across `backend/`, `frontend/admin/`, `frontend/microsite/`
   - Confirm no stale references remain
4. Run `bun run check:fix` and commit any formatting fixes
5. Run the test suites relevant to the change:
   - Backend: `bun test` (or `bun run test:unit` + `bun run test:db` if DB tests are relevant)
   - Frontend: `bun run test:frontend`
   - Do not push if anything red — fix first
6. Push branch to origin: `git push -u origin HEAD`
7. Create PR into `dev`: `gh pr create --base dev --fill`
8. Report PR URL and wait for CI. If CI fails, fix locally and push a new commit (never `--no-verify` without noting the reason in the commit)
