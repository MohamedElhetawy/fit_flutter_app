# FitX — Use Cases
**Version:** 1.0.0

---

## UC-01: User Registers with Phone Number

**Actor:** Guest User  
**Goal:** Create a FitX account  
**Preconditions:** User has a valid Egyptian mobile number; app installed  

**Main Flow:**
1. User opens app → taps "Create Account"
2. User enters phone number
3. System validates format (Egyptian +20 prefix)
4. System sends OTP via SMS
5. User enters 6-digit OTP
6. System validates OTP (not expired, matches)
7. System creates account and issues JWT
8. System redirects to Onboarding Flow

**Alternative Flows:**
- 4a. SMS fails → Show "Resend" after 60s
- 6a. OTP expired → Prompt to resend
- 6b. OTP wrong (≤4 attempts) → Show retry error
- 6c. OTP wrong (5th attempt) → Lock for 15 min

**Postconditions:** User account created, user logged in, onboarding begins

---

## UC-02: User Completes Onboarding

**Actor:** Newly Registered User  
**Goal:** Set up personalized fitness profile  

**Main Flow:**
1. User is prompted through 7 onboarding screens
2. User selects fitness goal
3. User enters weight, height, age
4. User selects fitness level
5. User sets food budget
6. User grants (or denies) location permission
7. User grants (or denies) notification permission
8. System generates personalized 4-week plan
9. User sees "Plan Ready" screen and taps "Let's Go!"

**Alternative Flows:**
- Any screen: User taps "Skip" → Onboarding marked incomplete, prompted again later
- 6a. User denies location → Merchant map shows nationwide list, no local filter

**Postconditions:** User profile complete, workout plan generated, Home screen shown

---

## UC-03: User Starts a Workout Session

**Actor:** Free User / Pro User  
**Goal:** Complete a guided workout  

**Main Flow:**
1. User opens Home → taps "Today's Workout"
2. System shows workout plan for the day
3. User taps "Start Workout"
4. System displays first exercise: name, illustration, sets/reps
5. User performs set → taps "Done"
6. System auto-starts rest timer
7. Timer ends → System shows next set
8. After all sets: System shows next exercise
9. After all exercises: System shows "Workout Complete" screen with summary
10. System awards points, updates streak counter

**Alternative Flows:**
- 5a. User taps "Skip" → Exercise skipped, marked in session log
- Any point: User taps "End Early" → Session saved as partial; no streak break if >50% complete
- Pro user only: 4a. User taps "AI Coach" → Camera activates for pose detection

---

## UC-04: AI Pose Correction During Exercise (Pro)

**Actor:** Pro User  
**Goal:** Get real-time form feedback  
**Preconditions:** Pro subscription active; sufficient lighting; camera permission granted  

**Main Flow:**
1. During workout, user taps "AI Coach" button
2. System requests camera permission (if not granted)
3. Camera activates; system starts pose detection
4. User performs exercise in front of camera
5. System detects body landmarks in real-time
6. System compares landmarks against correct form model
7. If form error detected → System plays audio cue in Arabic (e.g., "ارفع كوعك أكتر")
8. User corrects form → System confirms "ممتاز!" or continues monitoring
9. Set completes → User taps Done → Camera deactivates

**Alternative Flows:**
- 3a. Insufficient lighting (lux <50) → System pauses and displays: "الإضاءة ضعيفة يا بطل، روح مكان أنور"
- 2a. Camera permission denied → Show fallback text instructions
- Feature unavailable for current exercise → Button grayed out with tooltip

---

## UC-05: User Logs a Meal via Camera

**Actor:** Free User / Pro User  
**Goal:** Log a meal by taking a photo  

**Main Flow:**
1. User opens Nutrition tab → taps "+ Log Meal"
2. User selects "Camera" option
3. Camera opens
4. User frames the food and taps capture
5. On-device AI model identifies food within 3 seconds
6. System displays top 3 predictions with confidence %
7. User selects correct prediction (or taps "Not right? Search manually")
8. System shows nutrition info (cal, protein, carbs, fat)
9. User confirms portion size (default or custom grams)
10. Meal logged; daily macros update

**Alternative Flows:**
- 5a. AI confidence < 60% for all predictions → Automatically offer search
- 7a. User cannot find food → User manually enters custom entry

---

## UC-06: User Gets Budget Protein Plan

**Actor:** Free User / Pro User  
**Goal:** Receive an affordable weekly protein meal plan  

**Main Flow:**
1. User opens Nutrition → "Budget Protein Planner"
2. User enters weekly budget in EGP (or confirms existing)
3. User selects any dietary restrictions
4. User taps "Generate Plan"
5. System calculates optimal plan using local market prices
6. System displays 7-day plan with meals and macros
7. System shows shopping list with total estimated cost
8. System shows nearest partner merchants for shopping
9. User can save plan or tap "Regenerate"

---

## UC-07: User Finds a Local Merchant Deal

**Actor:** Free User / Pro User  
**Goal:** Discover and use a merchant discount  

**Main Flow:**
1. User opens "Deals" tab
2. Map shows nearby merchant markers
3. User taps a merchant marker
4. Merchant profile card slides up: name, rating, offers list
5. User taps "Get Deal" on an offer
6. System generates unique QR code (valid 24h)
7. User visits merchant, shows QR code
8. Merchant scans QR → Discount applied
9. System records transaction → Commission queued

**Alternative Flows:**
- 1a. Location permission denied → Show text-based list of nearby merchants by district
- 5a. Offer usage limit reached → Show "Offer expired" message

---

## UC-08: Partner Posts a New Offer

**Actor:** Merchant Partner  
**Goal:** Broadcast a promotional offer to nearby FitX users  

**Main Flow:**
1. Partner logs in to partner.fitx.app
2. Partner navigates to "Offers Manager"
3. Partner taps "New Offer"
4. Partner fills: product name, discount type (%), start date, end date, usage limit
5. Partner taps "Submit for Review"
6. System validates offer (no misleading claims, valid dates)
7. Admin approves (auto-approved if partner rating ≥4.5)
8. Offer becomes visible to users within merchant's coverage zone

**Alternative Flows:**
- 6a. Offer fails validation → System shows specific rejection reason
- 7a. Admin rejects → Partner receives notification with reason

---

## UC-09: User Earns Gym Mayor Badge

**Actor:** Free User / Pro User  
**Goal:** Win the monthly Gym Mayor title for their gym  

**Main Flow:**
1. User checks in at gym via app (GPS-confirmed)
2. System awards 25 points and increments gym check-in counter for the month
3. At end of month: System calculates top check-in user per gym
4. System awards "Gym Mayor" badge and 500 bonus points
5. User receives push notification: "أنت عمدة الجيم لهذا الشهر!"
6. Badge displayed prominently on user profile

---

## UC-10: Admin Suspends a Merchant

**Actor:** Admin (Maestro)  
**Goal:** Suspend a low-quality merchant partner  

**Main Flow:**
1. System auto-flags merchant with rating <4.0 (after 20+ ratings)
2. Admin reviews: average rating, recent reviews, transaction history
3. Admin taps "Suspend Partner"
4. Admin selects reason from dropdown
5. System removes merchant from all user-facing maps immediately
6. System sends automated notification to merchant explaining suspension
7. System issues credit to recent customers (50 EGP FitX credit)
8. Action is logged with admin ID and timestamp

---

## UC-11: Workout Buddy Matching

**Actor:** Free User  
**Goal:** Find a local workout partner  

**Main Flow:**
1. User opens "Community" → "Find a Workout Buddy"
2. System searches for users within 3km with same goal and overlapping schedule
3. System presents 3 suggested buddy profiles (anonymized: first name + fitness goal)
4. User taps "Connect" on preferred profile
5. System sends match request to target user
6. Target user accepts
7. Both users see each other's schedule and can message in-app