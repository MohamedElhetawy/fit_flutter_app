# FitX — Test Cases
**Version:** 1.0.0

---

## Module: Authentication

| TC-ID | Test Case | Input | Expected Output | Priority |
|-------|-----------|-------|-----------------|----------|
| TC-AUTH-001 | Register with valid Egyptian phone | `+201012345678` | OTP sent; 200 response | P0 |
| TC-AUTH-002 | Register with non-Egyptian phone | `+12025551234` | 400 INVALID_PHONE | P0 |
| TC-AUTH-003 | Register with malformed phone | `abc123` | 400 INVALID_PHONE | P1 |
| TC-AUTH-004 | Verify valid OTP within 5 min | Correct 6-digit OTP | 200 + tokens | P0 |
| TC-AUTH-005 | Verify expired OTP | OTP after 5 min 1s | 401 OTP_EXPIRED | P0 |
| TC-AUTH-006 | Verify wrong OTP | Incorrect 6-digit | 401 INVALID_OTP; attempts_remaining = 4 | P0 |
| TC-AUTH-007 | Account locks after 5 failed OTPs | 5× wrong OTP | 429 ACCOUNT_LOCKED; locked for 15 min | P0 |
| TC-AUTH-008 | Refresh valid token | Valid refresh_token | 200 + new tokens | P0 |
| TC-AUTH-009 | Refresh expired token | Expired refresh_token | 401 UNAUTHORIZED | P0 |
| TC-AUTH-010 | Refresh already-used token | Previously-used token | 401 (token rotation violation) | P0 |
| TC-AUTH-011 | Access protected endpoint without token | No Authorization header | 401 UNAUTHORIZED | P0 |
| TC-AUTH-012 | Access protected endpoint with expired JWT | Expired access_token | 401 UNAUTHORIZED | P0 |
| TC-AUTH-013 | Free user accesses Pro endpoint | Valid free-user JWT | 403 PRO_REQUIRED | P0 |
| TC-AUTH-014 | Logout invalidates JWT | Logout then use old token | 401 UNAUTHORIZED | P0 |
| TC-AUTH-015 | Rate limit: >10 auth requests/min | 11 requests in 60s | 429 RATE_LIMITED | P1 |

---

## Module: Onboarding

| TC-ID | Test Case | Input | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-ON-001 | Complete all 7 onboarding steps | All valid inputs | User profile saved; workout plan generated | P0 |
| TC-ON-002 | Skip onboarding on first step | Tap "Skip" | User directed to Home; onboarding_complete = false | P0 |
| TC-ON-003 | Resume incomplete onboarding | Re-open app | Onboarding prompt shown on Home | P1 |
| TC-ON-004 | Deny location permission | Tap "Don't Allow" | Merchant map works with manual district selection | P0 |
| TC-ON-005 | Deny notification permission | Tap "Don't Allow" | App proceeds normally; no crash | P0 |
| TC-ON-006 | Submit with missing required fields | Skip body metrics | Step-level validation error shown | P1 |

---

## Module: Workout

| TC-ID | Test Case | Input | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-WK-001 | Start today's workout | Tap "Start Workout" | First exercise displayed with Arabic name + illustration | P0 |
| TC-WK-002 | Complete a set | Tap "Done" | Rest timer auto-starts; set marked complete | P0 |
| TC-WK-003 | Complete all sets in an exercise | 3× tap "Done" | Next exercise card appears with transition animation | P0 |
| TC-WK-004 | Complete full workout session | All exercises done | Completion screen shown; points awarded; streak updated | P0 |
| TC-WK-005 | Skip an exercise mid-workout | Tap "Skip Exercise" | Exercise marked skipped; next exercise shown | P1 |
| TC-WK-006 | End workout early (>50% complete) | Tap "End Early" at 60% | Session saved as partial; streak NOT broken | P1 |
| TC-WK-007 | End workout early (<50% complete) | Tap "End Early" at 40% | Session saved; streak may break next day | P2 |
| TC-WK-008 | Emergency workout: 15 min, home, no equipment | Submit valid inputs | Plan generated in <2 seconds; 3+ exercises shown | P0 |
| TC-WK-009 | Emergency workout: invalid time (0 min) | Submit 0 minutes | Validation error; minimum 5 minutes | P1 |
| TC-WK-010 | Log weight during set | Enter 70kg | Set saved with weight; volume calculated correctly | P1 |
| TC-WK-011 | Rest timer runs out | Wait for timer | Notification/vibration; next set prompted | P0 |
| TC-WK-012 | AI Pose Correction activates (Pro) | Tap "AI Coach" button | Camera opens; overlay shows on-screen guidance | P0 |
| TC-WK-013 | AI Pose Correction: low light | Trigger in dark room | Camera pauses; "إضاءة ضعيفة" message shown | P0 |
| TC-WK-014 | AI Pose Correction: free user | Free user taps "AI Coach" | Pro upsell screen shown; camera does NOT open | P0 |

---

## Module: Nutrition

| TC-ID | Test Case | Input | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-NUT-001 | Log meal manually by search | Search "كشري" | Results within 2s; calories shown | P0 |
| TC-NUT-002 | Log meal via camera (high confidence) | Clear photo of koshari | Top prediction ≥80% confidence; displayed in <3s | P0 |
| TC-NUT-003 | Log meal via camera (low confidence) | Blurry/ambiguous photo | Manual search opened automatically | P0 |
| TC-NUT-004 | Daily macro ring updates after log | Log 200g chicken breast | Protein ring updates live; correct calculation | P0 |
| TC-NUT-005 | Budget protein plan: 300 EGP | Submit 300 EGP budget | 7-day plan shown; total cost ≤300 EGP; shopping list included | P0 |
| TC-NUT-006 | Budget protein plan: negative budget | -50 EGP | Validation error; minimum budget enforced | P1 |
| TC-NUT-007 | Fridge Rescue: valid ingredients | "بيض، طماطم، جبن" | 3+ recipes returned in <5s; macros shown | P0 |
| TC-NUT-008 | Fridge Rescue: empty input | Submit empty list | Error: "إدخل على الأقل مكوّن واحد" | P1 |
| TC-NUT-009 | Delete a food log | Swipe-to-delete log item | Log removed; daily macros recalculated | P1 |
| TC-NUT-010 | Water intake log | Log 500ml | Water progress bar updates; daily total correct | P2 |

---

## Module: Commerce

| TC-ID | Test Case | Input | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-COM-001 | Merchant map loads | Open Deals tab (location granted) | Map shows within 2s; markers visible | P0 |
| TC-COM-002 | Merchant map: no location | Location denied | District-based list shown; no map crash | P0 |
| TC-COM-003 | Tap merchant marker | Tap any marker | Merchant card slides up; name/rating/offers shown | P0 |
| TC-COM-004 | Redeem valid offer | Tap "Get Deal" | QR code generated instantly; expiry shown | P0 |
| TC-COM-005 | QR code expiry | QR code after 24h | Offer expired message; no redemption possible | P0 |
| TC-COM-006 | Double-redeem same QR | Scan QR twice (merchant side) | Second scan returns "Already redeemed" error | P0 |
| TC-COM-007 | Rate a merchant | Submit 5-star rating | Rating submitted; merchant average updated | P1 |
| TC-COM-008 | Merchant auto-suspend at 3.9 avg | System calculates avg | Merchant removed from map; notification sent to partner | P0 |
| TC-COM-009 | Filter merchants by category | Select "لحوم" filter | Only butcher markers visible | P1 |

---

## Module: Gamification

| TC-ID | Test Case | Input | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-GAM-001 | Points awarded for workout | Complete full session | +50 points; home screen counter updates | P0 |
| TC-GAM-002 | Points awarded for food log | Log a meal | +10 points per meal | P0 |
| TC-GAM-003 | Streak increments | Complete workout on consecutive days | Streak count +1; flame animation plays | P0 |
| TC-GAM-004 | Streak breaks after 2 missed days | Skip 2 planned workout days | Streak resets to 0; recovery nudge notification | P0 |
| TC-GAM-005 | Streak not broken on rest day | Miss rest day (planned) | Streak unchanged | P0 |
| TC-GAM-006 | Badge: First Workout | Complete first ever session | Badge unlocked; celebration modal shown | P0 |
| TC-GAM-007 | Badge: 7-Day Streak | Maintain 7-day streak | Badge unlocked | P0 |
| TC-GAM-008 | Gym Mayor: top check-in user | 15 check-ins in a month | Mayor badge awarded end of month | P1 |
| TC-GAM-009 | Leaderboard ranking | Multiple users check in at same gym | Rankings sorted correctly; "is_you" marked | P0 |

---

## Module: Subscription

| TC-ID | Test Case | Input | Expected | Priority |
|-------|-----------|-------|----------|----------|
| TC-SUB-001 | Upgrade to Pro (Fawry) | Valid Fawry payment | Subscription activated; tier = pro immediately | P0 |
| TC-SUB-002 | Upgrade to Pro (card via Paymob) | Valid card | Subscription activated | P0 |
| TC-SUB-003 | Failed payment | Declined card | Error shown; subscription NOT activated | P0 |
| TC-SUB-004 | Pro features unlock after upgrade | Tap AI Coach after upgrade | Camera opens (previously showed upsell) | P0 |
| TC-SUB-005 | Subscription expires | Mock expiry date reached | Tier reverts to free; Pro features show upsell | P0 |
| TC-SUB-006 | Cancel subscription | Cancel in settings | Access until period end; no refund issued | P1 |