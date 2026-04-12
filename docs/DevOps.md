# FitX — DevOps Strategy
**Version:** 1.0.0

---

## 1. DevOps Philosophy

**"Ship fast, break nothing."**

FitX follows a culture of:
- **Automated everything:** If it can be automated, it must be.
- **Observability first:** You can't fix what you can't see.
- **Small, frequent deployments:** Multiple deploys per day over big-bang releases.
- **Feature flags over branching:** Merge to main daily; control what users see via flags.

---

## 2. Environments

| Environment | Purpose | URL | Deploy Trigger |
|-------------|---------|-----|----------------|
| Development | Local dev | localhost | Manual |
| Staging | Pre-production testing | staging.fitx.app | Push to `develop` branch |
| Production | Live app | api.fitx.app | Merge to `main` (manual approval) |
| Canary | 5% traffic A/B test | Handled by load balancer | Post-prod deploy |

### Environment Variables
All secrets managed via **Doppler**:
```
DOPPLER_TOKEN stored in GitHub Secrets
Each environment has its own Doppler config:
  - fitx/development
  - fitx/staging
  - fitx/production
```

---

## 3. Branching Strategy

```
main (production)
  └── develop (staging)
        ├── feature/fitx-123-add-fridge-rescue
        ├── feature/fitx-124-gym-mayor-badges
        ├── fix/fitx-125-otp-timer-bug
        └── chore/fitx-126-update-dependencies
```

**Rules:**
- `main`: Protected; requires PR + 1 approval + passing CI
- `develop`: Protected; requires PR + passing CI
- Feature branches: Named `type/ticket-id-short-description`
- Commits: Follow Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`)
- No direct push to `main` or `develop` — ever

---

## 4. Code Review Standards

**PR Requirements:**
- [ ] CI pipeline fully green (lint, tests, build)
- [ ] Self-review checklist completed
- [ ] No hardcoded secrets
- [ ] No `console.log` in production code
- [ ] API changes include OpenAPI update
- [ ] DB migrations are reversible

**Review SLA:** Within 24 hours of PR creation

---

## 5. Monitoring Stack

| Tool | Purpose | Alert Channel |
|------|---------|--------------|
| Firebase Crashlytics | Mobile crash reporting | Slack #alerts |
| Sentry | API error tracking | Slack #alerts |
| Fly.io Metrics | Server CPU, memory, latency | PagerDuty |
| Upstash Console | Redis memory, commands/sec | Email |
| Supabase Dashboard | DB connections, slow queries | Email |
| Cloudflare Analytics | CDN hit rate, bandwidth | Weekly email |
| GitHub Actions | CI/CD pipeline status | Slack #deploys |

**Alerting Rules:**
```
P0 triggers (immediate PagerDuty):
  - API error rate > 5% for 2 minutes
  - App crash rate > 2%
  - Payment endpoint failure rate > 1%
  - Server disk usage > 90%

P1 triggers (Slack notification):
  - API p95 latency > 1 second
  - DB connection pool > 80%
  - Redis memory > 75%
  - Failed login rate spike (>100/min)
```