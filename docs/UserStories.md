# FitX — User Stories
**Version:** 1.0.0  
**Format:** As a [role], I want [goal], so that [reason]

---

## Epic 1: Authentication & Onboarding

| ID | User Story | Priority | Acceptance Criteria |
|----|-----------|----------|---------------------|
| US-001 | As a new user, I want to register with my phone number so that I can create a secure account without needing email | Must | OTP sent within 10s; account created on valid OTP; JWT returned |
| US-002 | As a user, I want to log in with Google so that I don't have to remember a password | Should | Google OAuth completes in <5s; account created/linked |
| US-003 | As a returning user, I want to use Face ID/fingerprint to log in so that access is instant and secure | Should | Biometric prompt shown; login completes in <1s |
| US-004 | As a new user, I want an engaging onboarding so that I feel the app is made for me | Must | All 7 onboarding steps completable; skip available; plan generated at end |
| US-005 | As a user, I want to update my weight regularly so that my macro targets stay accurate | Must | Weight log with timestamp; weight history chart visible |

---

## Epic 2: Workout

| ID | User Story | Priority | Acceptance Criteria |
|----|-----------|----------|---------------------|
| US-010 | As a beginner, I want a safe, pre-built workout plan so that I don't have to guess what exercises to do | Must | Plan generated based on goal + level; includes warm-up and cool-down |
| US-011 | As a user, I want to track my sets and reps in real-time so that I know my progress during the workout | Must | Set counter updates with each "Done" tap; rest timer auto-starts |
| US-012 | As a busy user, I want to generate a 15-minute workout instantly so that I can train even on hectic days | Must | Emergency workout generated <2s for any time input 5–45 min |
| US-013 | As a Pro user, I want my camera to check my form so that I avoid injury | Should | Pose detection active for 5 MVP exercises; audio feedback in Arabic |
| US-014 | As a user, I want the app to suggest lighter workouts when I'm tired so that I don't overtrain | Should | Fatigue check-in shown; adaptive plan shown on score ≥7 |
| US-015 | As a user, I want workout plans to evolve every 4 weeks so that I keep progressing | Should | New plan auto-generated at week 4 based on performance data |
| US-016 | As a user, I want to see my workout history so that I can track my long-term progress | Must | Calendar view showing completed/missed sessions; volume trend chart |

---

## Epic 3: Nutrition

| ID | User Story | Priority | Acceptance Criteria |
|----|-----------|----------|---------------------|
| US-020 | As a user, I want to log my food by taking a photo so that tracking is fast and effortless | Must | Recognition in <3s; top 3 predictions shown; manual fallback available |
| US-021 | As a user, I want to see my daily macros in a visual ring so that I understand my nutrition at a glance | Must | Protein/carbs/fat rings update live; color-coded by completion |
| US-022 | As a budget-conscious user, I want a weekly protein meal plan based on my budget so that eating healthy doesn't break the bank | Must | Plan generated with EGP cost; shopping list included |
| US-023 | As a user, I want to input what I have in my fridge and get a healthy recipe so that I reduce food waste | Should | 3+ recipes returned <5s; macros shown per recipe |
| US-024 | As a user, I want the app to alert me when seasonal produce is cheap so that I eat better for less | Could | Seasonal alert push notification based on month/region |
| US-025 | As a user, I want to track my water intake so that I stay properly hydrated | Should | Water log with daily target; reminder notification configurable |

---

## Epic 4: Local Commerce

| ID | User Story | Priority | Acceptance Criteria |
|----|-----------|----------|---------------------|
| US-030 | As a user, I want to find nearby butchers and supplement stores on a map so that I know where to shop | Must | Map loads within 2s; markers filterable by category and rating |
| US-031 | As a user, I want to get a discount QR code from a merchant so that I save money on healthy food | Must | QR generated instantly; valid 24h; scannable by merchant |
| US-032 | As a user, I want to rate a merchant after buying so that others know who to trust | Must | Rating prompt appears after QR redemption; affects merchant score |
| US-033 | As a partner, I want to post offers so that I reach fitness-motivated local customers | Must | Offer creation in <2 min; visible to users within coverage zone |
| US-034 | As a partner, I want to see how many customers came from FitX so that I can measure my ROI | Should | Dashboard shows referral count, redemptions, and estimated revenue |

---

## Epic 5: Gamification & Community

| ID | User Story | Priority | Acceptance Criteria |
|----|-----------|----------|---------------------|
| US-040 | As a user, I want to maintain a streak so that I stay motivated to work out consistently | Must | Streak counter on home screen; resets after 2 missed days |
| US-041 | As a user, I want to compete for Gym Mayor so that there's a fun incentive to show up | Should | Monthly leaderboard per gym; badge awarded to top check-in user |
| US-042 | As a user, I want map-based walking challenges so that fitness feels like an adventure | Should | Challenge shows progress as a journey (e.g., Cairo to Alexandria) |
| US-043 | As a user, I want a workout buddy near me so that I stay accountable | Should | Buddy matched based on location, goal, and schedule; messaging enabled |
| US-044 | As a Pro user, I want a voice coach to motivate me during rest periods so that I push harder | Could | Voice clips play between sets; configurable on/off |
| US-045 | As a user, I want to earn badges for milestones so that I feel rewarded for my effort | Should | Badges unlocked for: first workout, 7-day streak, 30-day streak, Gym Mayor |

---

## Epic 6: Admin & Operations

| ID | User Story | Priority | Acceptance Criteria |
|----|-----------|----------|---------------------|
| US-050 | As an admin, I want to manage the exercise library so that the content stays accurate and safe | Must | Full CRUD for exercises; changes reflected in app within 1 minute |
| US-051 | As an admin, I want to update food prices weekly so that the budget planner stays accurate | Must | Batch price update interface; changes trigger plan recalculation |
| US-052 | As an admin, I want to see real-time dashboards so that I can monitor app health and growth | Must | Live MAU, revenue, Pro conversion, and crash rate visible |
| US-053 | As an admin, I want to auto-suspend merchants below 4.0 stars so that user trust is protected | Must | Auto-suspension triggered at 4.0 avg with 20+ ratings; notification sent |