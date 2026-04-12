# FitX — Gamification & Social Logic
**Version:** 1.0.0  
**Status:** Implementation Ready  
**Purpose:** Retention & Community Engagement

---

## 1. Point Economy (XP)
XP is awarded for actions that improve fitness/health.

| Category | Action | XP Points | Restriction |
|----------|--------|-----------|-------------|
| **Workout** | Session > 30m | 100 | Daily |
| **Workout** | Session > 60m | 150 | Daily |
| **Workout** | New PR (Volume) | 200 | Per Exercise |
| **Nutrition** | Food Log (Logged) | 10 | Max 30/day |
| **Nutrition** | Goal Met (Macros) | 50 | Daily |
| **Social** | Gym Check-in | 50 | 12h Cooldown |
| **Social** | Match with Buddy | 25 | Per Buddy |

---

## 2. Badge System (The Achievements)

| Badge | Criteria | Feedback (Arabic) |
|-------|----------|-------------------|
| **الناشئ** | Log 1st Workout | "أهلاً بك في عيلة FitX!" |
| **عاش يا وحش** | 10 Consecutive Logins | "استمرارية الأبطال!" |
| **ملك السكوات** | 1000 Total Squat Reps | "رجلك بقت حديد!" |
| **المنضبط** | 30-Day Streak | "إنت مثال للالتزام." |
| **عمدة الجيم** | #1 Check-ins in Locally | "الجيم ده بتاعك دلوقت!" |

---

## 3. The "Gym Mayor" Algorithm (Local Ranking)
Determines the top user in a specific partner gym over a rolling 30-day period.

- **Score Calculation:**
  `MayorScore = (Checkins * 5) + (WorkoutsInGym * 10) + (PRsInGym * 20)`
- **Verification:** User must be within 50m of `Merchant.lat/lng` for `Checkin` to count.
- **Persistence:** Recalculated daily at 04:00 AM (Cairo Time).

---

## 4. Buddy Matchmaking Heuristics
Connects two users for a "Workout Buddy" experience.

1. **Location:** `Distance < 5km`.
2. **Goal:** Must match (e.g., both `LOSE_WEIGHT`).
3. **Level:** Max 1 level difference (Beginner vs Intermediate).
4. **Schedule:** Overlapping preferred workout times (Morning/Evening).

---

## 5. Streak & Retention Notifications
Powered by `BullMQ` + `FCM (Firebase Cloud Messaging)`.

| Event | Logic | Body (Arabic) |
|-------|-------|---------------|
| **20h Since Activity** | Streak at risk | "الحق الستريك بتاعك يا بطل!" |
| **New Gym Check-in** | Friend checked in | "صاحبك (فلان) بدأ تمرينه في جيم (اسم الجيم)!" |
| **Weekly Summary** | Sunday 09:00 AM | "الأسبوع اللي فات كان عظظمة. شوف إنجازاتك." |
| **Weight Milestone** | Lost 1kg+ | "كيلو مجهد مش سهل.. مبروك!" |
