# FitX — System Design (Firebase Architecture)
**Version:** 1.1.0

---

## 1. Core System Architecture

FitX utilizes a serverless, event-driven architecture powered by **Firebase**. This minimizes infrastructure overhead while providing real-time capabilities and seamless scaling.

### 1.1 Authentication (Firebase Auth)
**Responsibility:** Secure user identity management.
**Supported Providers:**
- Phone Number (Primary for Egyptian market)
- Google OAuth
- Apple ID
**Flow:**
- App handles sign-in → Firebase issues standard JWT → ID Token sent in headers for cross-service validation.

---

### 1.2 Data Layer (Cloud Firestore)
**Responsibility:** Primary NoSQL document database.
**Collections Structure:**
- `users`: Core profile data, stats, and settings.
- `workouts`: Workout plans, exercise library, and historical sessions.
- `nutrition`: Food logs, meal plans, and regional food price data.
- `gamification`: Points, badges, streaks, and gym leaderboards.
- `commerce`: Merchant profiles, offers, and transaction logs.

**Real-time Features:** Firestore Listeners power live leaderboard updates and buddy activity feeds without custom WebSocket servers.

---

### 1.3 Logic Layer (Cloud Functions)
**Responsibility:** Secure, server-side processing for complex business logic.
**Key Functions:**
- `onWorkoutCompleted`: Triggers points awarding, streak updates, and leaderboard increments.
- `generateMealPlan`: Integrates with LLMs (Claude) for budget-aware nutrition planning.
- `processRedemption`: Validates merchant QR codes and records commissions.
- `syncHealthData`: Background sync for wearable data (Health Connect / HealthKit).

---

### 1.4 AI & Machine Learning
**Responsibility:** Pose correction and food recognition.
**Execution:**
- **On-Device (ML Kit):** Real-time pose tracking and form analysis (no latency, offline-capable).
- **Cloud-Assisted (Functions):** Complex nutrition analysis and Fridge Rescue via Anthropic Claude API.

---

### 1.5 Storage & Media (Firebase Storage)
**Responsibility:** Hosting user-uploaded media and exercise video clips.
**Optimization:** Firebase Hosting provides the CDN layer for fast global delivery of static assets.

---

## 2. Gamification & Community
**Logic:** Event-driven via Firestore Triggers.
- `onCreate` on `workout_sessions` → Increment streak + Add points.
- `onUpdate` on `user_points` → Check for badge eligibility.
- **Leaderboards:** Aggregated using Firestore counters, providing real-time "Gym Mayor" statuses.

---

## 3. Merchant & Partner Ecosystem
**Flow:**
1. Partner creates an offer in the Dashboard (Web app).
2. User "Claims" offer → Generates a unique, expiring ID in Firestore.
3. Merchant scans QR → Cloud Function validates and marks as `redeemed`.
4. Commission logic runs automatically on successful redemption.

---

## 4. Background & Scheduled Tasks (Cloud Scheduler)
| Job | Schedule | Description |
|-----|----------|-------------|
| Market Price Sync | Weekly | Updates regional Egyptian food prices. |
| Leaderboard Reset | Monthly | Archives winners and resets monthly counters. |
| Streak Audit | Daily | Identifies at-risk streaks and triggers notifications. |
| Re-engagement | Daily | Sends personalized voice clips to inactive users. |