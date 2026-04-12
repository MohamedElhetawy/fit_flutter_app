# FitX — Non-Functional Requirements (NFR)
**Version:** 1.0.0

---

## 1. Performance Requirements

| ID | Requirement | Target | Measurement |
|----|------------|--------|-------------|
| NFR-PERF-001 | App cold start time | < 2 seconds | From tap to Home screen visible |
| NFR-PERF-002 | App warm start time | < 800ms | From tap to Home screen visible |
| NFR-PERF-003 | API response time (p50) | < 150ms | Server-side measurement |
| NFR-PERF-004 | API response time (p95) | < 300ms | Server-side measurement |
| NFR-PERF-005 | API response time (p99) | < 1000ms | Server-side measurement |
| NFR-PERF-006 | Food camera recognition | < 3 seconds | From capture to result |
| NFR-PERF-007 | Pose detection latency | < 500ms | From pose error to audio feedback |
| NFR-PERF-008 | Emergency workout generation | < 2 seconds | From tap to plan display |
| NFR-PERF-009 | App size (initial download) | < 40MB | Play Store / App Store listing |
| NFR-PERF-010 | Screen transition animation | 60fps | No dropped frames on target devices |
| NFR-PERF-011 | Fridge Rescue response | < 5 seconds | End-to-end including AI call |

---

## 2. Availability & Reliability

| ID | Requirement | Target |
|----|------------|--------|
| NFR-AVAIL-001 | API uptime | 99.9% per month (≤43.8 min downtime) |
| NFR-AVAIL-002 | Crash-free session rate | ≥ 99.5% |
| NFR-AVAIL-003 | Core features offline | Workout log, food log (cached data) must work offline |
| NFR-AVAIL-004 | Data sync on reconnect | Offline actions sync within 30 seconds of reconnection |
| NFR-AVAIL-005 | Planned maintenance window | Sunday 02:00–04:00 Cairo time; users notified 48h in advance |

---

## 3. Scalability

| ID | Requirement | Target |
|----|------------|--------|
| NFR-SCALE-001 | Concurrent users | Handle 10,000 concurrent users without performance degradation |
| NFR-SCALE-002 | Database scale | Architecture supports 10M user records without schema migration |
| NFR-SCALE-003 | Horizontal scaling | API tier must be stateless and horizontally scalable |
| NFR-SCALE-004 | CDN for static assets | All images/videos served via CDN; no origin server load |
| NFR-SCALE-005 | Auto-scaling | Cloud compute auto-scales on CPU >70% for 2 consecutive minutes |

---

## 4. Security

| ID | Requirement | Specification |
|----|------------|---------------|
| NFR-SEC-001 | Transport security | TLS 1.2+ for all API communication; TLS 1.3 preferred |
| NFR-SEC-002 | Data at rest | User PII encrypted with AES-256 at rest |
| NFR-SEC-003 | Password policy | Min 8 chars, 1 uppercase, 1 number (if password auth used) |
| NFR-SEC-004 | JWT security | Short-lived tokens (24h); refresh token rotation on use |
| NFR-SEC-005 | API rate limiting | 100 requests/min per user; 1000 requests/min per IP |
| NFR-SEC-006 | Input sanitization | All user inputs sanitized; parameterized queries only |
| NFR-SEC-007 | PII data masking | Logs must never contain phone numbers, payment data, or names in plaintext |
| NFR-SEC-008 | Penetration testing | Annual pen test by certified third party |
| NFR-SEC-009 | Dependency scanning | Weekly automated CVE scanning of all dependencies |
| NFR-SEC-010 | Admin panel access | 2FA mandatory for all admin accounts |

---

## 5. Usability

| ID | Requirement | Target |
|----|------------|--------|
| NFR-USE-001 | Onboarding completion rate | ≥ 80% of new users complete onboarding |
| NFR-USE-002 | First workout rate | ≥ 60% of onboarded users start first workout within 24h |
| NFR-USE-003 | Task completion rate | ≥ 90% in usability testing for core tasks |
| NFR-USE-004 | Error message quality | All error messages must be in plain Arabic, explaining cause and next step |
| NFR-USE-005 | Loading states | All async operations show a skeleton/spinner; no blank screens |
| NFR-USE-006 | Haptic feedback | Taps on primary CTAs must trigger subtle haptic feedback |
| NFR-USE-007 | Minimum tap target | 44×44 points minimum for all interactive elements (iOS HIG) |
| NFR-USE-008 | RTL support | Full RTL layout and text rendering; no LTR leakage |

---

## 6. Compatibility

| ID | Requirement | Specification |
|----|------------|---------------|
| NFR-COMPAT-001 | iOS minimum version | iOS 14.0+ |
| NFR-COMPAT-002 | Android minimum version | Android 8.0 (API Level 26) |
| NFR-COMPAT-003 | Screen sizes | Support 4.7" to 6.9" displays |
| NFR-COMPAT-004 | Screen aspect ratios | 16:9, 18:9, 19.5:9, notch/punch-hole displays |
| NFR-COMPAT-005 | Low-end device support | Target devices: Infinix Hot 12, Samsung A-series, Xiaomi Redmi Note |
| NFR-COMPAT-006 | RAM requirement | App functional on devices with 2GB RAM |
| NFR-COMPAT-007 | Camera requirement | Pose detection requires camera; graceful fallback if unavailable |

---

## 7. Battery & Resource Efficiency

| ID | Requirement | Target |
|----|------------|--------|
| NFR-BATT-001 | AI pose correction battery drain | < 5% battery per 30-minute active session |
| NFR-BATT-002 | Background battery usage | < 1% battery drain per hour when app is in background |
| NFR-BATT-003 | Data usage (free tier, monthly) | < 50MB per month for core feature usage |
| NFR-BATT-004 | Low-end device animation reduction | Automatically reduce animations on devices with <2GB RAM or CPU score <100k in Geekbench |

---

## 8. Localization

| ID | Requirement | Specification |
|----|------------|---------------|
| NFR-L10N-001 | Primary language | Egyptian Arabic (ar-EG) |
| NFR-L10N-002 | Secondary language | Modern Standard Arabic + English |
| NFR-L10N-003 | RTL layout | All screens natively RTL; no mirroring hacks |
| NFR-L10N-004 | Number formatting | Arabic-Indic numerals optional; Latin numerals default |
| NFR-L10N-005 | Date formatting | Hijri calendar option alongside Gregorian |
| NFR-L10N-006 | Currency | Egyptian Pound (EGP, ج.م.) |
| NFR-L10N-007 | Voice coach | Egyptian Arabic dialect; warm, friendly tone |

---

## 9. Maintainability

| ID | Requirement | Target |
|----|------------|--------|
| NFR-MAINT-001 | Code coverage | ≥ 80% unit test coverage for core business logic |
| NFR-MAINT-002 | API versioning | All API endpoints versioned (v1, v2); old versions deprecated gracefully |
| NFR-MAINT-003 | Feature flags | All new features behind feature flags for safe rollout |
| NFR-MAINT-004 | Deployment frequency | Able to deploy hotfixes within 2 hours |
| NFR-MAINT-005 | Documentation | All API endpoints documented in OpenAPI 3.0 |
| NFR-MAINT-006 | Error tracking | Sentry or equivalent integrated; all crashes auto-reported |
| NFR-MAINT-007 | Dependency freshness | No dependency more than 2 major versions behind latest stable |

---

## 10. Compliance

| ID | Requirement | Reference |
|----|------------|-----------|
| NFR-COMP-001 | Egyptian Personal Data Protection | Law No. 151 of 2020 |
| NFR-COMP-002 | App Store guidelines | Apple App Store Review Guidelines |
| NFR-COMP-003 | Play Store policies | Google Play Developer Policy |
| NFR-COMP-004 | Payment compliance | PCI-DSS via licensed payment gateway (Fawry/Paymob) |
| NFR-COMP-005 | Accessibility | WCAG 2.1 AA compliance for Arabic RTL |
| NFR-COMP-006 | Children's data | COPPA compliance; users must confirm age ≥13 |