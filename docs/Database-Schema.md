# FitX — Database Schema

**Version:** 1.0.0  
**Database:** PostgreSQL 15  
**ORM:** Prisma

---

## Schema Conventions

- All IDs: `CUID2` (e.g., `usr_clxyz...`)
- All timestamps: `TIMESTAMPTZ` in UTC
- Soft deletes via `deleted_at TIMESTAMPTZ NULL`
- Monetary values: `INTEGER` (in smallest currency unit: piastres)
- Enums: defined as PostgreSQL ENUM types

---

## Tables

### users

```sql
CREATE TABLE users (
  id              VARCHAR(30) PRIMARY KEY,  -- cuid2
  phone_hash      VARCHAR(64) NOT NULL UNIQUE,  -- SHA256 of phone
  phone_encrypted VARCHAR(256) NOT NULL,        -- AES-256 encrypted
  email           VARCHAR(255) UNIQUE,
  google_id       VARCHAR(100) UNIQUE,
  display_name    VARCHAR(100),
  avatar_url      TEXT,
  role            VARCHAR(20) NOT NULL DEFAULT 'user',  -- user|admin|partner|trainer
  status          VARCHAR(20) NOT NULL DEFAULT 'active', -- active|suspended|deleted
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX idx_users_phone_hash ON users(phone_hash);
CREATE INDEX idx_users_google_id ON users(google_id);
```

### user_profiles

```sql
CREATE TABLE user_profiles (
  user_id         VARCHAR(30) PRIMARY KEY REFERENCES users(id),
  weight_kg       DECIMAL(5,2),
  height_cm       DECIMAL(5,2),
  age             INTEGER,
  goal            VARCHAR(30),  -- lose_weight|build_muscle|stay_active|athletic
  fitness_level   VARCHAR(20),  -- beginner|intermediate|advanced
  equipment       TEXT[],       -- none|home_basics|full_gym
  monthly_budget_egp INTEGER,
  location_lat    DECIMAL(10,7),
  location_lng    DECIMAL(10,7),
  location_district VARCHAR(100),  -- Cairo district, no precise location stored
  notifications_enabled BOOLEAN DEFAULT TRUE,
  language        VARCHAR(10) DEFAULT 'ar-EG',
  onboarding_complete BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### weight_logs

```sql
CREATE TABLE weight_logs (
  id          VARCHAR(30) PRIMARY KEY,
  user_id     VARCHAR(30) NOT NULL REFERENCES users(id),
  weight_kg   DECIMAL(5,2) NOT NULL,
  logged_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_weight_logs_user ON weight_logs(user_id, logged_at DESC);
```

### subscriptions

```sql
CREATE TABLE subscriptions (
  id              VARCHAR(30) PRIMARY KEY,
  user_id         VARCHAR(30) NOT NULL REFERENCES users(id),
  tier            VARCHAR(20) NOT NULL DEFAULT 'free',  -- free|pro
  status          VARCHAR(20) NOT NULL,  -- active|expired|cancelled|trial
  started_at      TIMESTAMPTZ NOT NULL,
  expires_at      TIMESTAMPTZ,
  payment_ref     VARCHAR(100),  -- External payment gateway reference
  amount_piastres INTEGER,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id, status);
```

### refresh_tokens

```sql
CREATE TABLE refresh_tokens (
  id          VARCHAR(30) PRIMARY KEY,
  user_id     VARCHAR(30) NOT NULL REFERENCES users(id),
  token_hash  VARCHAR(64) NOT NULL UNIQUE,
  device_id   VARCHAR(100),
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  used_at     TIMESTAMPTZ  -- Single-use rotation
);
```

### exercises

```sql
CREATE TABLE exercises (
  id              VARCHAR(30) PRIMARY KEY,
  name_ar         VARCHAR(200) NOT NULL,
  name_en         VARCHAR(200),
  description_ar  TEXT,
  muscle_groups   TEXT[] NOT NULL,    -- chest|back|legs|shoulders|biceps|triceps|core|cardio
  equipment       TEXT[] NOT NULL,    -- none|barbell|dumbbell|machine|cables|bodyweight
  difficulty      VARCHAR(20) NOT NULL,  -- beginner|intermediate|advanced
  image_url       TEXT,
  video_url       TEXT,
  is_pro          BOOLEAN DEFAULT FALSE,
  is_safe_for_beginners BOOLEAN DEFAULT TRUE,
  instructions_ar TEXT[],  -- Step-by-step in Arabic
  tips_ar         TEXT[],
  created_by      VARCHAR(30) REFERENCES users(id),
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ
);
```

### workout_plans

```sql
CREATE TABLE workout_plans (
  id          VARCHAR(30) PRIMARY KEY,
  user_id     VARCHAR(30) NOT NULL REFERENCES users(id),
  name_ar     VARCHAR(200) NOT NULL,
  goal        VARCHAR(30) NOT NULL,
  weeks       INTEGER NOT NULL DEFAULT 4,
  plan_data   JSONB NOT NULL,  -- Full plan structure
  is_active   BOOLEAN DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_workout_plans_user ON workout_plans(user_id, is_active);
```

### workout_sessions

```sql
CREATE TABLE workout_sessions (
  id              VARCHAR(30) PRIMARY KEY,
  user_id         VARCHAR(30) NOT NULL REFERENCES users(id),
  plan_id         VARCHAR(30) REFERENCES workout_plans(id),
  workout_name_ar VARCHAR(200),
  status          VARCHAR(20) DEFAULT 'active',  -- active|completed|partial
  started_at      TIMESTAMPTZ NOT NULL,
  ended_at        TIMESTAMPTZ,
  duration_seconds INTEGER,
  total_volume_kg  DECIMAL(10,2),
  calories_burned  INTEGER,
  notes           TEXT
);
CREATE INDEX idx_workout_sessions_user ON workout_sessions(user_id, started_at DESC);
```

### session_sets

```sql
CREATE TABLE session_sets (
  id              VARCHAR(30) PRIMARY KEY,
  session_id      VARCHAR(30) NOT NULL REFERENCES workout_sessions(id),
  exercise_id     VARCHAR(30) NOT NULL REFERENCES exercises(id),
  set_number      INTEGER NOT NULL,
  reps_target     INTEGER,
  reps_done       INTEGER,
  weight_kg       DECIMAL(6,2),
  rest_seconds    INTEGER,
  completed_at    TIMESTAMPTZ,
  pose_score      DECIMAL(3,2)  -- AI form score 0-1 (Pro only)
);
```

### food_items

```sql
CREATE TABLE food_items (
  id                VARCHAR(30) PRIMARY KEY,
  name_ar           VARCHAR(200) NOT NULL,
  name_en           VARCHAR(200),
  category          VARCHAR(50),   -- grain|protein|vegetable|fruit|dairy|fat|beverage
  calories_per_100g DECIMAL(6,2) NOT NULL,
  protein_g         DECIMAL(6,2),
  carbs_g           DECIMAL(6,2),
  fat_g             DECIMAL(6,2),
  fiber_g           DECIMAL(6,2),
  is_local          BOOLEAN DEFAULT TRUE,  -- Is an Egyptian local food
  season            TEXT[],  -- winter|summer|all_year
  image_url         TEXT,
  barcode           VARCHAR(50),
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_food_items_name ON food_items USING gin(to_tsvector('arabic', name_ar));
```

### food_logs

```sql
CREATE TABLE food_logs (
  id              VARCHAR(30) PRIMARY KEY,
  user_id         VARCHAR(30) NOT NULL REFERENCES users(id),
  food_item_id    VARCHAR(30) REFERENCES food_items(id),
  custom_name_ar  VARCHAR(200),  -- If food not in DB
  meal_type       VARCHAR(20) NOT NULL,  -- breakfast|lunch|dinner|snack
  quantity_grams  DECIMAL(7,2) NOT NULL,
  calories        DECIMAL(7,2),
  protein_g       DECIMAL(6,2),
  carbs_g         DECIMAL(6,2),
  fat_g           DECIMAL(6,2),
  logged_at       TIMESTAMPTZ NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_food_logs_user_date ON food_logs(user_id, logged_at DESC);
```

### market_prices

```sql
CREATE TABLE market_prices (
  id              VARCHAR(30) PRIMARY KEY,
  food_item_id    VARCHAR(30) NOT NULL REFERENCES food_items(id),
  region          VARCHAR(100),  -- Cairo|Giza|Alexandria|...
  price_egp_per_kg DECIMAL(8,2) NOT NULL,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  source          VARCHAR(50)  -- manual|scraper
);
```

### merchants

```sql
CREATE TABLE merchants (
  id              VARCHAR(30) PRIMARY KEY,
  owner_user_id   VARCHAR(30) REFERENCES users(id),
  name            VARCHAR(200) NOT NULL,
  name_en         VARCHAR(200),
  category        VARCHAR(50) NOT NULL,  -- butcher|gym|supplements|restaurant
  description_ar  TEXT,
  address_ar      VARCHAR(500),
  district        VARCHAR(100),
  lat             DECIMAL(10,7),
  lng             DECIMAL(10,7),
  phone           VARCHAR(20),
  whatsapp        VARCHAR(20),
  rating          DECIMAL(3,2) DEFAULT 0,
  rating_count    INTEGER DEFAULT 0,
  commission_rate DECIMAL(4,3) DEFAULT 0.10,  -- 10%
  status          VARCHAR(20) DEFAULT 'pending',  -- pending|active|suspended
  coverage_radius_m INTEGER DEFAULT 5000,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_merchants_location ON merchants USING GIST(
  ll_to_earth(lat, lng)
);
```

### offers

```sql
CREATE TABLE offers (
  id              VARCHAR(30) PRIMARY KEY,
  merchant_id     VARCHAR(30) NOT NULL REFERENCES merchants(id),
  title_ar        VARCHAR(300) NOT NULL,
  description_ar  TEXT,
  discount_type   VARCHAR(20) DEFAULT 'percent',  -- percent|fixed
  discount_value  DECIMAL(6,2) NOT NULL,  -- % or EGP amount
  product_category VARCHAR(50),
  max_uses        INTEGER,
  current_uses    INTEGER DEFAULT 0,
  valid_from      TIMESTAMPTZ NOT NULL,
  valid_until     TIMESTAMPTZ NOT NULL,
  status          VARCHAR(20) DEFAULT 'pending',  -- pending|active|expired|suspended
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### qr_redemptions

```sql
CREATE TABLE qr_redemptions (
  id              VARCHAR(30) PRIMARY KEY,
  offer_id        VARCHAR(30) NOT NULL REFERENCES offers(id),
  user_id         VARCHAR(30) NOT NULL REFERENCES users(id),
  merchant_id     VARCHAR(30) NOT NULL REFERENCES merchants(id),
  token_hash      VARCHAR(64) NOT NULL UNIQUE,
  status          VARCHAR(20) DEFAULT 'issued',  -- issued|redeemed|expired
  issued_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at      TIMESTAMPTZ NOT NULL,
  redeemed_at     TIMESTAMPTZ,
  transaction_amount_piastres INTEGER,
  commission_piastres INTEGER
);
```

### user_points

```sql
CREATE TABLE user_points (
  id          VARCHAR(30) PRIMARY KEY,
  user_id     VARCHAR(30) NOT NULL REFERENCES users(id),
  points      INTEGER NOT NULL,
  event_type  VARCHAR(50) NOT NULL,  -- workout_complete|food_log|checkin|badge|referral
  source_id   VARCHAR(30),  -- ID of the triggering record
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_user_points_user ON user_points(user_id, created_at DESC);
```

### user_badges

```sql
CREATE TABLE user_badges (
  user_id     VARCHAR(30) NOT NULL REFERENCES users(id),
  badge_id    VARCHAR(50) NOT NULL,  -- first_workout|streak_7|streak_30|gym_mayor|...
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, badge_id)
);
```

### streaks

```sql
CREATE TABLE streaks (
  user_id         VARCHAR(30) PRIMARY KEY REFERENCES users(id),
  current_streak  INTEGER DEFAULT 0,
  longest_streak  INTEGER DEFAULT 0,
  last_activity   TIMESTAMPTZ,
  streak_at_risk  BOOLEAN DEFAULT FALSE
);
```

### checkins

```sql
CREATE TABLE checkins (
  id          VARCHAR(30) PRIMARY KEY,
  user_id     VARCHAR(30) NOT NULL REFERENCES users(id),
  gym_id      VARCHAR(30) REFERENCES merchants(id),
  lat         DECIMAL(10,7),
  lng         DECIMAL(10,7),
  verified    BOOLEAN DEFAULT FALSE,
  checked_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_checkins_gym_month ON checkins(gym_id, checked_in_at);
```

### buddy_matches

```sql
CREATE TABLE buddy_matches (
  id              VARCHAR(30) PRIMARY KEY,
  user_id_1       VARCHAR(30) NOT NULL REFERENCES users(id),
  user_id_2       VARCHAR(30) NOT NULL REFERENCES users(id),
  status          VARCHAR(20) DEFAULT 'pending',  -- pending|active|unmatched
  matched_at      TIMESTAMPTZ,
  unmatched_at    TIMESTAMPTZ,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### buddy_messages

```sql
CREATE TABLE buddy_messages (
  id          VARCHAR(30) PRIMARY KEY,
  match_id    VARCHAR(30) NOT NULL REFERENCES buddy_matches(id),
  sender_id   VARCHAR(30) NOT NULL REFERENCES users(id),
  content     TEXT NOT NULL,
  sent_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  read_at     TIMESTAMPTZ
);
CREATE INDEX idx_buddy_messages_match ON buddy_messages(match_id, sent_at DESC);
```
