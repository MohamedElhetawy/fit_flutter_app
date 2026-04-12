# FitX — CI/CD Pipeline

**Version:** 1.0.0  
**Platform:** GitHub Actions

---

## 1. Pipeline Overview

```
Developer Push / PR
        │
        ▼
┌───────────────────┐
│   CI Pipeline     │  ← Runs on every push and PR
│   (~8 minutes)    │
│                   │
│  1. Checkout      │
│  2. Install deps  │
│  3. Type check    │
│  4. Lint          │
│  5. Unit tests    │
│  6. Build         │
│  7. Security scan │
└─────────┬─────────┘
          │ Pass
          ▼
  ┌───────────────┐
  │  PR Approved? │
  └───────┬───────┘
          │ Yes
          ▼
┌───────────────────┐
│  CD — Staging     │  ← Auto-deploy to staging on merge to develop
│   (~5 minutes)    │
│                   │
│  1. Build Docker  │
│  2. Push to GHCR  │
│  3. Deploy to Fly │
│  4. DB migrate    │
│  5. Smoke tests   │
│  6. Notify Slack  │
└─────────┬─────────┘
          │
          ▼ Manual approval gate
┌───────────────────┐
│  CD — Production  │  ← Merge to main + manual approval
│   (~7 minutes)    │
│                   │
│  1. Build Docker  │
│  2. Push to GHCR  │
│  3. Blue/green    │
│     deploy to Fly │
│  4. DB migrate    │
│     (zero-downtime│
│      with Prisma) │
│  5. Smoke tests   │
│  6. Canary 5%     │
│  7. Monitor 10min │
│  8. Full rollout  │
│  9. Notify Slack  │
└───────────────────┘
```

---

## 2. GitHub Actions Workflows

### workflow: ci.yml

```yaml
name: CI

on:
  push:
    branches: ['*']
  pull_request:
    branches: [main, develop]

jobs:
  # ─── Backend CI ───────────────────────────────────────────────
  backend-ci:
    name: Backend CI
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
          POSTGRES_DB: fitx_test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:7-alpine
        options: >-
          --health-cmd "redis-cli ping"
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      - name: Install dependencies
        run: npm ci
        working-directory: backend
      - name: Type check
        run: npm run type-check
        working-directory: backend
      - name: Lint
        run: npm run lint
        working-directory: backend
      - name: Run migrations
        run: npx prisma migrate deploy
        working-directory: backend
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/fitx_test
      - name: Unit tests
        run: npm run test:unit -- --coverage
        working-directory: backend
        env:
          DATABASE_URL: postgresql://postgres:test@localhost:5432/fitx_test
          REDIS_URL: redis://localhost:6379
      - name: Integration tests
        run: npm run test:integration
        working-directory: backend
      - name: Upload coverage
        uses: codecov/codecov-action@v4

  # ─── Mobile CI ────────────────────────────────────────────────
  mobile-ci:
    name: Mobile CI
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: mobile/package-lock.json
      - name: Install dependencies
        run: npm ci
        working-directory: mobile
      - name: Type check
        run: npm run type-check
        working-directory: mobile
      - name: Lint
        run: npm run lint
        working-directory: mobile
      - name: Unit tests
        run: npm run test -- --coverage
        working-directory: mobile
      - name: Build JS bundle (Android)
        run: npm run build:android
        working-directory: mobile

  # ─── Security Scan ────────────────────────────────────────────
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Semgrep
        uses: returntocorp/semgrep-action@v1
        with:
          config: p/nodejs p/typescript p/owasp-top-ten
      - name: Audit npm dependencies
        run: |
          npm audit --audit-level=high
          cd backend && npm audit --audit-level=high
          cd ../mobile && npm audit --audit-level=high
```

### workflow: deploy-staging.yml

```yaml
name: Deploy to Staging

on:
  push:
    branches: [develop]

jobs:
  deploy-backend-staging:
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Setup Doppler
        uses: dopplerhq/cli-action@v3
        with:
          doppler-token: ${{ secrets.DOPPLER_TOKEN_STAGING }}
      - name: Build Docker image
        run: docker build -t ghcr.io/fitx/api:staging-${{ github.sha }} ./backend
      - name: Push to GHCR
        run: |
          echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker push ghcr.io/fitx/api:staging-${{ github.sha }}
      - name: Deploy to Fly.io (staging)
        uses: superfly/flyctl-actions@1.5
        with:
          args: "deploy --image ghcr.io/fitx/api:staging-${{ github.sha }} --app fitx-api-staging"
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
      - name: Run DB migrations
        run: doppler run -- npx prisma migrate deploy
        env:
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN_STAGING }}
      - name: Smoke tests
        run: npm run test:smoke -- --env=staging
        working-directory: backend
      - name: Notify Slack
        uses: slackapi/slack-github-action@v1
        with:
          payload: '{"text": "✅ Staging deployed: ${{ github.sha }}"}'
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### workflow: deploy-production.yml

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy-production:
    runs-on: ubuntu-latest
    environment: production  # Requires manual approval in GitHub Environments
    steps:
      - uses: actions/checkout@v4
      - name: Build production image
        run: docker build -t ghcr.io/fitx/api:${{ github.sha }} ./backend
      - name: Push to GHCR
        run: docker push ghcr.io/fitx/api:${{ github.sha }}
      - name: Blue/Green Deploy to Fly.io
        uses: superfly/flyctl-actions@1.5
        with:
          args: "deploy --image ghcr.io/fitx/api:${{ github.sha }} --strategy bluegreen --app fitx-api"
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN_PROD }}
      - name: Run zero-downtime migrations
        run: doppler run -- npx prisma migrate deploy
      - name: Smoke tests (production)
        run: npm run test:smoke -- --env=production
      - name: Canary monitoring (10 min)
        run: npm run monitor:canary -- --duration=600
      - name: Full traffic rollout
        run: flyctl scale count 3 --app fitx-api  # ensure full capacity
      - name: Notify team
        uses: slackapi/slack-github-action@v1
        with:
          payload: '{"text": "🚀 Production deployed: ${{ github.sha }}"}'
```

---

## 3. Mobile App Release Pipeline

### Android (Google Play)

```yaml
# Triggered on version tag: v1.0.0
- Build React Native bundle (Metro)
- Build signed APK / AAB (Gradle)
  - Keystore from GitHub Secrets
- Run E2E tests on Firebase Test Lab (real device)
- Upload to Play Console (Internal track)
- Manual promotion: Internal → Alpha → Beta → Production
```

### iOS (App Store)

```yaml
# Runs on macOS GitHub Actions runner
- Build React Native bundle
- Build with Xcode (fastlane)
- Sign with Distribution certificate (Keychain from Secrets)
- Upload to App Store Connect via altool
- Submit for TestFlight (Internal)
- Manual promotion to App Store
```

---

## 4. Database Migration Strategy

**Zero-Downtime Migration Rules:**

1. **Never** drop a column or table in the same deploy that removes code using it.
2. **Always** add columns as nullable first; backfill; then add NOT NULL constraint.
3. **Sequence:** Old code + new schema → New code + new schema → Remove old schema

```
Release N:   Add new column (nullable)
Release N+1: Use new column in code; backfill old data
Release N+2: Add NOT NULL; remove old column reference
```

**Prisma Migration Workflow:**

```bash
# Development
npx prisma migrate dev --name add_user_districts

# Production (automated in CI)
npx prisma migrate deploy  # Applies pending migrations; safe for production
```

---

## 5. Rollback Strategy

| Scenario | Rollback Method | Time |
|----------|----------------|------|
| API bug detected post-deploy | Re-deploy previous Docker image | 3 min |
| DB migration causes issues | Revert migration (if reversible) | 10 min |
| Mobile app crash surge | Halt release in Play Console/App Store | 5 min |
| Critical security issue | Emergency rollback + revoke all sessions | 15 min |

**Automated rollback trigger:**

- If error rate > 10% within 5 minutes of deploy → Auto-rollback previous image
