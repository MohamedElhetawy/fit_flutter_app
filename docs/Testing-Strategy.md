# FitX — Testing Strategy

**Version:** 1.0.0

---

## 1. Testing Philosophy

**"Test the right things at the right level."**

FitX follows the testing pyramid:

```
        /\
       /E2E\          ← Few, high-value user journey tests
      /──────\
     /Integr. \       ← API contracts, DB interactions
    /────────────\
   /  Unit Tests  \   ← Business logic, algorithms, utils
  /────────────────\
```

Target Coverage:

- Unit tests: **≥80%** coverage on business logic modules
- Integration tests: **100%** of API endpoints
- E2E tests: **100%** of critical user paths (registration, workout, payment)

---

## 2. Unit Testing

### Backend (Jest + TypeScript)

**What to unit test:**

- Workout plan generator algorithm
- Macro calculation (Mifflin-St Jeor equation)
- Budget optimizer (knapsack algorithm)
- Gamification point calculation
- QR token generation and validation
- Commission calculation
- Streak logic

**Example:**

```typescript
describe('MacroCalculator', () => {
  describe('calculateDailyCalories', () => {
    it('calculates correctly for a 21yo male, 80kg, 175cm, moderately active, lose weight', () => {
      const result = calculateDailyCalories({
        weightKg: 80, heightCm: 175, age: 21,
        gender: 'male', activityLevel: 'moderate', goal: 'lose_weight'
      });
      // BMR = 10*80 + 6.25*175 - 5*21 + 5 = 1793.75
      // TDEE = 1793.75 * 1.55 = 2780.3
      // Deficit for weight loss = 2780.3 - 500 = 2280
      expect(result.calories).toBeCloseTo(2280, 0);
      expect(result.proteinG).toBeGreaterThan(150);
    });
  });
});

describe('StreakService', () => {
  it('does not break streak if user completes workout within same day', () => { ... });
  it('breaks streak after 2 consecutive missed days', () => { ... });
  it('does not break streak on planned rest days', () => { ... });
});
```

### Mobile (Jest + React Native Testing Library)

**What to unit test:**

- Custom hooks (useWorkout, useNutritionLog)
- Utility functions (formatting, validation)
- Redux/Zustand store reducers
- Navigation logic

---

## 3. Integration Testing

### API Integration Tests (Supertest + Jest)

**Coverage target:** Every endpoint, every response code

```typescript
describe('POST /auth/verify-otp', () => {
  it('returns 200 and tokens on valid OTP', async () => {
    // Setup: create OTP in Redis
    await redis.set(`otp:${testPhone}`, hashOtp('123456'), 'EX', 300);
    
    const res = await request(app)
      .post('/v1/auth/verify-otp')
      .send({ phone: testPhone, otp: '123456' });
    
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('access_token');
    expect(res.body).toHaveProperty('refresh_token');
    expect(res.body.user.onboarding_complete).toBe(false);
  });

  it('returns 401 on invalid OTP', async () => {
    const res = await request(app)
      .post('/v1/auth/verify-otp')
      .send({ phone: testPhone, otp: '000000' });
    
    expect(res.status).toBe(401);
    expect(res.body.error).toBe('INVALID_OTP');
    expect(res.body).toHaveProperty('attempts_remaining');
  });

  it('returns 429 after 5 failed attempts', async () => {
    // 5 failed attempts...
    const res = await failOtpFiveTimes(testPhone);
    expect(res.status).toBe(429);
    expect(res.body.error).toBe('ACCOUNT_LOCKED');
  });
});
```

### Database Integration Tests

- Test Prisma queries with real test database
- Verify RLS policies work correctly
- Test migration idempotency

---

## 4. End-to-End Testing (Detox)

### Critical User Paths (100% E2E coverage required)

| Path | Test File | Priority |
|------|-----------|----------|
| New user registration + onboarding | `e2e/auth/registration.e2e.ts` | P0 |
| Complete a workout session | `e2e/workout/complete-session.e2e.ts` | P0 |
| Log a meal via camera | `e2e/nutrition/food-camera.e2e.ts` | P0 |
| Get budget protein plan | `e2e/nutrition/budget-plan.e2e.ts` | P0 |
| Find merchant + redeem QR | `e2e/commerce/redeem-offer.e2e.ts` | P0 |
| Pro subscription upgrade | `e2e/subscription/upgrade.e2e.ts` | P0 |
| Workout buddy matching | `e2e/community/buddy-match.e2e.ts` | P1 |

### E2E Test Setup

```typescript
// e2e/auth/registration.e2e.ts
describe('User Registration', () => {
  beforeAll(async () => {
    await device.launchApp({ newInstance: true });
  });

  it('should complete phone registration and onboarding', async () => {
    await element(by.id('btn-get-started')).tap();
    await element(by.id('input-phone')).typeText('01012345678');
    await element(by.id('btn-send-otp')).tap();
    await expect(element(by.id('screen-otp-verify'))).toBeVisible();
    
    // Enter test OTP (intercepted in test environment)
    await element(by.id('otp-input-1')).typeText('1');
    // ... 5 more digits
    
    await expect(element(by.id('screen-onboarding-goal'))).toBeVisible();
    
    // Complete onboarding...
    await element(by.id('btn-goal-lose-weight')).tap();
    await element(by.id('btn-next')).tap();
    // ... other steps
    
    await expect(element(by.id('screen-home'))).toBeVisible();
    await expect(element(by.text('صباح الخير'))).toBeVisible();
  });
});
```

---

## 5. Performance Testing

### API Load Testing (k6)

```javascript
// k6/scenarios/workout-plan.js
export const options = {
  scenarios: {
    peak_load: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '2m', target: 100 },   // Ramp up
        { duration: '5m', target: 1000 },  // Peak load (1k concurrent)
        { duration: '2m', target: 0 },     // Ramp down
      ],
      thresholds: {
        http_req_duration: ['p(95)<300'],  // 95% under 300ms
        http_req_failed: ['rate<0.01'],    // <1% error rate
      }
    }
  }
};
```

**Load test targets:**

- Authentication: 500 req/s
- Workout endpoints: 1000 req/s
- Food recognition: 100 req/s (AI-heavy)
- Merchant map: 800 req/s

---

## 6. Mobile-Specific Testing

### Device Coverage Matrix

| Device | OS | Priority |
|--------|-----|----------|
| Samsung Galaxy A54 | Android 13 | P0 (most common in Egypt) |
| Xiaomi Redmi Note 12 | Android 13 | P0 |
| iPhone 13 | iOS 17 | P0 |
| Samsung Galaxy A32 | Android 12 | P0 |
| Infinix Hot 20 | Android 12 | P1 |
| iPhone SE (2020) | iOS 16 | P1 |
| iPhone 15 Pro | iOS 17 | P2 |

### AI Feature Testing

- Pose detection: Test with 20 volunteers, 5 exercises, varied lighting
- Food recognition: Test with 100 photos of top-20 Egyptian dishes
- Target accuracy: ≥80% top-1, ≥95% top-3

---

## 7. Smoke Tests (Post-Deploy)

Run automatically after every deployment:

```bash
npm run test:smoke

# Tests:
# ✓ Health endpoint returns 200
# ✓ Can register a test user
# ✓ Can authenticate and get JWT
# ✓ Can fetch workout plan
# ✓ Can log a food item
# ✓ Can fetch merchant list
# ✓ Payment endpoint responds (no actual charge)
```
