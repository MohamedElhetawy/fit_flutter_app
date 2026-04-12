# FitX — Workout Generation & Progression Logic
**Version:** 1.0.0  
**Status:** Implementation Ready  
**Purpose:** Adaptive Training Algorithms

---

## 1. Initial Plan Generation (The Base 4-Week Block)

### 1.1 Goal-Based Templates (Seed Data)
| Goal | Frequency | Focus |
|------|-----------|-------|
| **LOSE_WEIGHT** | 4 days/week | High Intensity (HIIT) + Compound Lifts (3 sets/12-15 reps) |
| **BUILD_MUSCLE** | 5 days/week | Hypertrophy (4 sets/8-12 reps, 1 min rest) |
| **STAY_ACTIVE** | 3 days/week | Full Body (3 sets/10 reps, moderate weight) |

### 1.2 Equipment Filtering (Subset Selection)
If `user_profile.equipment` does not contain `BARBELL`:
- Map `exercise_id: 'bb_bench_press'` -> `exercise_id: 'db_bench_press'` (Dumbbell fallback).
- If no weights: Map to `bodyweight_pushups`.

---

## 2. Intra-Workout Adaptation (Real-Time)

### 2.1 The "RPE-8 Rule"
If a set is completed with RPE (Rate of Perceived Exertion) < 8:
- **Immediate action:** Increase weight for the next set by `2.5kg` (or `min_increment`).
- **Log trigger:** Mark as `overshoot_prevented`.

### 2.2 Muscle Fatigue Check (Soreness Input)
Pre-workout questionnaire:
- "Are your legs sore (1-5)?"
- If `score >= 4`: Auto-replace `Squats` with `Lying Leg Curls` or reduce `Squat Volume` by 50%.

---

## 3. Progressive Overload (Weekly Cycle)

### 3.1 Volume Benchmarking
`TotalVolume = Weight × Reps × Sets`
- **Goal:** Increase `TotalVolume` by 2-5% week-over-week for compound lifts.
- **Plateau Rule:** If no volume increase for 3 weeks, trigger "Deload Week" (50% intensity).

### 3.2 PR (Personal Record) Validation
A PR is valid only if:
1. Form Score (AI) >= 0.8.
2. Complete Range of Motion (ROM) detected.
3. No assistance detected/logged.

---

## 4. Emergency "15-Min Saver" Logic (The Quick-Fix)
If the user triggers `EMERGENCY_SAVER` (Time < 20 mins):
- **Structure:** AMRAP (As Many Reps As Possible) Circuit.
- **Exercises:** 
    1. Bodyweight Squats (60s)
    2. Pushups (60s)
    3. Mountain Climbers (60s)
    4. Planks (60s)
- **Rest:** 15s between rounds.
- **Repeat:** 3 rounds.
- **Outcome:** Maintains `Streak` and provides `+30 XP`.
