# FitX — Product Requirements Document (PRD)
**Version:** 1.0.0  
**Status:** Draft  
**Last Updated:** 2025  
**Owner:** FitX Product Team

---

## 1. Executive Summary

FitX is an AI-powered smart fitness ecosystem tailored specifically for Egyptian users. It bridges the gap between expensive global fitness apps and the local Egyptian market by offering hyper-localized nutrition guidance, AI-driven real-time coaching, gamified community engagement, and a local merchant network that rewards both users and businesses.

The product vision: *"A personal trainer, nutritionist, and fitness community in your pocket — priced for the Egyptian street."*

---

## 2. Problem Statement

| # | Problem | Impact |
|---|---------|--------|
| 1 | Global fitness apps are priced in USD and suggest inaccessible foods (quinoa, salmon) | High frustration, low retention |
| 2 | Beginners train without guidance, leading to injuries | Health risk + churn |
| 3 | 90% of users quit gyms within a month due to boredom and lack of accountability | Revenue loss, brand failure |
| 4 | No app maps local protein sources (butchers, supplement shops) to the user's budget | Unmet need, massive opportunity |
| 5 | Lack of Arabic-native, culturally adapted fitness coaching | Alienation of core target market |

---

## 3. Goals & Objectives

### Product Goals
- Launch a zero-friction fitness app with free tier that acquires users at scale.
- Convert ≥15% of free users to Pro within 6 months.
- Build a local merchant network of ≥500 partners in Year 1.
- Achieve MAU of 200,000 within 12 months post-launch.

### Business Goals
- Achieve profitability by Month 18 through subscription + commission revenue.
- Establish FitX as the #1 fitness app in Egypt within 24 months.
- Expand to MENA markets (KSA, UAE, Jordan) by Year 3.

### User Goals
- Enable users to train safely without a personal trainer.
- Help users eat healthy within their real budget.
- Make fitness social, fun, and habit-forming.

---

## 4. Target Users

### Primary
- Egyptian youth aged 18–35 (university students + young professionals)
- Budget-conscious, smartphone-native, Arabic-first

### Secondary
- Personal trainers seeking client management tools
- Local gym owners wanting competitive engagement tools
- Local merchants (butchers, supplement stores) seeking targeted customers

---

## 5. User Personas Summary

| Persona | Type | Key Need |
|---------|------|----------|
| Ahmed (20, student) | Free User | Safe workout plan + cheap protein guide |
| Sara (27, professional) | Pro User | Quick 15-min workouts + precise calorie tracking |
| Coach Khaled (35) | Trainer | Client monitoring dashboard |
| Abu Hassan (45, butcher) | Merchant Partner | Reach fitness-conscious local customers |
| Admin (FitX team) | Maestro | Full system control + analytics |

*See Personas.md for detailed profiles.*

---

## 6. Core Features

### 6.1 AI-Powered Training (Bio-Tech Training)

| Feature | Description | Tier |
|---------|-------------|------|
| AI Pose Correction | Real-time camera-based form analysis using on-device ML | Pro |
| Adaptive Training | Adjusts workout intensity based on wearable data or self-report | Pro |
| Emergency Workout Generator | 15-min routines for busy days with one tap | Free + Pro |
| Biological Clock Training | Schedules workouts based on user's chronotype goals | Free + Pro |

### 6.2 Localized Nutrition Engine

| Feature | Description | Tier |
|---------|-------------|------|
| Egyptian Food Recognition | Camera-based food logging for local dishes (koshari, foul, hawawshi) | Free |
| Budget Protein Planner | Generates a weekly protein meal plan based on user's stated budget | Free + Pro |
| Smart Butcher Map | Maps nearby high-quality meat cuts at best prices | Pro |
| Seasonal Food Radar | Alerts users to seasonal foods for optimal nutrition/cost ratio | Free |
| Fridge Rescue | User inputs available ingredients → app suggests a healthy meal | Free |

### 6.3 Gamification & Community

| Feature | Description | Tier |
|---------|-------------|------|
| Gym Mayor | Monthly leaderboard; top check-in user becomes "Mayor" | Free |
| Voice Coach | AI personality coach with motivational voice messages | Pro |
| Workout Buddy | Matches users with local partners of same goal + schedule | Free |
| Map Challenges | Walking/running challenges framed as virtual travel journeys | Free |

### 6.4 Merchant & Partner Dashboard

| Feature | Description | Tier |
|---------|-------------|------|
| Offer Broadcast | Partners post deals visible to nearby fitness users | Partner |
| Customer Analytics | Basic footfall and conversion stats from app referrals | Partner |
| Rating System | Users rate purchases; <4 stars triggers partner review/suspension | System |

---

## 7. Feature Prioritization (MoSCoW)

### Must Have (MVP)
- User registration & onboarding
- Workout library (free plans, safe exercises)
- Food logging via camera + manual entry (Egyptian food DB)
- Budget protein planner
- Basic gamification (streaks, points, map challenges)
- Merchant listing & map view

### Should Have (v1.1)
- AI pose correction (Pro)
- Adaptive training engine
- Voice coach personality
- Workout Buddy matching
- Partner dashboard (offer management)

### Could Have (v2.0)
- Wearable integration (Apple Watch, Garmin, Samsung Health)
- Nutrition AI with macro precision
- Video exercise library with Arabic narration
- B2B white-label for gyms

### Won't Have (Now)
- Live streaming workouts
- Doctor/dietitian consultations (liability)
- Hardware devices

---

## 8. Success Metrics (KPIs)

| Metric | Target (Month 6) | Target (Month 12) |
|--------|-----------------|------------------|
| MAU | 50,000 | 200,000 |
| DAU/MAU Ratio | 30% | 40% |
| Pro Conversion Rate | 10% | 15% |
| Day 30 Retention | 25% | 35% |
| Merchant Partners | 100 | 500 |
| App Store Rating | ≥4.3 | ≥4.6 |
| Crash-Free Sessions | 99.5% | 99.8% |

---

## 9. Assumptions & Constraints

### Assumptions
- Users have Android or iOS smartphones with cameras.
- Majority of Egyptian users are on mobile data (not WiFi).
- Local merchants are willing to offer ≥10% discounts for app referrals.

### Constraints
- Budget: Bootstrap phase; infrastructure must remain low-cost.
- Team: Small dev team initially (2–3 engineers).
- Regulation: Must comply with Egyptian data protection laws.
- Language: App must be fully RTL Arabic with optional English.

---

## 10. Out of Scope

- Web app (mobile-first, app-only for MVP)
- Medical diagnosis or clinical nutrition
- Live video consultations
- Non-Egyptian food databases in MVP

---

## 11. Dependencies

| Dependency | Type | Risk |
|------------|------|------|
| Google ML Kit / TensorFlow Lite | AI Pose Detection | Medium |
| Firebase / Supabase | Backend BaaS | Low |
| Fawry / InstaPay | Payment Processing | Low |
| Google Maps SDK | Location & Merchant Map | Low |
| App Store / Play Store | Distribution | Low |

---

## 12. Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| Low lighting degrades AI pose detection | High | Medium | Graceful fallback + user notification |
| No smartwatch = limited adaptive training | High | Medium | Self-report (1–10 fatigue scale) fallback |
| Merchant fraud / low quality products | Medium | High | Rating system + 4-star threshold enforcement |
| High server costs at scale | Low | High | 90% offline processing; cloud only for Pro AI features |
| Competitor copies model | Medium | Medium | First-mover advantage + community moat |

---

## 13. Timeline Overview

| Phase | Duration | Deliverable |
|-------|---------|-------------|
| Discovery & Design | Month 1–2 | Wireframes, Design System, DB Schema |
| MVP Development | Month 3–5 | Core app (free tier) on Android |
| Beta Testing | Month 6 | Closed beta with 500 users |
| Launch v1.0 | Month 7 | Public launch on Play Store |
| iOS Launch | Month 8 | App Store submission + approval |
| v1.1 (Pro Features) | Month 9–11 | AI coach, pose detection, partner dashboard |
| Growth & Expansion | Month 12+ | Marketing push, merchant network scale-up |

---

## 14. Approval

| Role | Name | Status |
|------|------|--------|
| Founder / Product Lead | Mohammed Elhetawy | ✅ Owner |
| Operations Lead | Seif | Pending |
| Tech Lead | TBD | Pending |