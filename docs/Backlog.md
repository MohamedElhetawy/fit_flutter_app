# FitX — Product Backlog
**Version:** 1.0.0  
**Format:** Prioritized backlog for Sprint 1–4 (MVP)

---

## Backlog Status Keys
- 🔴 Blocked
- 🟡 In Progress
- 🟢 Ready
- ⬜ Backlog (not yet refined)
- ✅ Done

---

## Epic 1: Authentication (Sprint 1)

| ID | Story | Points | Status | Assignee |
|----|-------|--------|--------|---------|
| BL-001 | Phone OTP registration API | 5 | 🟢 Ready | — |
| BL-002 | OTP verification + JWT issuance | 5 | 🟢 Ready | — |
| BL-003 | Google OAuth login | 5 | 🟢 Ready | — |
| BL-004 | JWT refresh + rotation | 3 | 🟢 Ready | — |
| BL-005 | Logout + token invalidation | 2 | 🟢 Ready | — |
| BL-006 | Biometric login (mobile) | 3 | ⬜ Backlog | — |
| BL-007 | Rate limiting (auth endpoints) | 3 | 🟢 Ready | — |
| BL-008 | Registration screen (mobile) | 3 | 🟢 Ready | — |
| BL-009 | OTP screen (mobile) | 3 | 🟢 Ready | — |
| BL-010 | Onboarding flow (7 steps, mobile) | 8 | 🟢 Ready | — |
| **Epic Total** | | **40** | | |

---

## Epic 2: Workout Engine (Sprint 1–2)

| ID | Story | Points | Status | Notes |
|----|-------|--------|--------|-------|
| BL-011 | Exercise library: seed 200 exercises | 8 | 🟢 Ready | Data task |
| BL-012 | Workout plan generator API | 8 | 🟢 Ready | Algorithm |
| BL-013 | Workout session tracking API | 5 | 🟢 Ready | |
| BL-014 | Session sets API (log sets/reps/weight) | 5 | 🟢 Ready | |
| BL-015 | Emergency workout generator API | 5 | 🟢 Ready | |
| BL-016 | Exercise library screen (mobile) | 5 | 🟢 Ready | |
| BL-017 | Workout plan screen (mobile) | 5 | 🟢 Ready | |
| BL-018 | Workout execution screen (mobile) | 8 | 🟢 Ready | Core UX |
| BL-019 | Rest timer component | 3 | 🟢 Ready | |
| BL-020 | Workout completion screen + animations | 5 | 🟢 Ready | |
| BL-021 | Emergency workout screen (mobile) | 3 | 🟢 Ready | |
| BL-022 | Workout history calendar view | 5 | ⬜ Backlog | Sprint 2 |
| **Epic Total** | | **65** | | |

---

## Epic 3: Nutrition (Sprint 2)

| ID | Story | Points | Status | Notes |
|----|-------|--------|--------|-------|
| BL-023 | Egyptian food database: seed 500 items | 13 | 🟢 Ready | Data task |
| BL-024 | Food log API (create/read/delete) | 5 | 🟢 Ready | |
| BL-025 | Macro calculation service | 5 | 🟢 Ready | Algorithm |
| BL-026 | Camera food recognition model (TFLite) | 13 | 🟡 In Progress | ML task |
| BL-027 | Food recognition API endpoint | 5 | 🔴 Blocked | Blocked by BL-026 |
| BL-028 | Budget protein planner algorithm | 8 | 🟢 Ready | Optimization |
| BL-029 | Budget planner API | 5 | 🔴 Blocked | Blocked by BL-028 |
| BL-030 | Market prices DB + seed data | 5 | 🟢 Ready | Data task |
| BL-031 | Fridge Rescue API (Claude integration) | 5 | 🟢 Ready | |
| BL-032 | Food log screen (mobile) | 8 | 🟢 Ready | |
| BL-033 | Macro ring component | 5 | 🟢 Ready | |
| BL-034 | Budget planner screen (mobile) | 5 | ⬜ Backlog | Sprint 2 |
| BL-035 | Fridge Rescue screen (mobile) | 3 | ⬜ Backlog | Sprint 2 |
| **Epic Total** | | **85** | | |

---

## Epic 4: Gamification (Sprint 2)

| ID | Story | Points | Status |
|----|-------|--------|--------|
| BL-036 | Points event system | 5 | 🟢 Ready |
| BL-037 | Streak engine | 5 | 🟢 Ready |
| BL-038 | Badge definitions + unlock logic | 5 | 🟢 Ready |
| BL-039 | Map challenge (step counting) | 8 | ⬜ Backlog |
| BL-040 | Gym check-in + leaderboard | 5 | ⬜ Backlog |
| BL-041 | Achievement screen (mobile) | 5 | ⬜ Backlog |
| BL-042 | Badge unlock modal + animation | 3 | ⬜ Backlog |
| **Epic Total** | | **36** | | |

---

## Epic 5: Commerce (Sprint 3)

| ID | Story | Points | Status |
|----|-------|--------|--------|
| BL-043 | Merchant DB + seed 20 test merchants | 5 | 🟢 Ready |
| BL-044 | Merchant map API (geo proximity) | 8 | 🟢 Ready |
| BL-045 | Offer management API | 5 | 🟢 Ready |
| BL-046 | QR generation + redemption system | 8 | 🟢 Ready |
| BL-047 | Commission calculation + tracking | 5 | 🟢 Ready |
| BL-048 | Merchant map screen (mobile) | 8 | 🟢 Ready |
| BL-049 | QR code screen (mobile) | 3 | 🟢 Ready |
| BL-050 | Partner web dashboard (offers) | 13 | ⬜ Backlog |
| BL-051 | Partner onboarding form | 5 | ⬜ Backlog |
| **Epic Total** | | **60** | | |

---

## Epic 6: Pro Features (Sprint 3–4)

| ID | Story | Points | Status | Notes |
|----|-------|--------|--------|-------|
| BL-052 | Subscription API (create/status/expire) | 8 | 🟢 Ready | |
| BL-053 | Fawry SDK integration | 8 | 🟢 Ready | |
| BL-054 | Paymob card payment | 8 | ⬜ Backlog | Sprint 4 |
| BL-055 | Subscription screens (mobile) | 5 | 🟢 Ready | |
| BL-056 | Pro feature gate (API middleware) | 3 | 🟢 Ready | |
| BL-057 | AI Pose Detection integration (mobile) | 13 | ⬜ Backlog | Sprint 4 |
| BL-058 | AI Pose audio feedback (Egyptian Arabic) | 8 | ⬜ Backlog | Sprint 4; needs recording |
| BL-059 | Adaptive training (fatigue check-in) | 5 | ⬜ Backlog | Sprint 4 |
| BL-060 | Voice coach push notifications | 5 | ⬜ Backlog | Sprint 4 |
| **Epic Total** | | **63** | | |

---

## Total Backlog Points: ~349 story points
## Estimated Velocity: ~50 points/sprint (2 engineers)
## Estimated Sprints to MVP: 7 sprints (14 weeks)