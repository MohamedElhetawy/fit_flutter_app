# FitX — Nutrition & Protein Budget Logic
**Version:** 1.0.0  
**Status:** Implementation Ready  
**Purpose:** Cost-Effective Protein Optimization

---

## 1. The "Protein-per-Pound" (PPP) Index
This index ranks local Egyptian foods by their protein density relative to current market price (EGP).

| Food Item | Protein/100g | Avg Price (EGP/kg) | Score (P-per-EGP) | Rank |
|-----------|--------------|-------------------|-------------------|------|
| **Lentils (Adas)** | 9g (cooked) | 60 | 1.5 | 1 |
| **Eggs (Beyd)** | 6g (piece) | 5 (per egg) | 1.2 | 2 |
| **Cottage Cheese (Quraish)** | 12g | 120 | 1.0 | 3 |
| **Chicken Liver (Kibda Farakh)** | 18g | 180 | 1.0 | 4 |
| **Chicken Breast (Paneh)** | 23g | 230 | 1.0 | 5 |
| **Ground Beef (Meat)** | 20g | 380 | 0.5 | 6 |

---

## 2. Budget Optimizer Algorithm

**Algorithm: `BudgetShieldOptimizer`**
- **Inputs:** `DailyBudgetEGP`, `ProteinGoalG`, `Location`.
- **Constraint:** `TotalCost <= DailyBudgetEGP`.
- **Constraint:** `TotalProtein >= 0.95 * ProteinGoalG`.
- **Inertia:** Do not repeat the exact same meal 3 days in a row.

### 2.1 Optimization Steps:
1. **Prioritize "Low-Cost Staples"** (Eggs, Lentils, Quraish) to cover 60% of protein goal for < 30% of budget.
2. **Assign "Main Source"** (Chicken/Liver/Fish) based on the remaining budget.
3. **Fill "Volume Macros"** (Rice/Potatoes/Bread) from the cheapest available source.
4. **Local Seasonality Adjustments:** If `month` is winter, swap `Watermelon` (post-workout) for `Sweet Potato`.

---

## 3. Egyptian Food Recognition Logic

### 3.1 Macro Estimation for Local Dishes
| Dish | Serving | Estimated Macros (P/C/F) | Notes |
|------|---------|-------------------------|-------|
| **Koshary** | Medium | 10g / 90g / 5g | High carb, low protein. Suggest "Add Egg". |
| **Falafel (Taamia)** | 1 piece | 1.5g / 4g / 6g | High fat (fried). Monitor quantity. |
| **Hawawshi** | 1 loaf | 25g / 45g / 30g | High protein, high fat. |
| **Foul** | 100g | 8g / 18g / 1g | Complex carb + plant protein. |

---

## 4. The "Fridge Rescue" Prompt Logic
Triggered when the user has < 5 ingredients and needs a meal.

- **System Role:** Professional Egyptian Chef & Nutritionist.
- **Constraints:** Max 15 mins prep, max 300 kcal (or target).
- **Output:** Step-by-step instructions in Arabic + Macros.
- **Example:** `{"egg": 2, "tomato": 1, "bread": 1}` -> Result: `Shakshouka (Mini Version)`.
