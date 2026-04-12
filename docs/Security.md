# FitX — Security Specification

**Version:** 1.0.0  
**Standard:** OWASP Mobile Top 10 + OWASP API Security Top 10

---

## 1. Security Principles

1. **Zero Trust** — Every request is authenticated and authorized, regardless of origin.
2. **Least Privilege** — Each role has only the permissions it needs and nothing more.
3. **Defense in Depth** — Multiple layers of security; no single point of failure.
4. **Privacy by Design** — Collect minimum data; anonymize wherever possible.
5. **Fail Securely** — On any error, deny by default; never expose internal state.

---

## 2. Authentication Security

### JWT Token Design

```
Access Token:
  Algorithm: RS256 (asymmetric — private key signs, public key verifies)
  Expiry: 24 hours
  Payload: { sub: user_id, role, tier, iat, exp, jti (unique ID) }
  
Refresh Token:
  Type: Opaque random token (256-bit)
  Storage: Server-side (Redis) with SHA-256 hash stored in DB
  Expiry: 30 days
  Rotation: Issued new token on every refresh; old one invalidated
  
Token Binding: Refresh tokens bound to device_id header
```

### OTP Security

```
Generation: Cryptographically random 6-digit code (crypto.randomInt)
Storage: SHA-256 hash only (never plaintext) in Redis
TTL: 5 minutes
Max Attempts: 5 per OTP session
Lockout: 15 minutes after 5 failures (exponential backoff for repeat offenders)
Rate Limit: Max 3 OTP requests per phone per hour
```

### Session Management

```
Concurrent Sessions: Max 5 active refresh tokens per user
Session Invalidation Triggers:
  - Password/phone change
  - Explicit logout from all devices
  - Admin account suspension
  - Detected anomalous activity (new country, rapid IP switching)
```

---

## 3. Authorization (RBAC)

### Role Matrix

| Permission | guest | user | pro | trainer | partner | admin |
|------------|-------|------|-----|---------|---------|-------|
| View public exercises | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Log workout | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ |
| AI Pose Correction | ❌ | ❌ | ✅ | ✅ | ❌ | ✅ |
| Unlimited budget plans | ❌ | ❌ | ✅ | ✅ | ❌ | ✅ |
| View merchant map | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Redeem offers | ❌ | ✅ | ✅ | ✅ | ❌ | ✅ |
| Manage own offers | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| View partner analytics | ❌ | ❌ | ❌ | ❌ | ✅ | ✅ |
| View any user data | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Suspend accounts | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Admin panel access | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

### Row-Level Security (PostgreSQL RLS)

All tables with user_id enforce:

```sql
CREATE POLICY user_owns_row ON food_logs
  FOR ALL
  USING (user_id = current_setting('app.current_user_id'));
```

This ensures even if the API layer has a bug, users can never access each other's data at the DB level.

---

## 4. API Security

### Rate Limiting (per endpoint category)

| Category | Limit | Window |
|----------|-------|--------|
| Auth endpoints (OTP, login) | 10 requests | 1 minute |
| Standard API | 100 requests | 1 minute |
| AI features (food recognition) | 20 requests | 1 minute |
| File uploads | 10 requests | 5 minutes |
| Admin endpoints | 200 requests | 1 minute |

Rate limit headers returned: `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

### Input Validation

```
All inputs: Validated with Zod schemas before any processing
String inputs: Max length enforced; strip HTML tags; trim whitespace
SQL: ALL queries via Prisma ORM (parameterized); zero raw SQL in application code
File uploads: Type checking (magic bytes, not just extension); max 10MB; virus scan on AI analysis endpoint
```

### CORS Policy

```
Allowed Origins:
  - https://fitx.app
  - https://partner.fitx.app
  - https://admin.fitx.app
  - (Mobile apps use HTTPS directly, no CORS needed)
  
Credentials: true
Methods: GET, POST, PATCH, DELETE, OPTIONS
Headers: Content-Type, Authorization, X-Device-ID
```

### Security Headers

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Content-Security-Policy: default-src 'self'; img-src *; media-src *.fitx.app
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), camera=(), microphone=()
```

---

## 5. Data Privacy & Protection

### PII Classification

| Data | Classification | Storage | Retention |
|------|---------------|---------|-----------|
| Phone number | High sensitivity | Encrypted at rest | Until account deletion |
| Name | Medium | Plaintext | Until account deletion |
| Location (GPS) | High sensitivity | NOT stored | Session only (in-memory) |
| Location (District) | Low | Plaintext | Until profile update |
| Workout logs | Low | Plaintext | 3 years |
| Food logs | Low | Plaintext | 2 years |
| Payment info | Critical | Never stored (PSP handles) | Never |
| Push tokens | Medium | Encrypted | Until logout |

### Data Minimization Rules

1. GPS coordinates: NEVER persisted; only used in-request for merchant proximity
2. Only store district-level location (not precise address)
3. Food camera images: processed in-memory; NEVER stored on server
4. Pose detection frames: processed on-device; NEVER uploaded

### Right to Deletion (GDPR-equivalent)

- User can request account deletion from settings
- Process: Soft-delete (deleted_at set) → 30 days → Hard delete all PII
- Anonymize: Replace all PII with "deleted_user" placeholders in shared data (reviews, leaderboards)
- Timeline: Complete within 30 days of request

---

## 6. Mobile App Security

### Certificate Pinning

```javascript
// Validate server certificate against pinned public key hash
// Prevents MITM attacks even if a CA is compromised
const PINNED_CERT_HASH = 'sha256/AAAA...';
```

Applied to all API calls in production builds.

### On-Device Data Protection

- SQLite database encrypted with SQLCipher (AES-256)
- Encryption key stored in iOS Keychain / Android Keystore (hardware-backed)
- Sensitive fields in Redux state NOT persisted via redux-persist
- Screen capture disabled for payment and QR code screens

### Jailbreak / Root Detection

```
On app start: Check for jailbreak/root indicators
If detected: Show warning; disable AI pose correction (camera security concern)
Do NOT block app entirely (too aggressive; false positives)
```

### Code Security

- Enable ProGuard / R8 on Android (obfuscation + minification)
- Enable bitcode + strip symbols on iOS release builds
- Remove all debug logs in production builds
- API keys: NEVER hardcoded; loaded from secure config at build time

---

## 7. Infrastructure Security

### Network

```
- All services in private VPC; only API Gateway exposed publicly
- Database: No public IP; accessible only from app servers via private network
- Redis: Password-protected; no public exposure
- Admin panel: IP whitelist (FitX team IPs only) + 2FA
```

### Secrets Management

```
Tool: Doppler (secrets manager) or environment variables encrypted at rest
Rotation: Database credentials rotated every 90 days
Never in: git, logs, error messages, API responses
```

### Dependency Security

```
Schedule: Weekly automated scan via GitHub Dependabot
Action: Critical CVEs patched within 48 hours
Process: PR opened automatically; reviewed before merge
```

---

## 8. Incident Response

### Severity Levels

| Level | Example | Response Time | Action |
|-------|---------|---------------|--------|
| P0 — Critical | Data breach, auth bypass | 1 hour | Immediate: notify team, contain, assess |
| P1 — High | Privilege escalation, payment fraud | 4 hours | Same-day investigation |
| P2 — Medium | Rate limit bypass, minor data leak | 24 hours | Next business day |
| P3 — Low | Informational exposure | 1 week | Scheduled fix |

### Breach Response Protocol

1. **Detect** → Automated alerts via Sentry + CloudFlare WAF
2. **Contain** → Disable affected endpoint or revoke all sessions if needed
3. **Assess** → Determine scope of exposure
4. **Notify** → Users affected notified within 72 hours (per PDPL Egypt)
5. **Remediate** → Fix + post-mortem
6. **Report** → Regulatory notification if required

---

## 9. Security Testing Schedule

| Test | Frequency | Tool |
|------|-----------|------|
| Dependency CVE scan | Weekly | GitHub Dependabot |
| SAST (static analysis) | Every PR | ESLint security plugin + Semgrep |
| DAST (dynamic analysis) | Monthly | OWASP ZAP |
| Penetration test | Annual | Certified third-party |
| Mobile app security audit | Pre each major release | Manual + MobSF |
