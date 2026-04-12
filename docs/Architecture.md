# FitX — System Architecture
**Version:** 1.0.0

---

## 1. Architecture Overview

FitX uses a **Mobile-First, Offline-Capable, Cloud-Enhanced** architecture. The guiding principle is: *do as much as possible on the device, use the cloud only when necessary.*

### Architecture Style
- **Frontend:** React Native (single codebase for iOS + Android)
- **Backend:** Microservices-lite: a monolith API with a separate AI inference service
- **Database:** PostgreSQL (relational) + Redis (caching + sessions)
- **AI Inference:** On-device (TensorFlow Lite) primary; cloud API secondary for complex Pro features
- **BaaS Layer:** Firebase (Auth, FCM push, Crashlytics)

---

## 2. High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                 │
│                                                                      │
│  ┌─────────────────┐   ┌─────────────────┐   ┌─────────────────┐   │
│  │  FitX Mobile    │   │  Partner Web    │   │  Admin Panel    │   │
│  │  (React Native) │   │  Dashboard      │   │  (React Web)    │   │
│  │  iOS + Android  │   │  (Next.js)      │   │  (Next.js)      │   │
│  └────────┬────────┘   └────────┬────────┘   └────────┬────────┘   │
└───────────┼─────────────────────┼─────────────────────┼────────────┘
            │                     │                     │
            └─────────────────────┼─────────────────────┘
                                  │ HTTPS / REST + WebSocket
┌─────────────────────────────────▼───────────────────────────────────┐
│                         API GATEWAY LAYER                            │
│                                                                      │
│              ┌─────────────────────────────────┐                    │
│              │   Kong / Nginx API Gateway       │                    │
│              │   - Rate limiting (100 req/min)  │                    │
│              │   - Auth validation              │                    │
│              │   - Request routing              │                    │
│              │   - SSL termination              │                    │
│              └─────────────────┬───────────────┘                    │
└────────────────────────────────┼────────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────────┐
│                      APPLICATION LAYER                               │
│                                                                      │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │   Core API       │  │   AI Service     │  │  Notification    │  │
│  │   (Node.js /     │  │   (Python /      │  │  Service         │  │
│  │   Fastify)       │  │   FastAPI)       │  │  (FCM wrapper)   │  │
│  │                  │  │                  │  │                  │  │
│  │  - Auth          │  │  - Food Recog.   │  │  - Push notifs   │  │
│  │  - Workouts      │  │  - Fridge Rescue │  │  - Voice clips   │  │
│  │  - Nutrition     │  │  - Meal Planning │  │  - Reminders     │  │
│  │  - Gamification  │  │  - Claude API    │  │                  │  │
│  │  - Commerce      │  │    integration   │  │                  │  │
│  └──────────┬───────┘  └────────┬─────────┘  └──────────────────┘  │
└─────────────┼───────────────────┼─────────────────────────────────-─┘
              │                   │
┌─────────────▼───────────────────▼───────────────────────────────────┐
│                         DATA LAYER                                   │
│                                                                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │  PostgreSQL  │  │    Redis     │  │  Cloudflare  │              │
│  │  (Primary DB)│  │  (Cache +    │  │  R2 Storage  │              │
│  │              │  │   Sessions)  │  │  (Images,    │              │
│  │              │  │              │  │   Audio,     │              │
│  │              │  │              │  │   Videos)    │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
└─────────────────────────────────────────────────────────────────────┘
              │
┌─────────────▼───────────────────────────────────────────────────────┐
│                      EXTERNAL SERVICES                               │
│                                                                      │
│  [Firebase Auth]  [FCM]  [Google Maps]  [Fawry/Paymob]             │
│  [Twilio SMS]  [Google ML Kit]  [Anthropic Claude API]              │
│  [Apple HealthKit]  [Google Fit]  [Crashlytics]                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 3. On-Device AI Architecture

```
Mobile App
├── TensorFlow Lite Runtime
│   ├── pose_detection.tflite   (20MB, custom-trained)
│   ├── food_recognition.tflite (15MB, Egyptian food model)
│   └── step_counter.tflite     (2MB, built-in sensor fusion)
│
├── Model Manager
│   ├── Hot-load models on demand (not all loaded at once)
│   ├── Update models via OTA (delta updates)
│   └── Fallback to cloud API if on-device fails
│
└── On-Device DB (SQLite via SQLCipher)
    ├── Exercise library (full cache)
    ├── Food database (full cache)
    ├── User's workout/nutrition history (7 days)
    └── Pending sync queue (offline actions)
```

---

## 4. Data Flow Patterns

### 4.1 Online Request Flow
```
App → API Gateway → Auth Middleware → Route Handler → DB → Response
```

### 4.2 Offline-First Pattern (Core Features)
```
User Action → Write to Local SQLite → Update UI immediately
                    ↓
           [Background Sync Service]
                    ↓
           When online: POST to API → Merge with server state
                    ↓
           Conflict Resolution: Server wins for shared data;
                                Client wins for personal logs
```

### 4.3 AI Pose Detection Flow
```
Camera Frame → TFLite Pose Model (on-device, 30fps)
                    ↓
           Landmark Coordinates Extracted
                    ↓
           Form Analyzer (rule-based engine, on-device)
                    ↓
           Error Detected? → Audio Feedback (pre-cached MP3)
                    ↓
           Session Summary → Sync to API when done
```

---

## 5. Security Architecture

```
[User Device]
     │ HTTPS TLS 1.3
     ▼
[API Gateway] — Rate limiting, DDoS protection, JWT validation
     │
     ▼
[Auth Middleware] — Validates JWT signature, expiry, user status
     │
     ▼
[Route Handler] — Role-based access control (RBAC)
     │
     ▼
[Database] — Row-level security; queries via ORM (parameterized)
```

**Data at Rest:**
- PostgreSQL: Transparent Data Encryption (TDE) enabled
- File Storage: Encrypted at rest (Cloudflare R2 default)
- Device: SQLCipher for on-device SQLite encryption
- Keys: Stored in iOS Keychain / Android Keystore

---

## 6. Caching Strategy

| Data | Cache Location | TTL | Invalidation |
|------|---------------|-----|--------------|
| Exercise library | On-device SQLite | Until app update | App version bump |
| Egyptian food DB | On-device SQLite | 7 days | Weekly push update |
| User profile | Redux Persist | 1 hour | Profile update event |
| Merchant offers | Redis | 15 minutes | Offer publish event |
| Leaderboard | Redis | 5 minutes | Check-in event |
| Food prices | Redis | 24 hours | Admin price update |
| JWT | Redis blacklist | Until expiry | Logout event |

---

## 7. Scalability Design

### Horizontal Scaling
- API servers: Stateless (session in Redis) → add instances behind load balancer
- AI Service: Separate scaling; GPU instances for heavy inference

### Database Scaling Path
- Phase 1 (0–500k users): Single PostgreSQL instance + read replica
- Phase 2 (500k–2M users): Connection pooling (PgBouncer) + read replicas
- Phase 3 (2M+ users): Sharding by user region (Egypt regions)

### CDN Architecture
- All static assets (images, videos, audio): Cloudflare CDN
- AI model files: Served via CDN with cache-control headers
- Audio clips (voice coach): Pre-cached on device at Pro activation