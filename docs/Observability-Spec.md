# FitX — Observability & Monitoring Spec
**Version:** 1.0.1  
**Status:** Implementation Ready  
**Engine:** Sentry + Prometheus + Grafana + Flow.io Logs

---

## 1. Error Tracking (Sentry)

### 1.1 Mobile Layer (React Native)
- **Scope:** Runtime exceptions, JS crashes, and Native (Java/Swift) fatal errors.
- **Privacy Enforcement:**
    - `Sentry.init({ beforeSend: (event) => scrubPII(event) })`.
    - Automatically drop `phone`, `email`, and `password` keys from `context` and `breadcrumbs`.
- **Alerting:** PagerDuty trigger if crash-free session rate falls below 99.5% in any 2-hour window.

### 1.2 Backend Layer (Node.js/Fastify)
- **Scope:** 5xx Errors, Unhandled Rejections, Slow DB Queries (>500ms).
- **Correlation:** Every Sentry event must include `trace_id` from the API response headers for cross-log matching.

---

## 2. Metrics & SLIs (Service Level Indicators)

### 2.1 Virtual Machine Metrics (Fly.io)
- **CPU:** Threshold 80% (Warning), 95% (Critical).
- **Memory:** Alert if free memory < 50MB (Potential leak).
- **Disk:** Monitor R2 bucket sync status for AI models.

### 2.2 Database Metrics (Supabase)
- **Pool Saturation:** Alert if active connections > 180 (Limit 200).
- **Latency:** DB query execution time > 200ms.

---

## 3. Product Analytics (PostHog / Mixpanel)

Tracking of core business events:
- `user_onboarding_started` / `user_onboarding_completed`.
- `workout_session_logged` (with `plan_id`).
- `subscription_upgraded` (with `tier`).
- `merchant_offer_redeemed`.

---

## 4. Alerting Channels & Escalation

| Trigger | Channel | Response Time |
|---------|---------|---------------|
| **API 5xx > 1%** | Slack (#ops-alerts) | 15 mins |
| **API Down (503)** | SMS / PagerDuty | 2 mins |
| **P0 Security Incident** | All Channels + Founder | Immediate |
| **New Badge Unlocked** | Discord (#hype) | Informational |
