# FitX — Data Model
**Version:** 1.0.0

---

## 1. Core Domain Models

### User
The central entity. Everything revolves around the user.
```typescript
interface User {
  id: string               // CUID2
  phoneHash: string        // SHA256 for lookup
  phoneEncrypted: string   // AES-256 for display
  email?: string
  googleId?: string
  displayName?: string
  avatarUrl?: string
  role: 'user' | 'admin' | 'partner' | 'trainer'
  status: 'active' | 'suspended' | 'deleted'
  profile: UserProfile
  subscription: Subscription
  createdAt: Date
}

interface UserProfile {
  userId: string
  weightKg?: number
  heightCm?: number
  age?: number
  goal: 'lose_weight' | 'build_muscle' | 'stay_active' | 'athletic'
  fitnessLevel: 'beginner' | 'intermediate' | 'advanced'
  equipment: ('none' | 'home_basics' | 'full_gym')[]
  monthlyBudgetEgp?: number
  locationDistrict?: string  // Approximate; no precise GPS stored
  onboardingComplete: boolean
}
```

### Workout
```typescript
interface Exercise {
  id: string
  nameAr: string
  muscleGroups: MuscleGroup[]
  equipment: Equipment[]
  difficulty: 'beginner' | 'intermediate' | 'advanced'
  imageUrl: string
  isPro: boolean
  instructionsAr: string[]
}

interface WorkoutPlan {
  id: string
  userId: string
  nameAr: string
  goal: string
  weeks: WorkoutWeek[]
  isActive: boolean
}

interface WorkoutSession {
  id: string
  userId: string
  planId?: string
  status: 'active' | 'completed' | 'partial'
  startedAt: Date
  endedAt?: Date
  sets: SessionSet[]
  totalVolumeKg: number
  caloriesBurned: number
}
```

### Nutrition
```typescript
interface FoodItem {
  id: string
  nameAr: string
  caloriesPer100g: number
  proteinG: number
  carbsG: number
  fatG: number
  isLocal: boolean       // Egyptian local food
  season: Season[]
}

interface FoodLog {
  id: string
  userId: string
  foodItemId?: string
  customNameAr?: string  // For unrecognized foods
  mealType: 'breakfast' | 'lunch' | 'dinner' | 'snack'
  quantityGrams: number
  loggedAt: Date
  macros: Macros          // Calculated at log time
}

interface MealPlan {
  id: string
  userId: string
  weeklyBudgetEgp: number
  totalCostEgp: number
  days: MealPlanDay[]
  shoppingList: ShoppingItem[]
}
```

### Commerce
```typescript
interface Merchant {
  id: string
  name: string
  category: 'butcher' | 'gym' | 'supplements' | 'restaurant'
  lat: number
  lng: number
  rating: number          // 0-5
  ratingCount: number
  commissionRate: number  // 0.10 = 10%
  status: 'pending' | 'active' | 'suspended'
  currentOffers: Offer[]
}

interface Offer {
  id: string
  merchantId: string
  titleAr: string
  discountType: 'percent' | 'fixed'
  discountValue: number
  validUntil: Date
  currentUses: number
  maxUses?: number
}

interface QRRedemption {
  id: string
  offerId: string
  userId: string
  merchantId: string
  tokenHash: string
  status: 'issued' | 'redeemed' | 'expired'
  expiresAt: Date
  commissionPiastres: number
}
```

---

## 2. Computed / Derived Data

### Daily Nutrition Summary (Computed on request)
```typescript
interface DailyNutritionSummary {
  date: string           // YYYY-MM-DD
  totalCalories: number
  totalProteinG: number
  totalCarbsG: number
  totalFatG: number
  waterMl: number
  targets: MacroTargets  // Calculated from profile
  completionPercent: number
  logs: FoodLog[]
}
```

### User Statistics (Computed from events)
```typescript
interface UserStats {
  totalPoints: number      // SUM of user_points
  currentStreak: number    // From streaks table
  longestStreak: number
  totalWorkouts: number    // COUNT of completed sessions
  totalVolumeKg: number    // SUM of session volumes
  gymRank?: number         // From Redis leaderboard
  globalRank?: number
  badges: Badge[]
}
```

---

## 3. Event Model (Gamification Bus)

All gamification events follow this structure:
```typescript
interface FitXEvent {
  eventId: string
  eventType: EventType
  userId: string
  sourceId: string      // ID of the triggering entity
  metadata: Record<string, unknown>
  occurredAt: Date
}

type EventType =
  | 'workout.completed'
  | 'workout.session.started'
  | 'food.logged'
  | 'checkin.created'
  | 'buddy.matched'
  | 'offer.redeemed'
  | 'streak.updated'
  | 'streak.broken'
  | 'badge.unlocked'
  | 'subscription.upgraded'
```