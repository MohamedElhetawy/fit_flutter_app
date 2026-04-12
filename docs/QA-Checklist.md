# FitX — QA Checklist

**Version:** 1.0.0  
**Use:** Complete before every production release

---

## Pre-Release QA Checklist

### 1. Functional Testing

- [ ] All P0 test cases passing
- [ ] All P1 test cases passing
- [ ] No regression in previously-passing features
- [ ] Edge cases for new features tested
- [ ] Admin and Partner dashboards functional

### 2. Authentication & Security

- [ ] OTP flow works end-to-end (SMS delivered)
- [ ] Google OAuth login completes without error
- [ ] Token refresh works correctly
- [ ] Logout invalidates session
- [ ] Free user cannot access Pro features
- [ ] Rate limiting active on auth endpoints
- [ ] HTTPS enforced (no HTTP fallback)

### 3. Performance

- [ ] App cold start < 2 seconds on target devices
- [ ] API p95 latency < 300ms under normal load
- [ ] Food recognition returns in < 3 seconds
- [ ] Emergency workout generates in < 2 seconds
- [ ] Merchant map loads in < 2 seconds
- [ ] No dropped frames (60fps) on animations on Samsung A54

### 4. Mobile Compatibility

- [ ] Tested on Samsung Galaxy A54 (Android 13) — PRIMARY
- [ ] Tested on Xiaomi Redmi Note 12 (Android 13)
- [ ] Tested on iPhone 13 (iOS 17)
- [ ] Tested on Samsung Galaxy A32 (Android 12)
- [ ] No crashes on 2GB RAM devices
- [ ] Animations disabled automatically on low-end devices

### 5. RTL & Localization

- [ ] All screens fully RTL — no LTR leakage
- [ ] Arabic text renders correctly in all fonts
- [ ] Numbers display correctly (Arabic-Indic or Latin, per setting)
- [ ] All UI copy reviewed by Arabic-native speaker
- [ ] No truncated Arabic text (line height sufficient)

### 6. Offline Behavior

- [ ] App opens without internet (cached data)
- [ ] Workout session loggable offline
- [ ] Food log works offline
- [ ] Offline actions sync when back online
- [ ] Graceful error message shown when offline for features requiring internet

### 7. Payments

- [ ] Fawry payment completes on test account
- [ ] Paymob card payment completes on test card
- [ ] Failed payment shows clear error in Arabic
- [ ] Subscription status updates immediately after successful payment
- [ ] Receipt/confirmation push notification sent

### 8. Push Notifications

- [ ] Workout reminder delivered at correct time
- [ ] Streak-at-risk notification sent after 1 missed day
- [ ] Achievement badge notification delivered
- [ ] Notification tap navigates to correct screen in app
- [ ] Notifications respect user's opt-out settings

### 9. AI Features (Pro)

- [ ] Pose detection launches without crash
- [ ] Low-light detection works (triggers message, not crash)
- [ ] Form feedback audio plays in Egyptian Arabic
- [ ] Food recognition works on top 10 test photos (≥80% accuracy)
- [ ] Fridge Rescue returns results in < 5 seconds

### 10. Data Integrity

- [ ] Workout completion accurately logs all sets and reps
- [ ] Calorie totals mathematically correct
- [ ] Streak counter increments/resets correctly
- [ ] Points awarded are correct per event type
- [ ] QR codes are single-use (double redemption blocked)

### 11. App Store Compliance

- [ ] iOS: No use of private APIs
- [ ] iOS: Camera and location permissions have descriptive usage strings in Arabic
- [ ] iOS: In-app purchase setup via StoreKit (if applicable)
- [ ] Android: No dangerous permissions without justification
- [ ] Android: Target SDK is latest stable
- [ ] Both: Privacy policy URL valid and accessible in app

### 12. Crash & Error Monitoring

- [ ] Sentry initialized and receiving test events
- [ ] Firebase Crashlytics receiving test crash
- [ ] No unhandled promise rejections in production build
- [ ] Error boundaries in place for all major screens
- [ ] All API errors have user-facing Arabic error messages

### Sign-Off

| Role | Name | Date | Status |
|------|------|------|--------|
| QA Lead | — | — | ☐ Approved |
| Tech Lead | Mohammed | — | ☐ Approved |
| Operations | Seif | — | ☐ Approved |
