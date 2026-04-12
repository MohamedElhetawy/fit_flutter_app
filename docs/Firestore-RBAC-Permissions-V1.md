# Firestore RBAC + Permissions V1

## Collections schema (minimum)

### `users/{uid}`
```json
{
  "name": "string",
  "email": "string",
  "phone": "string|null",
  "role": "super_admin|admin|trainer|user|support",
  "status": "active|suspended|deleted",
  "gymId": "string|null",
  "createdBy": "uid|string|null",
  "authProvider": "password|google|phone",
  "lastLogin": "timestamp",
  "createdAt": "timestamp",
  "permissions": {
    "users.read": true,
    "users.create": false,
    "users.update": false,
    "users.delete": false,
    "subscriptions.manage": false,
    "reports.view": true
  }
}
```

### `roles/{roleId}` (optional dynamic role metadata)
```json
{
  "name": "admin",
  "permissions": [
    "users.read",
    "users.create",
    "users.update",
    "users.delete",
    "subscriptions.manage",
    "reports.view"
  ],
  "isSystem": true
}
```

### `permissions/{permissionId}`
```json
{
  "key": "users.read",
  "description": "Read users in same tenant",
  "group": "users"
}
```

## Rules status
- Added `firestore.rules` with:
  - role-based + permission-based checks
  - multi-tenant checks by `gymId`
  - safeguards for `users`, `workouts`, `subscriptions`
  - protected metadata collections (`roles`, `permissions`)
  - role dashboards stats collections access

## Deploy commands
```bash
firebase login
firebase use fit-x-cd2c8
firebase deploy --only firestore:rules,firestore:indexes
```

## Notes
- For strongest security, move critical roles to **Firebase custom claims** in phase V2.
- Keep user `status` accurate; suspended users are blocked by rules.
