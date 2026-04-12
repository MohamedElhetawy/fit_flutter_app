# FitX — Tech Stack

**Version:** 1.1.0  
**Philosophy:** Premium user experience, high-performance Flutter frontend, and scalable Firebase backend.

---

## 1. Mobile App

| Category | Technology | Version | Rationale |
|----------|-----------|---------|-----------|
| Framework | Flutter | 3.x | High-performance UI; single codebase; excellent developer productivity |
| Language | Dart | 3.x | Strong typing; compiled to native code |
| State Management | Riverpod / BLoC | — | Robust and testable state management |
| Navigation | GoRouter | — | Declarative routing for Flutter |
| UI Components | Custom Material 3 | — | Brand consistency; premium dark mode |
| Animations | Flutter Animations | — | 60/120fps native animations |
| Local DB | Hive / Isar | — | Fast NoSQL local storage for offline features |
| Maps | google_maps_flutter | — | Google Maps SDK integration |
| Camera | camera package | — | High-performance camera integration |
| AI (On-device) | google_ml_kit | — | On-device inference for pose detection |
| HTTP Client | Dio | — | Feature-rich HTTP client with interceptors |
| Push (FCM) | firebase_messaging | — | FCM integration |
| Auth | firebase_auth | — | Phone auth + Google OAuth |
| Analytics | firebase_analytics | — | Integrated tracking |
| Crash Reporting | firebase_crashlytics | — | Automatic error reporting |
| Testing | Flutter Test / Patrol | — | Unit, Widget, and Integration tests |

---

## 2. Backend — Firebase (Serverless)

| Category | Technology | Rationale |
|----------|-----------|-----------|
| Authentication | Firebase Auth | Managed authentication; supports Phone, Google, Apple |
| Database | Cloud Firestore | Real-time NoSQL database; scales automatically |
| Storage | Cloud Storage | Secure file storage for user media |
| Functions | Cloud Functions (Node.js) | Serverless backend logic for complex operations |
| Hosting | Firebase Hosting | Fast, secure hosting for web assets |
| Security | Firebase Security Rules | Granular access control at the DB/Storage level |

---

## 3. Backend — AI Service

| Category | Technology | Rationale |
|----------|-----------|-----------|
| Runtime | Python 3.11 | ML ecosystem; NumPy/Pandas native |
| LLM | Anthropic Claude API | Fridge Rescue; meal planning; voice scripts |
| On-device AI | Google ML Kit | Specialized on-device models for pose tracking |

---

## 4. Infrastructure

| Category | Technology | Rationale |
|----------|-----------|-----------|
| Cloud Provider | Google Cloud (Firebase) | Fully managed infrastructure |
| CDN | Firebase Hosting CDN | Global distribution |
| Monitoring | Firebase Console + Sentry | Comprehensive error and performance tracking |
| CI/CD | GitHub Actions | Automated build and deploy to Firebase/Stores |

---

## 5. Technology Decision Log

| Decision | Alternatives Considered | Why Chosen |
|----------|------------------------|------------|
| Flutter vs React Native | React Native | High-performance UI requirements; smoother animations; better developer experience for this project |
| Firebase vs Custom Backend | Node.js/PostgreSQL | Speed to market; reduced operational overhead; real-time features out-of-the-box |
| Riverpod vs Bloc | Provider, GetX | Riverpod offers a modern, compile-safe approach to state management |
| Claude API vs OpenAI | GPT-4o, Gemini | Arabic language quality; safety; specifically requested by product team |

