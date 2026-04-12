# FitX — Release Notes Template
**Format:** Used for every public release

---

## Release Notes v1.0.0 — Initial Launch 🎉
**Release Date:** TBD  
**Platform:** Android (Play Store)  
**Build:** 1.0.0 (100)

---

### What's New
- 🏋️ **Smart Workout Plans** — Get a personalized 4-week workout plan tailored to your goal, fitness level, and available equipment
- 📸 **Egyptian Food Recognition** — Point your camera at any Egyptian dish and instantly get its calories and macros — كشري, فول, حواوشي, and 500+ more
- 💰 **Budget Protein Planner** — Tell us your weekly budget and we'll build you a complete high-protein meal plan using ingredients from your local market
- 🧊 **Fridge Rescue** — Enter what's in your fridge; we'll suggest healthy, macro-counted meals you can make right now
- 🗺 **Local Deals Map** — Discover deals from verified butchers, supplement stores, and gyms in your neighborhood
- 🔥 **Streaks & Challenges** — Track your consistency, compete with friends for Gym Mayor, and virtually walk across Egypt with map challenges
- ⚡ **Emergency Workouts** — Tight on time? Get a personalized 5–45 minute workout generated in seconds
- 🌙 **Biological Clock Training** — Train at the optimal time for your goal (fat burn vs. muscle building)

### System Requirements
- Android 8.0 (API 26) or higher
- Camera required for food recognition
- Location permission for merchant map (optional but recommended)

---

## Release Notes v1.1.0 — Pro Launch
**Release Date:** TBD  
**Platform:** Android + iOS

### What's New
- 🤖 **AI Pose Correction (Pro)** — Your phone's camera becomes your personal trainer, giving real-time Arabic feedback on your form
- 🎙 **Voice Coach (Pro)** — An Egyptian Arabic coach who cheers you on, calls you out when you skip days, and celebrates your wins
- 💪 **Adaptive Training (Pro)** — The app reads your wearable data (or asks how you feel) to adjust workout intensity intelligently
- 🥩 **Smart Butcher Map (Pro)** — Find the best meat cuts for your diet goal, from verified local butchers
- 💳 **FitX Pro — 39 EGP/month** — Unlock all features including AI coach, unlimited meal plans, and exclusive partner discounts

### Bug Fixes
- Fixed: Arabic numerals not displaying correctly in calorie ring on some Android devices
- Fixed: Rest timer continuing after app was backgrounded
- Fixed: Budget planner not reflecting updated meat prices in some Cairo districts
- Improved: Camera food recognition accuracy for hawawshi improved from 71% to 84%
- Improved: App launch time reduced by 400ms on mid-range devices

---

# FitX — Changelog
**Format:** Keep a Changelog (keepachangelog.com)

---

## [Unreleased]
### Added
- Partner web dashboard v1

---

## [1.1.0] — 2025-Q3 (planned)
### Added
- AI Pose Correction feature (Pro)
- Voice Coach personality (Pro) 
- Adaptive training with fatigue check-in
- iOS App Store release
- Paymob credit card payment option
- Gym leaderboard (Gym Mayor feature)
- Workout Buddy matching system

### Changed
- Budget planner now shows nearest merchant for each shopping item
- Improved Egyptian food DB: 500 → 750 items

### Fixed
- Fixed Arabic number rendering in macro rings (#145)
- Fixed rest timer persisting after session end (#162)
- Fixed location permission crash on Android 12 (#178)

---

## [1.0.0] — 2025-Q2 (MVP Launch)
### Added
- Phone number registration + OTP verification
- Google OAuth login
- 7-step personalized onboarding
- Workout plan generator (4-week plans)
- Workout execution with rest timer
- Emergency workout generator
- Egyptian food database (500+ items)
- Camera food recognition (TFLite, top 20 dishes)
- Manual food log + macro tracking
- Budget protein planner
- Fridge Rescue (AI-powered recipes)
- Merchant map with local deals
- QR discount redemption
- Points + streaks + badges gamification
- Map challenges (walking)
- Push notifications (workout reminders, streak alerts)
- Admin panel
- Partner sign-up and offer management