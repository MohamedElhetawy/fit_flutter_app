# FitX — Core Business Logic & Formulas
**Version:** 1.0.0  
**Status:** Implementation Ready  
**Purpose:** Precise mathematical formulas for the FitX engine.

---

## 1. Physical & Nutritional Formulas

### 1.1 Basal Metabolic Rate (BMR)
Using the **Mifflin-St Jeor Equation** (Most accurate for modern lifestyle):
- **Men:** `BMR = (10 × weight_kg) + (6.25 × height_cm) - (5 × age) + 5`
- **Women:** `BMR = (10 × weight_kg) + (6.25 × height_cm) - (5 × age) - 161`

### 1.2 Total Daily Energy Expenditure (TDEE)
`TDEE = BMR × ActivityMultiplier`

| Level | Description | Multiplier |
|-------|-------------|------------|
| Sedentary | Desk job, little exercise | 1.2 |
| Lightly Active | 1-3 days/week exercise | 1.375 |
| Moderately Active | 3-5 days/week exercise | 1.55 |
| Very Active | 6-7 days/week hard exercise | 1.725 |
| Athlete | 2x/day training | 1.9 |

### 1.3 Macronutrient Partitioning (FitX Standards)
Based on `FitnessGoal`:
- **LOSE_WEIGHT:** `Protein: 2.2g/kg`, `Fat: 0.6g/kg`, `Carbs: Remainder`.
- **BUILD_MUSCLE:** `Protein: 2.0g/kg`, `Fat: 0.8g/kg`, `Carbs: Remainder (Surplus 300-500 kcal)`.
- **STAY_ACTIVE:** `Protein: 1.6g/kg`, `Fat: 0.8g/kg`, `Carbs: Remainder (Maintenance)`.

---

## 2. Gamification & XP Logic

### 2.1 XP Accrual (The FitX Score)
| Action | XP Reward | Condition |
|--------|-----------|-----------|
| Complete Workout | 100 XP | Duration > 20 mins |
| Precise Set (AI) | 10 XP | Pose Score > 0.9 |
| Food Logged | 5 XP | Max 30 XP/day |
| Gym Check-in | 50 XP | Verified GPS |
| New Record (PR) | 200 XP | One-time per exercise/month |

### 2.2 Leveling System
`XP_to_Next_Level = 500 × (CurrentLevel ^ 1.5)`

### 2.3 Streak Mechanics
- **Active Window:** 24.0 hours from last activity.
- **Grace Period:** "Streak Shield" consumable (costs 500 Points).

---

## 3. Dynamic Fatigue Adjustment (RPE Based)
Adjusts the next set/workout based on user feedback or heart rate:

```typescript
function calculateVolumeAdjustment(rpe: number, sleepQuality: number): number {
    // RPE: Rate of Perceived Exertion (1-10)
    // Sleep: 1 (Bad) to 5 (Great)
    let modifier = 1.0;

    if (rpe >= 9) modifier -= 0.1; // Reduce weight by 10%
    if (rpe <= 6) modifier += 0.05; // Increase weight by 5%
    if (sleepQuality <= 2) modifier -= 0.15; // Significant reduction for safety

    return modifier;
}
```

---

## 4. Merchant & Revenue Logic

### 4.1 Commission Calculation
`Commission = SaleAmount * Merchant.commissionRate`
- Standard: 10%.
- Premium Partners: 15% (Higher ranking in search).

### 4.2 QR Token Validity
`Expiry = IssuedAt + 24 hours`
- Token must be refreshed if not used within window to prevent screenshot sharing.
