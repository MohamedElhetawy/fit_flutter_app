# Migration Runbook V1 (users / subscriptions / workouts)

## Goal
Backfill and normalize Firestore data before dashboard precomputed stats.

## What this migration does
- `users`:
  - role normalization: `trainee -> user`, `gym -> admin`
  - ensure `status`, `permissions`, `createdAt`, `lastLogin`, `authProvider`
- `workouts`:
  - ensure `createdAt`, `status`
  - backfill `gymId` from user when possible
- `subscriptions`:
  - ensure `createdAt`, `status`, `planType`
  - backfill `gymId` from user when possible

## Prerequisites
1. Service account key JSON (Firebase project `fit-x-cd2c8`)
2. Node.js installed
3. Env var:
   - Windows PowerShell:
     ```powershell
     $env:GOOGLE_APPLICATION_CREDENTIALS="D:\path\to\service-account.json"
     ```

## Run steps
```powershell
cd tools
npm install
npm run migrate:v1:dry
npm run migrate:v1:apply
```

## Validation queries (manual checks)
- Confirm no legacy role values:
  - `users` where role in [`trainee`, `gym`] should be zero
- Confirm status defaults:
  - `users/workouts/subscriptions` without `status` should be zero
- Confirm permissions map exists for all users

## Rollback strategy
- This migration is merge-only (no destructive deletes).
- If needed, restore from Firestore backup/export snapshot before run.
