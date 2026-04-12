# FitX — Functional Requirements Document (FRD)
**Version:** 1.0.0

---

## 1. Overview
This document provides detailed functional specifications for each module of FitX, serving as the engineering team's primary implementation reference.

---

## 2. Module F-01: Authentication & User Management

### F-01.1 Phone Registration
**Input:** Egyptian phone number (+20XXXXXXXXXX)  
**Process:** Send OTP via SMS → User enters OTP → System validates → Create account  
**Output:** JWT access token + refresh token  
**Error Cases:**
- Invalid phone format → Show inline error
- OTP expired → Resend button (active after 60s cooldown)
- Phone already registered → Prompt login

### F-01.2 Google OAuth Login
**Input:** Google account  
**Process:** Google OAuth 2.0 → Exchange code for token → Create/link account  
**Output:** JWT access token + refresh token

### F-01.3 Biometric Login
**Input:** Fingerprint / Face ID confirmation  
**Precondition:** User has previously logged in with credentials; biometric enabled in settings  
**Process:** Device biometric API → Verify → Return stored refresh token → Issue new access token

### F-01.4 Profile Management
Users can update: display name, profile photo, weight (logged as history), height, fitness goal, budget.  
Weight updates are stored with timestamp to generate a weight-history chart.

---

## 3. Module F-02: Onboarding Flow

### Screens:
1. **Welcome** → App value prop, "Get Started" CTA
2. **Goal Selection** → Radio: Lose Weight / Build Muscle / Stay Active / Athletic Performance
3. **Body Metrics** → Weight (kg), Height (cm), Age
4. **Fitness Level** → Beginner / Intermediate / Advanced
5. **Budget & Equipment** → Monthly food budget (EGP slider), Equipment (None / Home Basics / Full Gym)
6. **Location Permission** → Request location for merchant map
7. **Notification Permission** → Request push notification access
8. **Plan Ready** → Show generated plan preview → "Let's Go!"

---

## 4. Module F-03: Home Dashboard

### Home Screen Components:
- **Daily Ring** — Calorie progress (kcal consumed vs. target)
- **Today's Workout Card** — Tap to start workout
- **Streak Counter** — Days streak with fire icon
- **Quick Actions** — "Log Meal", "Emergency Workout", "Find Deals"
- **Motivational Banner** — Dynamic (time-of-day aware, weather-aware)
- **Buddy Activity Feed** — Recent activity from matched workout buddies

---

## 5. Module F-04: Workout Module

### F-04.1 Workout Plan View
- Weekly calendar strip at top
- Day cards showing: workout name, estimated duration, muscle groups targeted
- "Active Rest" days shown clearly

### F-04.2 Workout Execution Screen
- Exercise name (Arabic + illustration)
- Current set / total sets indicator
- Reps target
- Weight input field (optional)
- Rest Timer (auto-starts after "Done" tap)
- Skip exercise button
- "AI Coach" floating button (Pro only) → activates camera

### F-04.3 Emergency Workout Generator
**User Input:** Available time (slider: 5–45 min)  
**System:** Instantly generates a workout using available equipment + goal  
**Output:** 3–8 exercises presented as a clean card stack  
**Constraint:** Must generate in <2 seconds

### F-04.4 Exercise Library Browser
- Filter by: muscle group, equipment, difficulty
- Search bar (Arabic + transliteration)
- Each exercise card: name, thumbnail, muscle group badges, Pro indicator

---

## 6. Module F-05: Nutrition Module

### F-05.1 Food Log Screen
- Daily overview: breakfast / lunch / dinner / snacks
- "+ Add" button opens: Camera / Search / Barcode / Recent
- Macro ring (protein/carbs/fat) updates live on add

### F-05.2 Camera Food Recognition
**Trigger:** User taps camera icon in food log  
**Process:** TensorFlow Lite model runs on-device  
**Result:** Top-3 food predictions with confidence scores shown as selectable chips  
**Fallback:** If confidence <60%, offer manual search

### F-05.3 Budget Protein Planner
**Input:** Budget (EGP), timeframe (week/month), dietary restrictions  
**Process:** Backend optimizes against current market prices in user's area  
**Output:**
- 7-day meal plan (5 meals/day)
- Daily macro totals
- Shopping list with itemized costs
- Nearest partner merchant for each item (map pin)

### F-05.4 Fridge Rescue
**Input:** Free-text ingredients list (e.g., "eggs, tomatoes, oats")  
**Process:** AI generates healthy recipes from inputs  
**Output:** 3 recipe cards with macros, steps, estimated calories  
**Constraint:** Must respond in <5 seconds

---

## 7. Module F-06: Merchant Map

### Map View:
- Google Maps base with FitX-branded markers
- Marker types: Butcher (red), Gym (blue), Supplement (green), Restaurant (orange)
- Tap marker → Merchant card slides up (name, rating, current offers, "Get Deal" CTA)
- Filter bar at top: show/hide by category and min rating

### Deal Redemption:
- "Get Deal" → Generates QR code with: merchant ID, offer ID, user ID, timestamp
- QR code valid for 24 hours
- Partner scans → Discount applied → App records transaction for commission

---

## 8. Module F-07: Gamification

### Points Ledger:
Every point event is recorded with: event_type, points_delta, timestamp, source_id.

### Leaderboard Calculation:
- Gym Mayor: counted by check-ins at specific gym in current calendar month
- Global Leaderboard: total XP points this week
- Buddy Leaderboard: points vs. workout buddy this week

### Badges System:
Each badge has: name, description, icon, unlock_condition (rule-based), rarity (Common/Rare/Epic).

---

## 9. Module F-08: Partner Dashboard (Web)

### Sections:
1. **Dashboard Home** — Total referrals, redemptions, revenue this month, star rating
2. **Offers Manager** — Create/edit/schedule offers with: discount type (%), product, validity period, usage limit
3. **Analytics** — Referral source breakdown, peak hours chart, customer age distribution (anonymized)
4. **Profile** — Business info, opening hours, product categories, photos

---

## 10. Module F-09: Admin Panel

### Dashboard:
- Real-time user counter, Pro user count, DAU chart, revenue chart
- Alert panel: merchants below 4.0 rating, reported users, pending partner approvals

### Content Management:
- Exercise library CRUD
- Food database CRUD with price management
- Workout plan templates management

### User Management:
- Search user by phone/name
- View profile, subscription status, activity log
- Suspend / unsuspend account
- Issue credit (for compensation)

### Partner Management:
- Approve / reject partner applications
- View partner analytics
- Manual rating override (with audit log)