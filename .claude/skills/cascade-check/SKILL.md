# Cascade Check Skill

Verify that a data-shape change (DTO, interface, enum, entity field, shared type) has been applied consistently across backend, admin frontend, and microsite frontend. This is the single step that prevents the #461-style "fixed in one place, broken in three others" cascade.

## When to run

- Before pushing a PR that touches any DTO, interface, enum, or shared type
- After renaming a field, changing a type, or altering a response shape
- When a bug report suggests layered data-shape drift (admin works, microsite broken — or vice versa)

## Inputs

Either:
- The user provides an identifier list (field names, enum values, type names): `/cascade-check personTypeBreakdown, countsForRinkAllocation`
- No args — derive identifiers from `git diff dev...HEAD` by extracting modified symbol names in changed TypeScript files

## Procedure

1. **Gather identifiers.** If not provided, run `git diff dev...HEAD -- '*.ts' '*.tsx'` and extract:
   - Field names added/removed from interfaces and DTO classes
   - Enum values added/removed
   - Renamed class/type names
   Present the list to the user and confirm before proceeding if it looks incomplete.

2. **Grep each identifier** across the monorepo (exclude `node_modules`, `dist`, `build`):
   ```
   rg -n "<identifier>" backend/src frontend/admin/src frontend/microsite/src
   ```

3. **Classify each hit:**
   - **Consistent** — file has been updated to match the new shape
   - **Stale** — still references the old shape and is likely broken
   - **Unrelated** — identifier is a homonym in a different context (string literal in test fixture, comment, etc.)

4. **Check shape parity across layers.** For DTO changes, specifically read:
   - The backend DTO class
   - The backend controller/service that constructs it
   - The frontend query hook that consumes it
   - The frontend component that renders it
   Confirm every field read on the frontend is present on the backend response, and vice versa.

5. **Report** in this format:
   ```
   Identifier: personTypeBreakdown
     Consistent: backend/src/bookings/dto/booking.dto.ts:42
     Stale:      frontend/microsite/src/booking/hooks.ts:88 (uses personTypeCounts)
     Unrelated:  backend/src/tests/fixtures/booking.fixture.ts:12 (string literal)
   ```

6. **Do not auto-fix.** List stale references and let the user decide scope. The goal is visibility, not silent edits — some stale references may be intentional (migration fallback, deprecation shim).

## Anti-patterns

- Running cascade-check only on the files you already edited (defeats the point)
- Treating test fixtures and migrations as "stale" without reading them — they often legitimately reference old shapes
- Relying on TypeScript compilation alone. `tsc` catches type errors but not semantic drift (e.g., backend returns `personTypeBreakdown` and frontend optional-chains `data?.personTypeCounts` which silently resolves to `undefined`)
