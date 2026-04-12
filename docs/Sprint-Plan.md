# FitX — Sprint Plan

**Version:** 1.0.0  
**Sprint Duration:** 2 weeks  
**Team:** Mohammed (Tech Lead) + Seif (Ops) + Designer (TBD)

---

## Sprint Ceremony Schedule

| Ceremony | When | Duration | Attendees |
|----------|------|----------|-----------|
| Sprint Planning | Monday (Sprint start) | 2 hours | Full team |
| Daily Standup | Every day | 15 min | Dev team |
| Sprint Review | Friday (Sprint end) | 1 hour | Full team + stakeholders |
| Retrospective | Friday (Sprint end) | 45 min | Dev team |
| Backlog Refinement | Wednesday (mid-sprint) | 1 hour | Dev team + PM |

---

## Sprint 1: Technical Foundation (Weeks 1–2)

**Goal:** Working auth + onboarding + CI/CD pipeline

### Committed Stories

| Story | Points | Owner |
|-------|--------|-------|
| BL-001: Phone OTP registration API | 5 | Mohammed |
| BL-002: OTP verification + JWT | 5 | Mohammed |
| BL-003: Google OAuth | 5 | Mohammed |
| BL-004: JWT refresh + rotation | 3 | Mohammed |
| BL-005: Logout + invalidation | 2 | Mohammed |
| BL-007: Rate limiting | 3 | Mohammed |
| BL-008: Registration screen (mobile) | 3 | Designer/Dev |
| BL-009: OTP screen (mobile) | 3 | Designer/Dev |
| BL-010: Onboarding flow (7 steps) | 8 | Mohammed |
| CI/CD pipeline setup | 5 | Mohammed |
| Database schema + migrations | 5 | Mohammed |
| **Total** | **47** | |

**Sprint 1 Definition of Done:**

- [ ] User can register and receive OTP via SMS
- [ ] User can verify OTP and receive JWT
- [ ] User can complete onboarding (7 steps)
- [ ] CI pipeline green on GitHub Actions
- [ ] App deploys to staging automatically on push to develop

---

## Sprint 2: Workout + Home Screen (Weeks 3–4)

**Goal:** Users can log and complete a workout

### Committed Stories

| Story | Points | Owner |
|-------|--------|-------|
| BL-011: Exercise library seed (200 exercises) | 8 | Seif (data) |
| BL-012: Workout plan generator API | 8 | Mohammed |
| BL-013: Session tracking API | 5 | Mohammed |
| BL-014: Session sets API | 5 | Mohammed |
| BL-015: Emergency workout generator | 5 | Mohammed |
| BL-016: Exercise library screen | 5 | Mohammed |
| BL-017: Workout plan screen | 5 | Mohammed |
| BL-018: Workout execution screen | 8 | Mohammed |
| BL-019: Rest timer component | 3 | Mohammed |
| BL-020: Completion screen + animation | 5 | Mohammed |
| Home dashboard screen | 5 | Mohammed |
| **Total** | **62** | |

**Sprint 2 DoD:**

- [ ] New user sees a generated workout plan after onboarding
- [ ] User can start, log sets, and complete a workout
- [ ] Rest timer works between sets
- [ ] Completion screen shows XP and streak
- [ ] Home screen shows daily calorie ring + today's workout

---

## Sprint 3: Nutrition Core (Weeks 5–6)

**Goal:** Users can log food and see their macros

### Committed Stories

| Story | Points | Owner |
|-------|--------|-------|
| BL-023: Egyptian food DB seed (500 items) | 13 | Seif (data) |
| BL-024: Food log API | 5 | Mohammed |
| BL-025: Macro calculation service | 5 | Mohammed |
| BL-028: Budget planner algorithm | 8 | Mohammed |
| BL-029: Budget planner API | 5 | Mohammed |
| BL-030: Market prices DB seed | 5 | Seif (data) |
| BL-031: Fridge Rescue API | 5 | Mohammed |
| BL-032: Food log screen (mobile) | 8 | Mohammed |
| BL-033: Macro ring component | 5 | Mohammed |
| **Total** | **59** | |

---

## Sprint 4: Food AI + Gamification (Weeks 7–8)

**Goal:** Camera food recognition working; points and streaks live

### Committed Stories

| Story | Points | Owner |
|-------|--------|-------|
| BL-026: Food recognition TFLite model | 13 | Mohammed (ML) |
| BL-027: Food recognition API | 5 | Mohammed |
| BL-034: Budget planner screen | 5 | Mohammed |
| BL-035: Fridge Rescue screen | 3 | Mohammed |
| BL-036: Points event system | 5 | Mohammed |
| BL-037: Streak engine | 5 | Mohammed |
| BL-038: Badge definitions + unlock | 5 | Mohammed |
| **Total** | **41** | |

---

## Sprint 5: Commerce + Partner (Weeks 9–10)

**Goal:** Merchant map live; partners can create offers

### Committed Stories

| Story | Points | Owner |
|-------|--------|-------|
| BL-043: Merchant DB + seed merchants | 5 | Seif |
| BL-044: Merchant map API | 8 | Mohammed |
| BL-045: Offer management API | 5 | Mohammed |
| BL-046: QR generation + redemption | 8 | Mohammed |
| BL-047: Commission calculation | 5 | Mohammed |
| BL-048: Merchant map screen | 8 | Mohammed |
| BL-049: QR code screen | 3 | Mohammed |
| BL-051: Partner onboarding form | 5 | Mohammed |
| **Total** | **47** | |

---

## Sprint 6: Pro + Payments (Weeks 11–12)

**Goal:** Pro subscription live and working with Fawry

### Committed Stories

| Story | Points | Owner |
|-------|--------|-------|
| BL-052: Subscription API | 8 | Mohammed |
| BL-053: Fawry SDK integration | 8 | Mohammed |
| BL-055: Subscription screens | 5 | Mohammed |
| BL-056: Pro feature gate middleware | 3 | Mohammed |
| BL-040: Gym check-in + leaderboard | 5 | Mohammed |
| BL-041: Achievement screen | 5 | Mohammed |
| BL-042: Badge unlock modal | 3 | Mohammed |
| Admin panel v1 (user + content CRUD) | 8 | Mohammed |
| **Total** | **45** | |

---

## Sprint 7: Polish + Beta Prep (Weeks 13–14)

**Goal:** Beta-ready; all QA checklist items passing

### Focus Areas

| Task | Owner |
|------|-------|
| Performance optimization (slow screens) | Mohammed |
| RTL layout audit (all screens) | Mohammed |
| Accessibility pass (tap targets, contrast) | Mohammed |
| Arabic copy review + fixes | Seif |
| Device compatibility testing (5 devices) | Team |
| Bug bash: all P0/P1 tickets closed | Team |
| App Store / Play Store assets (screenshots, descriptions) | Seif |
| Smoke tests suite completion | Mohammed |
| Monitoring + alerting setup | Mohammed |
| Beta user onboarding prep | Seif |
