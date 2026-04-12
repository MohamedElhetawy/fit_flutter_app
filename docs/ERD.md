# FitX — Entity Relationship Diagram (ERD)

**Version:** 1.0.0  
**Notation:** Crow's Foot (text representation)

---

## Primary Entity Relationships

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         FitX ERD Overview                                    │
└─────────────────────────────────────────────────────────────────────────────┘

USERS ─────────────────────────────────────────────────────────────────────────

users ||──|| user_profiles          (One user has exactly one profile)
users ||──o{ subscriptions          (One user has zero or many subscriptions)
users ||──o{ refresh_tokens         (One user has zero or many tokens)
users ||──o{ weight_logs            (One user has zero or many weight logs)
users ||──o{ workout_plans          (One user has zero or many workout plans)
users ||──o{ workout_sessions       (One user has zero or many sessions)
users ||──o{ food_logs              (One user has zero or many food logs)
users ||──o{ user_points            (One user has zero or many point events)
users ||──|| streaks                (One user has exactly one streak record)
users ||──o{ user_badges            (One user has zero or many badges)
users ||──o{ checkins               (One user has zero or many check-ins)

WORKOUTS ──────────────────────────────────────────────────────────────────────

workout_plans ||──o{ workout_sessions    (Plan has zero or many sessions)
workout_sessions ||──o{ session_sets     (Session has zero or many sets)
exercises ||──o{ session_sets           (Exercise can appear in many sets)

NUTRITION ─────────────────────────────────────────────────────────────────────

food_items ||──o{ food_logs            (Food item logged many times)
food_items ||──o{ market_prices        (Food item has many regional prices)

COMMERCE ──────────────────────────────────────────────────────────────────────

merchants ||──o{ offers                 (Merchant has zero or many offers)
offers ||──o{ qr_redemptions           (Offer redeemed zero or many times)
users ||──o{ qr_redemptions            (User redeems zero or many times)
merchants ||──o{ checkins              (Merchant (gym) has many check-ins)

SOCIAL ────────────────────────────────────────────────────────────────────────

users }o──o{ buddy_matches             (User can have many buddy matches)
buddy_matches ||──o{ buddy_messages    (Match has many messages)
```

---

## Detailed Entity Attributes

```
┌──────────────────────┐
│        USERS         │
├──────────────────────┤
│ PK  id               │
│     phone_hash       │
│     phone_encrypted  │
│     email (UK)       │
│     google_id (UK)   │
│     display_name     │
│     role             │
│     status           │
│     created_at       │
└──────────┬───────────┘
           │ 1
           │
           │ 1
┌──────────▼───────────┐
│    USER_PROFILES     │
├──────────────────────┤
│ PK  user_id (FK)     │
│     weight_kg        │
│     height_cm        │
│     age              │
│     goal             │
│     fitness_level    │
│     equipment[]      │
│     budget_egp       │
│     onboarding_done  │
└──────────────────────┘

┌──────────────────────┐
│     EXERCISES        │
├──────────────────────┤
│ PK  id               │
│     name_ar          │
│     muscle_groups[]  │
│     equipment[]      │
│     difficulty       │
│     is_pro           │
│     image_url        │
│     video_url        │
└──────────┬───────────┘
           │ 1
           │
           │ M
┌──────────▼───────────┐
│    SESSION_SETS      │
├──────────────────────┤
│ PK  id               │
│ FK  session_id       │
│ FK  exercise_id      │
│     set_number       │
│     reps_done        │
│     weight_kg        │
│     pose_score       │
└──────────┬───────────┘
           │ M
           │
           │ 1
┌──────────▼───────────┐
│  WORKOUT_SESSIONS    │
├──────────────────────┤
│ PK  id               │
│ FK  user_id          │
│ FK  plan_id          │
│     status           │
│     started_at       │
│     ended_at         │
│     total_volume_kg  │
│     calories_burned  │
└──────────────────────┘

┌──────────────────────┐
│     MERCHANTS        │
├──────────────────────┤
│ PK  id               │
│ FK  owner_user_id    │
│     name             │
│     category         │
│     lat / lng        │
│     rating           │
│     commission_rate  │
│     status           │
└──────────┬───────────┘
           │ 1
           │
           │ M
┌──────────▼───────────┐
│       OFFERS         │
├──────────────────────┤
│ PK  id               │
│ FK  merchant_id      │
│     title_ar         │
│     discount_type    │
│     discount_value   │
│     valid_until      │
│     max_uses         │
│     current_uses     │
│     status           │
└──────────┬───────────┘
           │ 1
           │
           │ M
┌──────────▼───────────┐
│   QR_REDEMPTIONS     │
├──────────────────────┤
│ PK  id               │
│ FK  offer_id         │
│ FK  user_id          │
│ FK  merchant_id      │
│     token_hash (UK)  │
│     status           │
│     expires_at       │
│     commission_pias  │
└──────────────────────┘
```

---

## Junction Tables

| Table | Entities | Nature |
|-------|----------|--------|
| `user_badges` | users ↔ badges | M:M (user can have many badge types) |
| `session_sets` | sessions ↔ exercises | M:M with attributes (sets, reps, weight) |
| `buddy_matches` | users ↔ users | M:M self-join |
| `market_prices` | food_items ↔ regions | M:M with price attribute |

---

## Indexes Summary

| Table | Index | Type | Purpose |
|-------|-------|------|---------|
| users | phone_hash | B-tree | Fast OTP verification lookup |
| users | google_id | B-tree | OAuth lookup |
| workout_sessions | user_id + started_at | B-tree | History queries |
| food_logs | user_id + logged_at | B-tree | Daily log queries |
| food_items | name_ar | GIN (full-text) | Arabic food search |
| merchants | lat/lng | GiST (earth distance) | Geo proximity search |
| checkins | gym_id + checked_in_at | B-tree | Monthly leaderboard calc |
| user_points | user_id + created_at | B-tree | Points history |
