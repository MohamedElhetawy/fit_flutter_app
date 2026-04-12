# FitX — Software Requirements Specification (SRS)
**Version:** 1.0.0  
**Status:** Draft  
**Standard:** IEEE 830 Adapted  
**Date:** 2025

---

## 1. Introduction

### 1.1 Purpose
This SRS defines the functional and non-functional requirements for the FitX mobile application. It serves as the binding contract between the product team, engineering team, and QA team throughout development.

### 1.2 Scope
FitX is a cross-platform mobile application (iOS + Android) with a cloud backend, consisting of:
- **FitX User App** — Consumer-facing mobile app
- **FitX Partner Dashboard** — Web-based portal for merchant partners
- **FitX Admin Panel** — Internal management portal (Maestro)
- **FitX Backend API** — RESTful API serving all clients
- **FitX AI Service** — Inference microservice for pose detection + food recognition

### 1.3 Definitions

| Term | Definition |
|------|------------|
| MAU | Monthly Active Users |
| On-device | Processing that runs locally on the user's phone, no server needed |
| Pro | Paid subscription tier |
| Maestro | Admin / super-user role (internal team) |
| Partner | Merchant (butcher, gym, supplement shop) registered on platform |
| Check-in | User recording a gym visit in the app |
| Fridge Rescue | Feature where user inputs ingredients and gets a meal suggestion |

### 1.4 References
- FitX Master Blueprint (FitX_Master_Blueprint.pdf)
- PRD v1.0.0
- BRD v1.0.0

---

## 2. Overall Description

### 2.1 Product Perspective
FitX operates as a standalone mobile-first application with a serverless-leaning backend. The system uses on-device AI for 90% of processing to reduce latency and infrastructure costs. Cloud is used for social features, analytics, and premium AI inference.

### 2.2 System Architecture Overview
```
[Mobile App] ←→ [API Gateway] ←→ [Core API Service]
                                        ↓
                               [Firebase Auth]
                               [PostgreSQL DB]
                               [AI Microservice]
                               [Storage (R2/S3)]
                               [Push Notifications]
```

### 2.3 Product Functions (High Level)
1. User Identity & Onboarding
2. Workout Planning & Execution
3. AI Pose Correction (on-device + cloud fallback)
4. Food Logging & Nutrition Tracking
5. Budget-Based Meal Planning
6. Merchant Map & Offers
7. Gamification Engine (points, badges, leaderboards)
8. Workout Buddy Matching
9. Push Notifications & Voice Coaching
10. Partner Dashboard
11. Admin Panel (Maestro)
12. Analytics & Reporting

### 2.4 User Classes

| Class | Access Level | Description |
|-------|-------------|-------------|
| Guest | Read-only browse | Can view app landing, no personal data |
| Free User | Standard | Core features, ads shown |
| Pro User | Premium | All features, no ads |
| Partner | Dashboard access | Merchant management only |
| Trainer | Client-view | View assigned clients' progress |
| Admin (Maestro) | Full | All system access |

---

## 3. Functional Requirements

### 3.1 Authentication & User Management

**REQ-AUTH-001:** The system SHALL support registration via phone number + OTP (SMS verification).  
**REQ-AUTH-002:** The system SHALL support login via Google OAuth.  
**REQ-AUTH-003:** The system SHALL support biometric login (fingerprint/Face ID) after initial auth.  
**REQ-AUTH-004:** OTP SHALL expire after 5 minutes.  
**REQ-AUTH-005:** After 5 failed OTP attempts, account SHALL be locked for 15 minutes.  
**REQ-AUTH-006:** The system SHALL support password reset via OTP.  
**REQ-AUTH-007:** JWT tokens SHALL expire after 24 hours; refresh tokens after 30 days.  
**REQ-AUTH-008:** All sessions SHALL be invalidated on password change.  

### 3.2 Onboarding

**REQ-ONBOARD-001:** New users SHALL complete a 5-step onboarding flow capturing: name, age, weight, height, fitness goal.  
**REQ-ONBOARD-002:** Onboarding SHALL include a budget input step (EGP/month for nutrition).  
**REQ-ONBOARD-003:** Onboarding SHALL detect user's location (with permission) to pre-load local merchant data.  
**REQ-ONBOARD-004:** Onboarding completion SHALL trigger generation of a personalized 4-week workout plan.  
**REQ-ONBOARD-005:** Users SHALL be able to skip onboarding and complete it later; features requiring profile data SHALL prompt completion.  

### 3.3 Workout Engine

**REQ-WORK-001:** The system SHALL maintain a library of ≥200 exercises with Arabic name, description, muscle group, equipment requirement, and difficulty level.  
**REQ-WORK-002:** Each exercise SHALL have at minimum 1 demonstration image; Pro exercises SHALL have video.  
**REQ-WORK-003:** The system SHALL generate a weekly workout plan based on: goal, available days/week, equipment access, and fitness level.  
**REQ-WORK-004:** The Emergency Workout Generator SHALL produce a workout in <2 seconds given: available time (5–45 min), location (home/gym), and equipment.  
**REQ-WORK-005:** The system SHALL track sets, reps, weight, and rest time per session.  
**REQ-WORK-006:** The system SHALL allow users to log workout completion with a one-tap "Done" confirmation per set.  
**REQ-WORK-007:** The system SHALL calculate total volume (sets × reps × weight) per session and display weekly trend.  
**REQ-WORK-008:** Rest timer SHALL auto-start between sets with configurable duration.  
**REQ-WORK-009:** Workout plans SHALL adapt every 4 weeks based on progression data.  

### 3.4 AI Pose Correction

**REQ-AI-POSE-001:** The system SHALL use on-device pose estimation (ML Kit PoseDetection / TensorFlow Lite) to analyze exercise form via the front or rear camera.  
**REQ-AI-POSE-002:** Supported exercises for pose analysis: squat, push-up, shoulder press, bicep curl, deadlift (5 exercises in MVP).  
**REQ-AI-POSE-003:** The system SHALL provide real-time audio feedback in Egyptian Arabic when a form error is detected.  
**REQ-AI-POSE-004:** Feedback latency SHALL be ≤500ms from detection to audio output.  
**REQ-AI-POSE-005:** When ambient light is insufficient (luminance <50 lux), the system SHALL pause analysis and notify the user to move to a brighter area.  
**REQ-AI-POSE-006:** AI Pose Correction SHALL be a Pro-only feature.  

### 3.5 Adaptive Training

**REQ-ADAPT-001:** If a wearable is connected (Apple Health / Google Fit), the system SHALL read resting heart rate and sleep quality to adjust workout intensity.  
**REQ-ADAPT-002:** If no wearable is connected, the system SHALL display a fatigue self-report scale (1–10) before each workout.  
**REQ-ADAPT-003:** If fatigue score ≥7, the system SHALL suggest a light/recovery alternative workout.  
**REQ-ADAPT-004:** Adaptive training SHALL be a Pro feature; fatigue check-in is available to all users.  

### 3.6 Food Logging & Nutrition Tracking

**REQ-NUT-001:** Users SHALL be able to log food via camera (AI recognition), barcode scan, or manual search.  
**REQ-NUT-002:** The Egyptian food database SHALL contain ≥500 local dishes and ingredients at launch.  
**REQ-NUT-003:** Camera food recognition SHALL identify the dish within 3 seconds with ≥80% accuracy on top-20 common Egyptian dishes.  
**REQ-NUT-004:** The system SHALL display calories, protein, carbs, and fat per logged item.  
**REQ-NUT-005:** Daily macro targets SHALL be calculated from user's profile (weight, height, age, goal, activity level) using the Mifflin-St Jeor equation.  
**REQ-NUT-006:** The system SHALL show a daily nutrition ring (circular progress chart) for each macro.  
**REQ-NUT-007:** Users SHALL be able to log water intake with configurable daily target.  
**REQ-NUT-008:** The Fridge Rescue feature SHALL accept a list of user-input ingredients and return ≥3 healthy meal suggestions within 5 seconds.  

### 3.7 Budget Protein Planner

**REQ-BUDGET-001:** Users SHALL input their weekly/monthly food budget in EGP.  
**REQ-BUDGET-002:** The system SHALL generate a 7-day high-protein meal plan using foods available in Egyptian markets within the stated budget.  
**REQ-BUDGET-003:** Each meal plan SHALL include a shopping list with estimated costs.  
**REQ-BUDGET-004:** The system SHALL update food prices in the database weekly (automated scraping or manual update).  
**REQ-BUDGET-005:** The Protein Planner SHALL be available in Free tier (3 plans/month) and unlimited in Pro.  

### 3.8 Merchant Map & Local Commerce

**REQ-MERCHANT-001:** The system SHALL display a map of verified partner merchants (butchers, supplement stores, gyms) within a configurable radius (default 5km).  
**REQ-MERCHANT-002:** Each merchant profile SHALL include: name, address, rating, operating hours, current offers, and product categories.  
**REQ-MERCHANT-003:** Users SHALL be able to tap a merchant offer to generate a unique discount QR code valid for 24 hours.  
**REQ-MERCHANT-004:** The system SHALL track and attribute purchases made via the app for commission calculation.  
**REQ-MERCHANT-005:** Merchant search SHALL support filtering by type, rating, and distance.  
**REQ-MERCHANT-006:** A merchant with an average rating <4.0 stars (minimum 20 ratings) SHALL be automatically suspended from appearing on user maps.  

### 3.9 Gamification Engine

**REQ-GAME-001:** The system SHALL award points for: daily workout completion (50 pts), food logging (10 pts per meal), check-in (25 pts), streak maintenance (bonus multiplier).  
**REQ-GAME-002:** The system SHALL maintain a monthly leaderboard per gym (check-ins), with the top user awarded "Gym Mayor" badge.  
**REQ-GAME-003:** Streak counter SHALL reset to 0 if user misses ≥2 consecutive planned workout days.  
**REQ-GAME-004:** The system SHALL offer weekly map challenges (e.g., "Walk the distance from Cairo to Alexandria this month").  
**REQ-GAME-005:** Badges SHALL be unlockable for: first workout, 7-day streak, 30-day streak, first food scan, Gym Mayor, Workout Buddy match.  
**REQ-GAME-006:** All gamification data SHALL be viewable in a "My Achievements" screen.  

### 3.10 Workout Buddy System

**REQ-BUDDY-001:** The system SHALL match users with nearby users sharing: similar goal, similar schedule, same neighborhood (within 3km).  
**REQ-BUDDY-002:** Buddy matching SHALL require both users to accept the match.  
**REQ-BUDDY-003:** Matched buddies SHALL be able to see each other's workout schedule and completion status.  
**REQ-BUDDY-004:** The system SHALL allow in-app messaging between matched buddies (text only, no media in MVP).  
**REQ-BUDDY-005:** Users may unmatch at any time; no explanation required.  

### 3.11 Voice Coach

**REQ-VOICE-001:** The Pro voice coach SHALL have a defined personality: energetic, Egyptian-Arabic, humorous, encouraging.  
**REQ-VOICE-002:** The system SHALL send motivational push notifications with pre-recorded audio clips at configurable times.  
**REQ-VOICE-003:** The voice coach SHALL announce workout start countdowns, set completions, and rest period ends.  
**REQ-VOICE-004:** If user has missed 3 days, the system SHALL send a gentle "We miss you" voice message.  
**REQ-VOICE-005:** Voice coach SHALL be toggleable on/off in user settings.  

### 3.12 Partner Dashboard

**REQ-PARTNER-001:** Partners SHALL access a web dashboard at partner.fitx.app.  
**REQ-PARTNER-002:** Partners SHALL be able to create, edit, and schedule promotional offers.  
**REQ-PARTNER-003:** Partners SHALL view: total referrals from FitX, QR code redemptions, and average rating.  
**REQ-PARTNER-004:** Partners SHALL receive automated email/SMS notifications when their rating drops below 4.2 (warning threshold).  
**REQ-PARTNER-005:** Partners SHALL NOT have access to individual user data (anonymized aggregate only).  

### 3.13 Admin Panel (Maestro)

**REQ-ADMIN-001:** Admins SHALL access a secure web panel at admin.fitx.app.  
**REQ-ADMIN-002:** Admins SHALL be able to: add/edit/delete exercises, update food database prices, approve/reject new merchant partners.  
**REQ-ADMIN-003:** Admins SHALL view real-time dashboards for: MAU, revenue, Pro conversion rate, merchant network size.  
**REQ-ADMIN-004:** Admins SHALL be able to manually suspend any user or partner account.  
**REQ-ADMIN-005:** All admin actions SHALL be logged with timestamp and admin ID.  

---

## 4. Non-Functional Requirements (Summary)

*See NFR.md for full specification.*

| Category | Requirement |
|----------|-------------|
| Performance | App launch <2s; API responses <300ms p95 |
| Availability | 99.9% uptime for API; offline mode for core features |
| Scalability | Architecture must support 1M users without redesign |
| Security | HTTPS everywhere; data encrypted at rest |
| Usability | Task completion rate ≥90% in usability testing |
| Accessibility | WCAG 2.1 AA for Arabic RTL layout |
| Localization | Full RTL Arabic support; Egyptian Arabic dialect in voice |
| Battery | AI pose correction must not drain >5% battery per 30-min session |

---

## 5. Interface Requirements

### 5.1 User Interface
- Native mobile (React Native or Flutter)
- RTL layout by default for Arabic
- Minimum tap target size: 44×44 pt (iOS HIG standard)
- Support iOS 14+ and Android 8.0+ (API 26+)

### 5.2 Hardware Interfaces
- Camera: pose detection + food recognition
- GPS: location-based merchant map
- Accelerometer/Gyroscope: step counting for map challenges
- Biometrics: fingerprint/Face ID for app lock
- Bluetooth: wearable connectivity (optional)

### 5.3 Software Interfaces
- Google ML Kit: pose detection
- TensorFlow Lite: custom food recognition model
- Firebase Auth: authentication
- Fawry / Paymob: payment processing
- Google Maps SDK: merchant map
- Apple HealthKit / Google Fit: wearable data

### 5.4 Communication Interfaces
- HTTPS/REST for all API communication
- WebSocket for real-time features (buddy chat, leaderboard updates)
- FCM (Firebase Cloud Messaging) for push notifications
- SMS via Twilio or local provider for OTP

---

## 6. Data Requirements

### 6.1 Data Retention
- User workout logs: retained for 3 years
- Food logs: retained for 2 years  
- Location data: NOT stored; used only in-session
- Analytics events: 13 months rolling window

### 6.2 Data Backup
- Database: daily automated backups, 30-day retention
- Recovery Time Objective (RTO): 4 hours
- Recovery Point Objective (RPO): 24 hours

---

## 7. Quality Requirements

**Reliability:** Crash-free session rate ≥99.5%  
**Maintainability:** Code coverage ≥80% for all core modules  
**Testability:** All API endpoints must have automated integration tests  
**Portability:** App must run on both iOS and Android from a single codebase (React Native / Flutter)