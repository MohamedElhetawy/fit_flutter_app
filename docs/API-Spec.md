# FitX — API Specification

**Version:** v1  
**Base URL:** `https://api.fitx.app/v1`  
**Format:** OpenAPI 3.0 (abbreviated for readability)  
**Auth:** Bearer JWT in Authorization header

---

## Authentication

### POST /auth/register

Register with phone number (step 1: request OTP)

```json
Request:
{
  "phone": "+201012345678"
}

Response 200:
{
  "message": "OTP sent",
  "expires_in": 300,
  "phone": "+201012345678"
}

Error 400:
{
  "error": "INVALID_PHONE",
  "message": "رقم الموبايل مش صح"
}
```

### POST /auth/verify-otp

```json
Request:
{
  "phone": "+201012345678",
  "otp": "123456"
}

Response 200:
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "user": {
    "id": "usr_abc123",
    "phone": "+201012345678",
    "onboarding_complete": false
  }
}

Error 401:
{
  "error": "INVALID_OTP",
  "message": "الكود غلط",
  "attempts_remaining": 3
}
```

### POST /auth/refresh

```json
Request:
{ "refresh_token": "eyJ..." }

Response 200:
{ "access_token": "eyJ...", "expires_in": 86400 }
```

### POST /auth/logout

```json
Headers: Authorization: Bearer {token}
Response 200: { "message": "Logged out" }
```

---

## User Profile

### GET /users/me

```json
Response 200:
{
  "id": "usr_abc123",
  "name": "Ahmed",
  "phone": "+201012345678",
  "profile": {
    "weight_kg": 80,
    "height_cm": 175,
    "age": 21,
    "goal": "lose_weight",
    "fitness_level": "beginner",
    "monthly_budget_egp": 300,
    "equipment": "none"
  },
  "subscription": {
    "tier": "free",
    "expires_at": null
  },
  "stats": {
    "streak_days": 12,
    "total_workouts": 28,
    "points": 1840
  }
}
```

### PATCH /users/me

```json
Request:
{
  "name": "Ahmed",
  "profile": {
    "weight_kg": 79
  }
}

Response 200: { "updated": true, "user": {...} }
```

---

## Workouts

### GET /workouts/plan

Returns the user's current active workout plan.

```json
Response 200:
{
  "plan_id": "plan_xyz",
  "name": "خطة المبتدئ — شهر ١",
  "weeks": [
    {
      "week": 1,
      "days": [
        {
          "day": 1,
          "name": "الصدر والترايسبس",
          "exercises": [
            {
              "id": "ex_001",
              "name_ar": "بريس الصدر بالعقلة",
              "sets": 3,
              "reps": 12,
              "rest_seconds": 90,
              "equipment": ["barbell"],
              "muscle_groups": ["chest", "triceps"],
              "image_url": "https://cdn.fitx.app/exercises/bench-press.jpg",
              "is_pro": false
            }
          ]
        }
      ]
    }
  ]
}
```

### POST /workouts/emergency

Generate an emergency workout.

```json
Request:
{
  "duration_minutes": 15,
  "location": "home",
  "equipment": []
}

Response 200:
{
  "workout": {
    "name": "تمرين ١٥ دقيقة في البيت",
    "total_duration": 15,
    "exercises": [...]
  }
}
```

### POST /workouts/sessions

Start or log a workout session.

```json
Request:
{
  "plan_id": "plan_xyz",
  "day_index": 0,
  "started_at": "2025-01-15T08:30:00Z"
}

Response 201:
{
  "session_id": "sess_123",
  "status": "active"
}
```

### PATCH /workouts/sessions/{session_id}

Update session (log sets, complete session).

```json
Request:
{
  "sets_completed": [
    {
      "exercise_id": "ex_001",
      "set_number": 1,
      "reps_done": 12,
      "weight_kg": 70,
      "completed_at": "2025-01-15T08:35:00Z"
    }
  ],
  "status": "completed",
  "ended_at": "2025-01-15T09:15:00Z"
}

Response 200:
{
  "session": { "id": "sess_123", "status": "completed" },
  "rewards": {
    "points_earned": 50,
    "streak_updated": true,
    "new_streak": 13,
    "badges_unlocked": []
  }
}
```

### GET /exercises

Browse exercise library.

```
Query params: muscle_group, equipment, difficulty, is_pro, search, page, limit
```

---

## Nutrition

### POST /nutrition/logs

Log a meal.

```json
Request:
{
  "meal_type": "breakfast",
  "food_item_id": "food_001",
  "quantity_grams": 200,
  "logged_at": "2025-01-15T08:00:00Z"
}

Response 201:
{
  "log_id": "log_abc",
  "nutrition": {
    "calories": 320,
    "protein_g": 28,
    "carbs_g": 18,
    "fat_g": 14
  },
  "daily_totals": {
    "calories": 720,
    "protein_g": 55,
    "carbs_g": 80,
    "fat_g": 22,
    "targets": { "calories": 2100, "protein_g": 160, ... }
  }
}
```

### POST /nutrition/recognize

Recognize food from image.

```json
Request: multipart/form-data
  image: [binary]
  
Response 200:
{
  "predictions": [
    { "food_id": "food_042", "name_ar": "كشري", "confidence": 0.92, "calories_per_100g": 160 },
    { "food_id": "food_043", "name_ar": "أرز مع عدس", "confidence": 0.05, ... },
    { "food_id": "food_044", "name_ar": "أرز أصفر", "confidence": 0.03, ... }
  ],
  "processing_time_ms": 1240
}
```

### POST /nutrition/budget-plan

Generate budget meal plan.

```json
Request:
{
  "weekly_budget_egp": 300,
  "protein_target_g": 160,
  "restrictions": ["no_pork"],
  "location_lat": 30.0444,
  "location_lng": 31.2357
}

Response 200:
{
  "plan_id": "mplan_001",
  "total_cost_egp": 287,
  "daily_protein_avg_g": 158,
  "days": [...],
  "shopping_list": [
    { "item": "بيض (كرتونة 30)", "quantity": "1 كرتونة", "est_cost_egp": 65, "nearest_merchant_id": "m_001" }
  ]
}
```

### POST /nutrition/fridge-rescue

Get recipes from available ingredients.

```json
Request:
{
  "ingredients": ["بيض", "طماطم", "جبن قريش", "شوفان"]
}

Response 200:
{
  "recipes": [
    {
      "name": "أوملت بالطماطم والجبن",
      "calories": 380,
      "protein_g": 28,
      "prep_minutes": 10,
      "steps": ["افرق البيض في طاسة...", "..."]
    }
  ]
}
```

---

## Commerce (Merchants)

### GET /merchants

```
Query: lat, lng, radius_km (default 5), category, min_rating, page
```

```json
Response 200:
{
  "merchants": [
    {
      "id": "m_001",
      "name": "جزارة أبو حسن",
      "category": "butcher",
      "rating": 4.8,
      "rating_count": 156,
      "distance_m": 450,
      "lat": 30.0512,
      "lng": 31.2401,
      "current_offers": [
        {
          "id": "offer_001",
          "title": "خصم 15% على اللحمة المفرومة",
          "discount_percent": 15,
          "valid_until": "2025-01-20T23:59:59Z"
        }
      ]
    }
  ],
  "total": 12
}
```

### POST /merchants/{merchant_id}/offers/{offer_id}/redeem

```json
Response 201:
{
  "qr_token": "eyJ...",
  "qr_image_url": "https://cdn.fitx.app/qr/qr_abc.png",
  "expires_at": "2025-01-16T09:00:00Z",
  "offer": { "title": "خصم 15%", "merchant_name": "جزارة أبو حسن" }
}
```

---

## Gamification

### GET /users/me/stats

```json
Response 200:
{
  "points": 1840,
  "streak_days": 13,
  "rank_global": 1234,
  "rank_gym": 3,
  "badges": [
    { "id": "badge_first_workout", "name": "أول تمرين", "unlocked_at": "2025-01-01T..." }
  ],
  "achievements_progress": [
    { "badge_id": "badge_30_streak", "name": "سلسلة ٣٠ يوم", "progress": 13, "target": 30 }
  ]
}
```

### GET /leaderboard/gym/{gym_id}

```json
Response 200:
{
  "month": "2025-01",
  "entries": [
    { "rank": 1, "user_name": "Ahmed M.", "checkins": 22, "is_you": false },
    { "rank": 2, "user_name": "Sara H.", "checkins": 18, "is_you": false },
    { "rank": 3, "user_name": "You", "checkins": 15, "is_you": true }
  ]
}
```

---

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| INVALID_PHONE | 400 | Phone number format invalid |
| INVALID_OTP | 401 | OTP incorrect |
| OTP_EXPIRED | 401 | OTP has expired |
| ACCOUNT_LOCKED | 429 | Too many failed OTP attempts |
| UNAUTHORIZED | 401 | Invalid or expired JWT |
| FORBIDDEN | 403 | Insufficient role/tier for this action |
| PRO_REQUIRED | 403 | Feature requires Pro subscription |
| NOT_FOUND | 404 | Resource not found |
| RATE_LIMITED | 429 | Too many requests |
| SERVER_ERROR | 500 | Internal server error |
