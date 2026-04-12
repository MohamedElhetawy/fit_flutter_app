# FitX — User Flows

**Version:** 1.0.0

---

## Flow 1: New User Registration & Onboarding

```
[App Launch]
     │
     ▼
[Splash Screen (2s)]
     │
     ▼
[Welcome Screen]
     │
     ├──► [Login] ──► [Phone/Google Auth] ──► [Home Dashboard]
     │
     └──► [Register]
               │
               ▼
         [Enter Phone Number]
               │
               ├──► [Invalid Format] ──► [Inline Error] ──► [Re-enter]
               │
               ▼
         [OTP Sent]
               │
               ▼
         [Enter OTP]
               │
               ├──► [Wrong OTP] ──► [Retry (up to 5x)] ──► [Lock 15min]
               ├──► [Expired] ──► [Resend OTP]
               │
               ▼
         [OTP Valid → Account Created]
               │
               ▼
         ┌─────────────────────────────┐
         │     ONBOARDING FLOW         │
         │                             │
         │ 1. Goal Selection           │
         │ 2. Body Metrics             │
         │ 3. Fitness Level            │
         │ 4. Budget & Equipment       │
         │ 5. Location Permission      │
         │ 6. Notification Permission  │
         │ 7. Plan Ready Preview       │
         └─────────────────────────────┘
               │
               ▼
         [Home Dashboard]
```

---

## Flow 2: Daily Workout Session

```
[Home Dashboard]
     │
     ▼
[Today's Workout Card] ──► [Emergency Workout?] ──► [Time Input] ──► [Quick Plan]
     │
     ▼
[Workout Plan Screen]
     │
     ▼
[Tap "Start Workout"]
     │
     ▼
[Exercise 1 Screen]
  - Name + Illustration
  - Set 1 of 3
  - Reps Target
     │
     ├──► [AI Coach Button (Pro)] ──► [Camera Active] ──► [Pose Feedback Loop]
     │
     ▼
[Tap "Done"] ──► [Rest Timer Auto-Starts]
     │
     ├──► [Modify Rest Time]
     │
     ▼
[Next Set] ──► [Repeat until all sets done]
     │
     ▼
[Next Exercise Card]
     │   (same loop for all exercises)
     ▼
[Workout Complete Screen]
  - Duration
  - Volume Lifted
  - Calories Burned (est.)
  - Points Awarded
  - Streak Update
     │
     ▼
[Share Achievement? / Back to Home]
```

---

## Flow 3: Food Logging via Camera

```
[Nutrition Tab]
     │
     ▼
[Daily Log View]
  - Breakfast / Lunch / Dinner / Snacks rings
     │
     ▼
[Tap "+ Log Meal"]
     │
     ├──► [Camera] ──► [Capture Photo]
     │         │
     │         ▼
     │    [On-Device AI Recognition (<3s)]
     │         │
     │         ├──► [Confidence ≥60%] ──► [Show Top 3 Predictions]
     │         │         │
     │         │         ├──► [User Selects Prediction]
     │         │         └──► ["Not Right?"] ──► [Manual Search]
     │         │
     │         └──► [Confidence <60%] ──► [Manual Search]
     │
     ├──► [Manual Search] ──► [Type food name] ──► [Results List] ──► [Select]
     │
     └──► [Barcode Scan] ──► [Product Identified] ──► [Select]
               │
               ▼ (all paths converge here)
         [Nutrition Info Screen]
           - Calories, Protein, Carbs, Fat
           - Portion Size Selector
               │
               ▼
         [Confirm Log]
               │
               ▼
         [Daily Macros Updated]
```

---

## Flow 4: Budget Protein Planner

```
[Nutrition Tab]
     │
     ▼
["Budget Planner" Button]
     │
     ▼
[Budget Input Screen]
  - Weekly Budget (EGP slider or keyboard)
  - Dietary Restrictions (checkboxes)
     │
     ▼
[Tap "Generate Plan"]
     │
     ▼
[Loading (calculating against market prices)]
     │
     ▼
[7-Day Plan Screen]
  ┌───────────────────────────────┐
  │  Day 1 — 2,200 kcal / 160g P │
  │  Breakfast: Eggs + Cheese     │
  │  Lunch: Foul + Chicken Thigh  │
  │  ...                          │
  └───────────────────────────────┘
     │
     ├──► [Swipe to next day]
     ├──► ["Shopping List" tab] ──► [Itemized list with EGP costs]
     ├──► ["Find Nearby" tab] ──► [Map with partner merchant pins]
     │
     ▼
[Save Plan / Regenerate]
```

---

## Flow 5: Merchant Deal Discovery & Redemption

```
[Home or "Deals" Tab]
     │
     ▼
[Map View Loads]
  - Merchant markers shown (color-coded by type)
  - Filter bar at top
     │
     ▼
[Tap Merchant Marker]
     │
     ▼
[Merchant Card Slides Up]
  - Name, Rating, Category
  - Offers List (scrollable)
     │
     ▼
[Tap "Get Deal"]
     │
     ▼
[QR Code Generated]
  - Show QR + Offer Details
  - Countdown timer (24h expiry)
     │
     ▼
[At Merchant — Partner Scans QR]
     │
     ▼
[Transaction Recorded]
     │
     ▼
[Push Notification: "Your discount was applied! Rate your experience."]
     │
     ▼
[Rating Prompt (1–5 stars + optional comment)]
```

---

## Flow 6: Partner Onboarding (Merchant)

```
[partner.fitx.app]
     │
     ▼
[Landing Page — Partner Benefits]
     │
     ▼
["Apply to Join" CTA]
     │
     ▼
[Partner Application Form]
  - Business name
  - Category (Butcher / Gym / Supplements / Restaurant)
  - Address + Location Pin
  - Phone + WhatsApp
  - License/ID upload
     │
     ▼
[Submit Application]
     │
     ▼
[Admin Review (24-48h)]
     │
     ├──► [Approved] ──► [Welcome Email with Dashboard Login]
     │         │
     │         ▼
     │    [First Login → Dashboard Tour]
     │         │
     │         ▼
     │    [Create First Offer]
     │
     └──► [Rejected] ──► [Email with reason]
```

---

## Flow 7: Workout Buddy Matching

```
[Community Tab]
     │
     ▼
["Find Workout Buddy" Button]
     │
     ▼
[System Checks: goal, schedule, location]
     │
     ▼
[3 Suggested Buddy Profiles]
  (anonymized: first name + goal)
     │
     ▼
[Tap "Connect" on one profile]
     │
     ▼
[Match Request Sent]
     │
     ▼
[Target User Receives Notification]
     │
     ├──► [Accepts] ──► [Both see schedule + Messaging enabled]
     └──► [Declines] ──► [Requester shown other suggestions]
```
