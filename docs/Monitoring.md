# FitX — Changelog

**Standard:** Keep a Changelog v1.1.0  
**Versioning:** Semantic Versioning (MAJOR.MINOR.PATCH)

---

## [Unreleased]

### Added

- Partner web dashboard v1
- Buddy in-app messaging
- Seasonal food radar push alerts

### Changed

- Upgraded TFLite food model to v2 (15% accuracy improvement)

### Security

- Enforced HSTS preload on all subdomains

---

## [1.1.0] — Planned (Q3 2025)

### Added

- AI Pose Correction for 5 core exercises (Pro only) — BL-057
- Voice Coach with Egyptian Arabic personality (Pro only) — BL-060
- Adaptive training engine with fatigue self-report — BL-059
- Workout Buddy matching and profile view — BL story
- iOS App Store release
- Gym check-in + Mayor leaderboard — BL-040
- Badge unlock celebration modal — BL-042
- Achievement screen — BL-041
- Paymob credit card integration — BL-054
- Smart Butcher Map with partner merchant locations
- Map challenge: virtual journey across Egypt
- Apple HealthKit / Google Fit wearable integration

### Changed

- Food database expanded from 500 to 750 items
- Budget planner now shows nearest merchant per shopping list item
- Home dashboard redesigned (Daily Ring more prominent)
- Onboarding reduced from 7 to 6 steps (location + notification merged)

### Fixed

- #145: Arabic numerals rendering incorrectly in macro rings on Android 12
- #162: Rest timer not stopping when session ended early
- #178: Location permission dialog causing crash on Android 12 cold start
- #189: Budget planner generating plans exceeding stated budget by up to 12%
- #201: Streak not updating if workout completed after midnight

### Performance

- Cold start time reduced by 400ms on mid-range Android devices
- Camera food recognition latency reduced from 3.2s to 2.4s (average)
- API p95 latency improved from 380ms to 210ms (DB query optimization)

### Security

- Upgraded JWT from HS256 to RS256
- Added certificate pinning for API calls on mobile
- Enforced OTP rate limiting (3 requests/hour per phone)

---

## [1.0.1] — Patch (2 weeks post-launch)

### Fixed

- #234: App crashing on Xiaomi MIUI 14 on startup (font rendering issue)
- #237: Food log not persisting offline when user had no internet at log time
- #241: QR code not scannable on some merchant devices (low contrast)
- #245: Streak showing as broken after timezone change

### Changed

- Updated Fawry SDK to 2.3.1 (stability improvements)

---

## [1.0.0] — MVP Launch (Q2 2025)

### Added

**Authentication**

- Phone number registration + SMS OTP verification
- Google OAuth login
- Biometric login (Face ID / fingerprint)
- JWT authentication with refresh token rotation

**Onboarding**

- 7-step personalized onboarding flow
- Workout plan auto-generated on completion

**Workout**

- Exercise library: 200+ exercises with Arabic names and illustrations
- Workout plan generator (4-week, personalized)
- Workout session tracker (sets, reps, weight, rest timer)
- Emergency workout generator (5–45 min)

**Nutrition**

- Egyptian food database: 500+ local dishes and ingredients
- Camera-based food recognition (TFLite on-device)
- Manual food search and log
- Macro tracking with visual ring
- Budget protein planner
- Fridge Rescue (Claude API)
- Water intake tracking

**Commerce**

- Merchant map (geo-proximity, filterable)
- Partner offer management
- QR discount generation and redemption
- Commission tracking

**Gamification**

- Points system with event-based rewards
- Streak counter with flame animation
- Badge system (5 badges at launch)
- Push notifications

**Platform**

- Full RTL Arabic UI (Egyptian colloquial copy)
- Offline mode for workout and food logging
- Admin panel (content + user management)
- Partner web dashboard (basic offer management)
- CI/CD pipeline (GitHub Actions → Fly.io)
- Error tracking (Sentry + Firebase Crashlytics)
