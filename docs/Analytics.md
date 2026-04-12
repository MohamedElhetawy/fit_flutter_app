# FitX — Analytics Strategy
**Version:** 1.0.0

---

## 1. Analytics Philosophy

**Measure what matters. Never measure people.**

FitX analytics serve two purposes:
1. **Product improvement** — Understand where users get stuck, what features drive retention
2. **Business decisions** — Understand unit economics, growth levers, and revenue drivers

What we avoid:
- Selling data to third parties (never)
- Individual user surveillance
- Dark patterns driven by engagement metrics at expense of user wellbeing

---

## 2. Analytics Stack

| Tool | Purpose | Data |
|------|---------|------|
| Firebase Analytics | Mobile app event tracking | Anonymous user events |
| Sentry Performance | API performance traces | Request timing, error rates |
| Custom Admin Dashboard | Business KPIs | Aggregated metrics from DB |
| Logtail | Log-based analytics | Server-side events |

---

## 3. Event Taxonomy

### 3.1 Onboarding Events

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `onboarding_started` | User opens onboarding screen 1 | — |
| `onboarding_step_completed` | Each step completed | `step_number` (1–7), `step_name` |
| `onboarding_skipped` | User taps "Skip" | `step_number` |
| `onboarding_completed` | All 7 steps done | `goal`, `fitness_level`, `has_location` |

### 3.2 Workout Events

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `workout_started` | Tap "Start Workout" | `plan_id`, `workout_name`, `is_emergency` |
| `exercise_completed` | All sets done for one exercise | `exercise_id`, `sets`, `avg_weight_kg` |
| `exercise_skipped` | Tap "Skip" | `exercise_id`, `reason` (optional) |
| `workout_completed` | All exercises done | `duration_seconds`, `total_volume_kg`, `exercises_count` |
| `workout_ended_early` | Tap "End Early" | `completion_percent`, `duration_seconds` |
| `rest_timer_skipped` | Skip rest timer | `rest_remaining_seconds` |
| `ai_coach_activated` | Tap AI Coach button | `exercise_id` |
| `ai_coach_low_light` | Low light detected | — |
| `emergency_workout_generated` | Workout generator used | `duration_minutes`, `location` |

### 3.3 Nutrition Events

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `food_logged_camera` | Food logged via camera | `confidence_score`, `food_id`, `meal_type` |
| `food_logged_search` | Food logged via search | `food_id`, `meal_type` |
| `food_logged_barcode` | Food logged via barcode | `food_id` |
| `food_recognition_fallback` | Low confidence → manual | `confidence_score` |
| `budget_plan_generated` | Budget planner used | `budget_egp`, `protein_target_g` |
| `budget_plan_saved` | User saves plan | — |
| `fridge_rescue_used` | Fridge Rescue submitted | `ingredient_count` |
| `water_logged` | Water intake logged | `amount_ml` |
| `daily_macro_goal_reached` | User hits calorie target | `macro_type` |

### 3.4 Commerce Events

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `merchant_map_opened` | Deals tab opened | `has_location_permission` |
| `merchant_tapped` | Merchant marker tapped | `merchant_id`, `category`, `distance_m` |
| `offer_viewed` | Offer card seen | `offer_id`, `merchant_id` |
| `offer_redeemed` | QR generated | `offer_id`, `merchant_id`, `discount_percent` |
| `offer_expired` | QR expires before use | `offer_id` |
| `merchant_rated` | User submits rating | `merchant_id`, `rating`, `after_qr_use` |

### 3.5 Gamification Events

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `streak_updated` | Streak incremented | `new_streak`, `milestone_hit` |
| `streak_broken` | Streak reset | `broken_streak_length` |
| `badge_unlocked` | Badge awarded | `badge_id`, `badge_name` |
| `leaderboard_viewed` | Leaderboard screen opened | `gym_id`, `user_rank` |
| `checkin_completed` | Gym check-in | `gym_id` |
| `map_challenge_progress` | Steps logged toward challenge | `challenge_id`, `progress_percent` |
| `buddy_match_requested` | Send buddy request | — |
| `buddy_matched` | Both users accept | — |

### 3.6 Subscription Events

| Event Name | Trigger | Properties |
|------------|---------|------------|
| `pro_upgrade_screen_viewed` | Upgrade screen opened | `trigger` (feature gate / settings / home prompt) |
| `pro_trial_started` | 7-day trial activated | — |
| `pro_purchased` | Payment successful | `plan` (monthly/quarterly/annual), `payment_method`, `amount_egp` |
| `pro_purchase_failed` | Payment failed | `error_code`, `payment_method` |
| `pro_cancelled` | User cancels | `days_remaining` |
| `pro_expired` | Subscription lapses | `days_since_last_payment` |

---

## 4. Key Product Metrics (KPIs Dashboard)

### Acquisition
| Metric | Formula | Target (Month 6) |
|--------|---------|-----------------|
| New Registrations / Day | COUNT new users | 500/day |
| Onboarding Completion Rate | completed / started | ≥80% |
| D1 Retention | users active Day 1 / installs | ≥60% |

### Engagement
| Metric | Formula | Target |
|--------|---------|--------|
| DAU/MAU | DAU ÷ MAU | ≥30% |
| Sessions per Active User | sessions / DAU | ≥1.5 |
| Workout Completion Rate | completed / started sessions | ≥75% |
| Food Log Rate | users logging meals / DAU | ≥40% |

### Retention
| Metric | Target |
|--------|--------|
| Day 7 Retention | ≥35% |
| Day 30 Retention | ≥20% |
| Day 90 Retention | ≥12% |

### Revenue
| Metric | Formula | Target (Month 12) |
|--------|---------|------------------|
| Pro Conversion Rate | Pro users / Total users | ≥15% |
| MRR | Pro users × avg price | 200k EGP |
| ARPU | Revenue / MAU | ≥2 EGP |
| LTV (Pro) | avg duration × price | ≥400 EGP |

### Commerce
| Metric | Target |
|--------|--------|
| QR Redemptions / Month | 5,000 |
| Active Merchants | 500 |
| Avg Merchant Rating | ≥4.3 |
| Commission Revenue / Month | 80,000 EGP |

---

## 5. Funnel Analysis

### Core Acquisition Funnel
```
Install → Registration → Onboarding → First Workout → Day 7 Active → Pro
  100%       70%            55%           45%             30%          5%
```

### Pro Conversion Funnel
```
Free User → Hits Pro Gate → Views Upgrade Screen → Starts Trial → Converts
  100%         30%               20%                   15%           10%
```

**Optimization focus:** The "Hits Pro Gate → Views Upgrade Screen" drop is the first optimization target.

---

## 6. A/B Testing Framework

FitX uses Firebase A/B Testing for experiments.

### Experiment Tracker

| Experiment | Hypothesis | Metric | Status |
|------------|-----------|--------|--------|
| EXP-001: Onboarding length | 5-step vs 7-step onboarding increases completion | Onboarding completion rate | 🔲 Planned |
| EXP-002: Pro CTA position | Pro upsell on Home vs. after workout increases conversion | Pro conversion rate | 🔲 Planned |
| EXP-003: Emergency workout button label | "تمرين طارئ ⚡" vs "وقتك ضيق؟" | Emergency workout usage | 🔲 Planned |
| EXP-004: Streak recovery mechanic | One free streak forgiveness/month increases retention | D30 retention | 🔲 Planned |

### Experiment Rules
- Minimum sample: 1,000 users per variant before reading results
- Minimum duration: 2 weeks (to capture weekly patterns)
- Significance threshold: p < 0.05
- One experiment at a time on same user group