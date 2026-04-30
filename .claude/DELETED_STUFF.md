# Deleted AI Tooling Artifacts

**Date**: 2026-02-12
**Reason**: FSCO-specific content copied to audc that references wrong tech stack (Angular 20, PrimeNG, Keycloak, GitLab) instead of actual audc stack (React, NestJS, Better Auth, GitHub).

---

## Deleted Rules Files

All from `product/.claude/rules/` and `product/.cursor/rules/`:

### 1. `agent-instructions.mdc` (alwaysApply: true)
- Referenced Angular 20, PrimeNG 20, Keycloak, Signals-first state management
- None of these exist in audc (it uses React, Radix UI, Better Auth, Zustand)
- Replaced by: `product/CLAUDE.md`

### 2. `project-structure.mdc`
- Listed tech stack as Angular 20.1.7, PrimeNG 20.0.1, @primeuix/themes, Tailwind CSS 4.1.4, GitLab CI/CD, Keycloak
- audc actually uses: React 18, Radix UI, Tailwind CSS 3.4, GitHub Actions, Better Auth
- Replaced by: `product/CLAUDE.md`

### 3. `app-bff-patterns.mdc`
- Pointed to `docs/app-bff-guidelines.md` which does NOT exist in audc
- Referenced `nest generate` commands (correct tool but docs were missing)
- Replaced by: Backend Patterns section in `product/CLAUDE.md`

### 4. `app-frontend-patterns.mdc`
- Referenced Angular (Customer B2C) with PrimeNG 20, standalone components, @primeuix/themes
- Referenced `frontend/react/dApp` and `frontend/react/sysadmin` directories (FSCO paths, don't exist in audc)
- audc frontend is at `frontend/admin/`
- Replaced by: Frontend Patterns section in `product/CLAUDE.md`

### 5. `feature-flags-patterns.mdc`
- FSCO-specific LINE → SEGMENT → FEATURE pattern with colon separators
- Referenced `docs/feature-flags-guidelines.md` which does NOT exist in audc
- Referenced `shared/src/libs/constants/feature-flags/` (FSCO path)
- audc uses Vite env vars (`VITE_FEATURE_*`) for feature flags

### 6. `infrastructure-deployment.mdc`
- Pointed to `docs/infrastructure-deployment.md` which does NOT exist in audc
- audc has `docs/infrastructure-guidelines.md` (different name, different content)
- Replaced by: Infrastructure section in `product/CLAUDE.md` + `product/README.md`

### 7. `cursor-rules.mdc`
- Meta-instructions for creating Cursor rules
- Referenced `docs/documentation-summary.md` which does NOT exist in audc
- Referenced Angular guidelines pattern throughout
- Generic enough concept but all examples and references were FSCO-specific

---

## Removed from settings.local.json

### Leaked Secrets (CRITICAL)

```
# Pulumi config passphrase (appeared 10+ times)
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-dev AWS_REGION=ap-southeast-2 bunx pulumi:*)"
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-dev AWS_REGION=ap-southeast-2 bunx pulumi up:*)"
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-dev AWS_REGION=ap-southeast-2 bunx pulumi import:*)"
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-dev AWS_REGION=ap-southeast-2 bunx pulumi import aws:ssm/parameter:Parameter dev-ssm-betterAuthSecret /dev/better-auth/secret --yes)"
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-prod AWS_REGION=ap-southeast-2 bunx pulumi:*)"
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-prod AWS_REGION=ap-southeast-2 bunx pulumi up:*)"
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-prod AWS_REGION=ap-southeast-2 bunx pulumi import aws:ssm/parameter:Parameter prod-ssm-dbPassword /prod/database/password --yes)"
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-prod AWS_REGION=ap-southeast-2 bunx pulumi import:*)"
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-prod AWS_REGION=ap-southeast-2 bunx pulumi stack:*)"
"Bash(PULUMI_CONFIG_PASSPHRASE='Utopia.audc@2026' AWS_PROFILE=audc-prod AWS_REGION=ap-southeast-2 bunx pulumi preview)"
"Bash(AWS_PROFILE=audc-prod AWS_REGION=ap-southeast-2 bunx pulumi login:*)"
"Bash(AWS_PROFILE=audc-dev AWS_REGION=ap-southeast-2 bunx pulumi:*)"

# RDS database password
"Bash(PGPASSWORD='1ofmnBD45f8qGTM4oEfacI84zOr9z9ln' /opt/homebrew/opt/libpq/bin/psql -h dev-db.c3wcm48kus5n.ap-southeast-2.rds.amazonaws.com -U dev_audc -d postgres -c \"SELECT datname FROM pg_database;\")"
"Bash(PGPASSWORD='1ofmnBD45f8qGTM4oEfacI84zOr9z9ln' /opt/homebrew/opt/libpq/bin/psql:*)"

# Inline DB credentials
"Bash(DB_HOST=localhost DB_PORT=65432 DB_USERNAME=postgres DB_PASSWORD=changeme DB_DATABASE=audc-app bun run:*)"
"Bash(STAGE=local DB_HOST=localhost DB_PORT=5433 DB_USERNAME=test DB_PASSWORD=test DB_DATABASE=audc_test REDIS_HOST=localhost REDIS_PORT=6380 RUN_DB_TESTS=true bun test:*)"
```

### Stale One-Off Entries

```
# Inline sed commands (one-time refactoring)
"Bash(while read file)"
"Bash(do sed -i \"s|from ''''../base/index''''|from ''''../base/auditable.entity''''|g\" $file sed -i \"s|from ''''../base/auditable.entity''''|from ''''../base/soft-deletable.entity''''|g\" $file)"
"Bash({} +)"

# For loop fragments
"Bash(for module in facilities bookings payments seasons memberships users addons functions)"
"Bash(do echo \"=== $module ===\")"
"Bash(done)"
"Bash(do echo '=== $module ===')"
"Bash(do)"

# Specific file list loops
"Bash(for f in OnlineBookingsSettingsDialog.tsx PricingConfig.tsx PricingManager.tsx SessionBuilderOnboarding.tsx SessionBuilderTab.tsx SessionDurationConfig.tsx SessionDurationManager.tsx SessionIntervalFlow.tsx SessionPreviewModal.tsx SessionScheduleBuilderNew.tsx SessionScheduleManager.tsx)"

# Specific file path approvals (one-off)
"Bash(backend/src/datastore/entities/clubs/club-settings.entity.ts )"
"Bash(backend/src/datastore/entities/clubs/club.entity.ts )"
"Bash(backend/src/datastore/entities/clubs/index.ts )"
"Bash(backend/src/datastore/entities/clubs/pricing-tier.entity.ts )"
"Bash(backend/src/datastore/entities/clubs/session-duration-price.entity.ts )"
"Bash(backend/src/datastore/entities/facilities/session-duration.entity.ts )"
"Bash(backend/src/datastore/migrations/1734430000000-AddPricingTiersAndClubSettings.ts )"
"Bash(backend/src/modules/clubs/clubs.module.ts )"
"Bash(backend/src/modules/clubs/controllers/clubs.controller.ts )"
"Bash(backend/src/modules/clubs/dto/club-settings.response.dto.ts )"
"Bash(backend/src/modules/clubs/dto/pricing-tier.dto.ts )"
"Bash(backend/src/modules/clubs/dto/session-time.dto.ts )"
"Bash(backend/src/modules/clubs/dto/update-club-settings.dto.ts )"
"Bash(backend/src/modules/clubs/services/pricing-tier.service.ts )"
"Bash(backend/src/modules/clubs/services/session-time.service.ts)"
"Bash(frontend/admin/src/types/v2.ts )"
"Bash(frontend/admin/src/hooks/useClubSettings.ts )"
"Bash(frontend/admin/src/hooks/usePricingTiers.ts )"
"Bash(frontend/admin/src/hooks/useSessionTimes.ts)"

# Specific UUID/ID approvals
"Bash(CLUB_ID=\"dd9247f6-8b93-43f4-9ca0-941a146a1bb1\":*)"
"Bash(GREEN_ID=\"fae66c8e-55dc-489c-bcb6-56b19badbc4c\")"

# Specific worktree/branch loops
"Bash(for branch in december-update discovery-home feature/calendar-backend-integration feature/calendar-frontend-integration feature/chatgpt-nlp-integration feature/testing-infrastructure)"
"Bash(for wt in /Users/hamer/developer/work/audc/product-backend /Users/hamer/developer/work/audc/product-chatgpt-nlp /Users/hamer/developer/work/audc/product-frontend /Users/hamer/developer/work/audc/product-testing)"
"Bash(do echo '=== $wt ===' git -C $wt status --short)"
"Bash(do echo '=== $wt ===' git -C $wt log --oneline -1 2)"
"Bash(/dev/null git -C $wt diff --stat)"
"Bash(git -C /Users/hamer/developer/work/audc/product-testing merge february-update)"

# Specific ECS log stream commands
"Bash(for stream in \"ecs/api/42c94e29c3094cdbb88b368fb3cf21ed\" \"ecs/api/2a48002e51bc407ea3da6b513a91cd8c\")"
"Bash(do echo \"=== STREAM: $stream ===\" aws logs get-log-events --log-group-name /ecs/dev-api --log-stream-name \"$stream\" --start-from-head --limit 30 --region ap-southeast-2 --profile audc-dev --query 'events[*].message' --output json)"

# Large GitHub branch protection JSON heredocs (3 variants)
"Bash(1 <<'EOF'\n{\n  \"name\": \"Protect prod\", ...})"  # 3 nearly-identical entries

# Stale SlashCommand entries (now Skills)
"SlashCommand(/create_plan UI to API Integration - Complete frontend-backend connection for all services and components)"
"SlashCommand(/create_plan:*)"

# AWS-specific one-offs
"Bash(AWS_PROFILE=audc-dev aws ssm delete-parameter:*)"
"Bash(AWS_PROFILE=audc-dev aws acm describe-certificate:*)"
"Bash(AWS_PROFILE=audc-dev aws route53 change-resource-record-sets:*)"
"Bash(AWS_PROFILE=audc-dev aws acm list-certificates:*)"
"Bash(AWS_PROFILE=audc-management aws route53:*)"
"Bash(AWS_PROFILE=audc aws route53:*)"
"Bash(AWS_PROFILE=audc-sso aws route53:*)"
"Bash(AWS_PROFILE=audc-prod aws sts:*)"
"Bash(AWS_PROFILE=audc-prod aws s3 ls:*)"
"Bash(AWS_PROFILE=audc-dev aws s3:*)"
"Bash(AWS_PROFILE=audc-prod aws s3:*)"

# WebFetch for specific domains (one-off research)
"WebFetch(domain:tkdodo.eu)"
"WebFetch(domain:leapcell.io)"
"WebFetch(domain:www.reactlibraries.com)"

# Miscellaneous one-offs
"Bash([ ! -f .env ])"
"Bash(TS_NODE_PROJECT=tsconfig.migration.json bun run migration:generate:*)"
"Bash(TS_NODE_PROJECT=tsconfig.migration.json bun run:*)"
"Bash(env STAGE=local ENABLE_WEBSOCKET=true timeout 15 bun run src/main.ts)"
"Bash(STAGE=local timeout 15 bun run:*)"
"Bash(STAGE=local timeout 30 bun run:*)"
"Bash(npx @nestjs/cli build:*)"
"Bash(npx jest:*)"
"Bash(npx eslint:*)"
"Bash(npx vite build:*)"
"Bash(bunx @better-auth/cli migrate:*)"
"Bash(tee:*)"
"Bash(awk:*)"
"Bash(xargs ls:*)"
"Bash(xargs cat:*)"
"Bash(xargs basename:*)"
"Bash(xargs kill:*)"
"Bash(docker builder prune:*)"
"Bash(docker network inspect:*)"
"Bash(docker-compose config:*)"
"Bash(npm install:*)"
"Bash(npm run build:*)"
"Bash(npm run build:backend:*)"
"Bash(npm run typecheck:*)"
"Bash(npm run type-check:*)"
"Bash(npm run lint:*)"
"Bash(npm run migration:run:*)"
"Bash(npx nest build)"
"Bash(npx tsc-alias:*)"
"Bash(node --check:*)"
"Bash(node -e:*)"
"Bash(bun -e:*)"
"Bash(bun run schema:generate:*)"
"Bash(bun run typeorm:*)"
"Bash(bun typeorm:*)"
"Bash(bun run migration:generate:*)"
"Bash(test:*)"
```

### What Was Consolidated

The 221 entries above were replaced with 58 clean wildcard patterns. Key consolidations:

| Before (multiple entries) | After (single wildcard) |
|--------------------------|------------------------|
| `docker ps`, `docker logs`, `docker start`, `docker exec`, `docker restart`, `docker inspect`, `docker network inspect`, `docker builder prune`, `docker compose up`, `docker compose ps`, `docker compose build` | `Bash(docker:*)` + `Bash(docker compose:*)` |
| `git add`, `git commit`, `git push`, `git pull`, `git log`, `git stash`, `git stash pop`, `git diff`, `git branch`, `git merge`, `git rebase`, `git cherry-pick`, `git fetch`, `git checkout`, `git status`, `git reset`, `git rev-parse`, `git worktree`, `git remote prune`, `git remote set-head` | `Bash(git:*)` |
| `gh pr create`, `gh pr view`, `gh pr merge`, `gh pr list`, `gh pr close`, `gh pr checks`, `gh auth`, `gh api`, `gh repo view`, `gh secret list`, `gh variable list`, `gh secret set`, `gh variable set`, `gh run view`, `gh run list`, `gh run watch`, `gh workflow run` | `Bash(gh:*)` |
| `bun run`, `bun test`, `bun add`, `bun install`, `bun seed`, `bun dx start`, `bun seed:superadmin`, `bun check`, `bun biome check`, `bun remove`, `bun run typeorm`, `bun typeorm`, `bun run migration:generate`, `bun run schema:generate` + env-prefixed variants | `Bash(bun:*)` + `Bash(bun run:*)` etc. |
| 10+ `AWS_PROFILE=audc-dev aws ...` variants | `Bash(AWS_PROFILE=audc-dev:*)` |
| 10+ `PULUMI_CONFIG_PASSPHRASE=... bunx pulumi` variants | **REMOVED** (secrets) |

---

## Action Items

- [ ] **Rotate Pulumi passphrase** (`Utopia.audc@2026`) - it was exposed in settings.local.json
- [ ] **Rotate RDS password** (`1ofmnBD45f8qGTM4oEfacI84zOr9z9ln`) - it was exposed in settings.local.json
- [ ] Consider storing Pulumi passphrase in a `.env` file or keychain instead of inline commands
- [ ] Review `docs/app-frontend-angular-guidelines.md` in audc - likely also copied from FSCO and irrelevant
