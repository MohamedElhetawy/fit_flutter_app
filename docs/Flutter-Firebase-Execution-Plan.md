# FitX Flutter + Firebase Master Plan (Nerva X)

## 1) Stack Alignment (No Conflict)
- **Frontend:** Flutter + Riverpod + GoRouter
- **Backend:** Firebase Auth + Firestore (+ Cloud Functions later)
- **Do not use** React Native / Node API assumptions from legacy docs in implementation.

## 2) Users & RBAC (Execution)
- Collections:
  - `users/{uid}`: identity, role, status, gymId, createdBy, authProvider, lastLogin
  - `roles/{roleId}`: optional role metadata
  - `permissions/{permissionId}`: optional master list
- Current app state:
  - Role enum implemented
  - Granular permissions map implemented in Flutter layer
  - UI guard implemented for dashboard sections
- Next:
  - Store role-permission mapping in Firestore for dynamic control
  - Add staff/support role and super_admin role migration

## 3) Security Layers
- **Frontend guard:** done (permission-based section visibility)
- **Backend guard (Firestore Rules):** required next
- **Logic validation:** enforce permission checks in app service methods

## 4) Dashboard System
- Implemented:
  - Role-aware dashboard tabs
  - Firestore streams for `users`, `subscriptions`
  - Aggregated admin stats with local cache key `dashboard_admin_stats_cache`
- Next:
  - Precomputed stats collections via Cloud Functions:
    - `dashboard_admin_stats/current`
    - `dashboard_trainer_stats/{uid}`
    - `dashboard_user_stats/{uid}`

## 5) Local Storage & Offline
- Implemented:
  - SharedPreferences cache for dashboard aggregate stats
- Next:
  - Add encrypted local DB (Hive/Isar/sqlite) for:
    - user profile (persistent)
    - dashboard snapshot (cache)
    - workout/subscription list snapshots
  - Sync cycle:
    - app start -> load local
    - sync from Firestore
    - update local
    - update UI

## 6) Backup (Google Drive)
- Planned architecture:
  - Export local data to JSON:
    - `users.json`, `subscriptions.json`, `workouts.json`, `metadata.json`
  - Upload with OAuth Google Drive API
  - Restore pipeline:
    - download -> validate version -> replace local -> resync cloud
- Security:
  - Encrypt payload before upload (AES key stored locally secure storage)

## 7) Firestore Rules (Required Draft)
- Enforce:
  - user reads/writes own profile only
  - trainer sees assigned users only
  - admin/gym limited by tenant `gymId`
  - super_admin full access
- Add custom claims for critical roles (`super_admin`, `admin`) to avoid trusting client role only.

## 8) Delivery Phases
- **Phase A (current -> next 3 days):**
  - complete RBAC dynamic permissions
  - finalize role dashboards
  - Firestore rules V1
- **Phase B (week 2):**
  - offline local DB + sync queue
  - precomputed dashboard stats
- **Phase C (week 3):**
  - backup/restore with Drive
  - encrypted export/import

## 9) What I need from you to edit Firebase directly
- Option 1 (recommended): temporary project editor access in Firebase Console
- Option 2: Service Account JSON with restricted scope (Firestore Rules + Functions deploy)
- Option 3: you run commands I provide, and send output back

Minimum required to execute backend tasks:
- Firebase project id (confirmed): `fit-x-cd2c8`
- Enabled products: Auth, Firestore, Functions, Storage
- Permission to deploy rules/functions.

## Zero Budget Mode (No Blaze)
- If Blaze is not enabled:
  - do **not** deploy Cloud Functions
  - compute dashboard stats client-side via Firestore count queries
  - cache stats locally (SharedPreferences) and refresh in background
  - keep precomputed stats as optional upgrade path when Blaze is enabled
