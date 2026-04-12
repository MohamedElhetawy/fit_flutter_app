# FitX — Logging Strategy
**Version:** 1.0.0

---

## 1. Logging Principles

1. **Structured logs only** — All logs are JSON; no printf-style strings
2. **Never log PII** — Phone numbers, names, and location data are never logged
3. **Log what matters** — Every request, every error, every business event
4. **Consistent format** — Same structure across all services
5. **Searchable** — All logs indexed and queryable in real-time

---

## 2. Log Format

### Standard Log Entry
```json
{
  "timestamp": "2025-01-15T08:30:01.234Z",
  "level": "info",
  "service": "fitx-api",
  "version": "1.0.0",
  "environment": "production",
  "request_id": "req_abc123xyz",
  "user_id": "usr_abc123",
  "message": "Workout session completed",
  "context": {
    "session_id": "sess_xyz",
    "duration_seconds": 2700,
    "exercises_completed": 5,
    "points_awarded": 50
  },
  "duration_ms": 45
}
```

### Error Log Entry
```json
{
  "timestamp": "2025-01-15T08:30:01.234Z",
  "level": "error",
  "service": "fitx-api",
  "request_id": "req_def456",
  "user_id": "usr_xyz789",
  "message": "Database query failed",
  "error": {
    "code": "P2002",
    "type": "UniqueConstraintViolation",
    "table": "users",
    "field": "phone_hash"
  },
  "stack": "Error: Unique constraint failed...\n  at ...",
  "http": {
    "method": "POST",
    "path": "/v1/auth/register",
    "status": 409
  }
}
```

---

## 3. Log Levels

| Level | When to Use | Examples |
|-------|-------------|---------|
| `error` | Unhandled exceptions, failed external calls | DB connection failure, payment API error |
| `warn` | Expected errors, degraded state | Rate limit reached, cache miss, slow query |
| `info` | Normal business events | User registered, workout completed, offer redeemed |
| `debug` | Detailed trace (dev/staging only) | Function entry, variable values, DB query params |
| `http` | All HTTP requests/responses | Auto-logged by Fastify middleware |

**Production log level:** `info` and above (debug suppressed)  
**Staging log level:** `debug` and above  
**Development:** All levels including `trace`

---

## 4. Request Logging

Every API request is automatically logged by Fastify's `pino-http` plugin:

```json
{
  "level": "http",
  "request_id": "req_abc123",
  "method": "POST",
  "url": "/v1/workouts/sessions",
  "status": 201,
  "response_time_ms": 87,
  "user_id": "usr_abc123",
  "user_agent": "FitX-Android/1.0.0",
  "ip_country": "EG"
}
```

**Note:** IP addresses are NOT stored. Only country code (from Cloudflare header).

---

## 5. Business Event Logging

Critical business events get explicit log entries at `info` level for analytics:

```typescript
// Workout completed
logger.info({
  event: 'workout.completed',
  user_id: userId,
  session_id: sessionId,
  duration_seconds: duration,
  exercises_completed: count,
  is_partial: false
});

// Pro subscription activated
logger.info({
  event: 'subscription.activated',
  user_id: userId,
  tier: 'pro',
  payment_method: 'fawry',
  amount_egp: 39,
  duration_days: 30
});

// QR redemption
logger.info({
  event: 'offer.redeemed',
  user_id: userId,
  merchant_id: merchantId,
  offer_id: offerId,
  commission_piastres: commissionAmount
});
```

---

## 6. PII Scrubbing Rules

The logging middleware automatically scrubs:
```typescript
const SCRUBBED_PATHS = [
  'req.body.phone',
  'req.body.otp',
  'req.body.password',
  'req.headers.authorization',
  'res.body.access_token',
  'res.body.refresh_token',
  'context.phone',
  'context.email',
];
```

Any field matching these paths is replaced with `[REDACTED]`.

---

## 7. Log Storage & Retention

| Environment | Storage | Retention | Tool |
|-------------|---------|-----------|------|
| Production | Fly.io log drain → Logtail | 30 days searchable; 1 year archive | Logtail / BetterStack |
| Staging | Fly.io log drain → Logtail | 7 days | Logtail |
| Development | Console only | Session only | Pino dev formatter |

**Log volume estimate:** ~10MB/day at 50k MAU (compressed)

---

## 8. Alerting from Logs

### Log-Based Alerts (Logtail / BetterStack)

| Alert | Condition | Channel |
|-------|-----------|---------|
| Payment failure spike | >5 `event: payment.failed` in 5 minutes | Slack #alerts |
| Auth brute force | >50 `error: INVALID_OTP` for same phone in 5 min | PagerDuty |
| DB connection errors | Any `error.code: P1001` (DB unreachable) | PagerDuty |
| Slow queries | >10 queries taking >2s in 5 minutes | Slack #alerts |
| External API failure | >3 consecutive Claude API timeouts | Slack #alerts |

---

## 9. Mobile App Logging

### Firebase Crashlytics (crashes + ANRs)
Automatic capture of:
- All unhandled exceptions with full stack trace
- ANR (App Not Responding) events
- Custom keys added to every report:
  - `user_tier`: free/pro
  - `app_version`: 1.0.0
  - `device_ram_mb`: device RAM in MB
  - `screen`: current screen name

### Firebase Analytics (user events)
See Analytics.md for full event taxonomy.

### Client-Side Error Boundary Logging
React Native global error boundary catches all render errors:
```typescript
// Logged to Sentry with component stack
Sentry.captureException(error, {
  contexts: { react: { componentStack } }
});
```