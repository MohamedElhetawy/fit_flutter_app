# FitX — Deployment Guide
**Version:** 1.0.0

---

## 1. Prerequisites

### Required Accounts
- [ ] GitHub (repo + Actions)
- [ ] Fly.io (compute)
- [ ] Supabase (PostgreSQL)
- [ ] Upstash (Redis)
- [ ] Cloudflare (CDN + R2)
- [ ] Firebase (FCM + Auth + Crashlytics)
- [ ] Doppler (secrets management)
- [ ] Sentry (error tracking)
- [ ] Google Play Console
- [ ] Apple Developer Account

### Required CLI Tools
```bash
npm install -g flyctl
npm install -g doppler
npm install -g prisma
npm install -g @sentry/cli
```

---

## 2. First-Time Setup

### 2.1 Clone & Install
```bash
git clone https://github.com/fitx-app/fitx.git
cd fitx

# Install all workspace dependencies
npm install
cd backend && npm install
cd ../mobile && npm install
cd ../partner-dashboard && npm install
```

### 2.2 Environment Setup
```bash
# Install Doppler CLI
curl -Ls https://cli.doppler.com/install.sh | sh

# Authenticate
doppler login

# Link project
doppler setup  # Select: fitx / development
```

### 2.3 Database Setup
```bash
cd backend

# Push schema to new database
npx prisma migrate deploy

# Seed initial data (exercises, food DB)
npx prisma db seed

# Verify
npx prisma studio  # Opens GUI at localhost:5555
```

### 2.4 Firebase Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize project
firebase init

# Deploy Firestore rules (if used)
firebase deploy --only firestore:rules
```

---

## 3. Local Development

```bash
# Start all services (backend + AI service)
npm run dev  # Root-level script using concurrently

# Or individual services:
cd backend && npm run dev     # Port 3000
cd ai-service && uvicorn main:app --reload  # Port 8000

# Mobile app
cd mobile && npm start  # Metro bundler
npx react-native run-android  # Android
npx react-native run-ios      # iOS
```

---

## 4. Staging Deployment

### Automated (CI/CD)
```
Push to develop branch → GitHub Actions → Auto-deploys to staging
```

### Manual Staging Deploy
```bash
# Backend
cd backend
fly deploy --app fitx-api-staging --image ghcr.io/fitx/api:latest

# Run migrations on staging
fly ssh console --app fitx-api-staging -C "npx prisma migrate deploy"

# Verify
curl https://staging.api.fitx.app/health
# Expected: {"status":"ok","version":"1.0.0","env":"staging"}
```

---

## 5. Production Deployment

### Pre-Deploy Checklist
- [ ] All tests passing on CI
- [ ] Staging smoke tests passed
- [ ] Migration is backwards-compatible (old code works with new schema)
- [ ] Feature flags configured correctly
- [ ] Sentry release created
- [ ] No open P0/P1 bugs
- [ ] Stakeholder sign-off for major features

### Deploy Steps
```bash
# 1. Merge PR to main (via GitHub, not CLI)

# 2. Approve deployment in GitHub Actions (environment: production)

# 3. Monitor deployment (automated in CI, but watch manually)
fly status --app fitx-api

# 4. Watch error rate in Sentry (first 10 minutes critical)

# 5. Verify production health
curl https://api.fitx.app/health

# 6. Announce in Slack #deploys
```

### Production Rollback
```bash
# List recent releases
fly releases --app fitx-api

# Rollback to specific version
fly deploy --image ghcr.io/fitx/api:PREVIOUS_SHA --app fitx-api

# Emergency: if migration caused issue
fly ssh console --app fitx-api -C "npx prisma migrate resolve --rolled-back MIGRATION_NAME"
```

---

## 6. Mobile App Deployment

### Android Release Build
```bash
cd mobile/android

# Generate release bundle
./gradlew bundleRelease

# Output: android/app/build/outputs/bundle/release/app-release.aab

# Sign with keystore
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore fitx-release-key.jks \
  app-release.aab fitx-key-alias

# Upload to Play Console
# Dashboard → Release → Production → Upload AAB
```

### iOS Release Build
```bash
# Using fastlane
cd mobile

bundle exec fastlane ios release

# fastlane/Fastfile includes:
# - increment_build_number
# - build_app (archive)
# - upload_to_testflight
```

### Release Track Strategy (Android)
```
Internal Testing → Closed Testing (Alpha, 100 testers)
→ Open Testing (Beta, public opt-in)
→ Production (staged rollout: 10% → 50% → 100%)
```

---

## 7. Health Check Endpoints

```
GET /health
Response: {
  "status": "ok",
  "version": "1.2.3",
  "env": "production",
  "timestamp": "2025-01-15T08:00:00Z",
  "services": {
    "database": "connected",
    "redis": "connected",
    "ai_service": "connected"
  }
}

GET /health/deep  (admin only)
Response: detailed latency metrics per service
```

---

## 8. Configuration Management

### Feature Flags (via Firebase Remote Config)
```
feature_ai_pose_correction: true/false
feature_workout_buddy: true/false
feature_fridge_rescue: true/false
feature_seasonal_radar: true/false
min_app_version_android: "1.0.0"
min_app_version_ios: "1.0.0"
force_update_version: null
maintenance_mode: false
maintenance_message_ar: ""
```

### Config Update (without redeploy)
```bash
# Update via Firebase Console or CLI
firebase remoteconfig:set feature_seasonal_radar true
# Takes effect for users within 60 seconds (client cache TTL)
```