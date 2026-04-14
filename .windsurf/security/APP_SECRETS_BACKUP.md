# 🔐 FitX App - Secrets & Critical Assets Backup

> **⚠️ تحذير أمني:** الملف ده فيه كل أسرار التطبيق. احفظه في مكان آمن ومتشاركهوش مع حد غير موثوق.

**App Name:** FitX  
**Created:** ${DateTime.now().toString()}  
**Backup Owner:** [اسمك هنا]

---

## � Table of Contents

| Section | Description | Priority |
|---------|-------------|----------|
| [1. Firebase Config](#1-firebase-configuration) | API keys, Project IDs | ⭐⭐⭐ |
| [2. Android Keystore](#2-android-keystore-critical) | Release signing key | ⭐⭐⭐⭐⭐ |
| [3. iOS Certificates](#3-ios-certificates--provisioning) | Apple certificates | ⭐⭐⭐⭐⭐ |
| [4. Security Rules](#4-firebase-security-rules-production) | Firestore rules | ⭐⭐⭐⭐ |
| [5. API Keys](#5-api-keys--third-party-services) | External services | ⭐⭐⭐ |
| [6. Admin Accounts](#6-admin-accounts) | Console access | ⭐⭐⭐⭐ |
| [6.5 Backup Scripts](#65-database-backup-scripts-new) | Database backup | ⭐⭐⭐ |
| [7. App Config](#7-app-configuration) | Build settings | ⭐⭐ |
| [8. Brand Assets](#8-brand-assets) | Icons, screenshots | ⭐⭐ |
| [9. Deployment](#9-deployment-commands) | Build commands | ⭐⭐ |
| [10. Database Schema](#10-database-schema-reference) | Collections structure | ⭐⭐ |
| [11. Security Checklist](#11-security-checklist) | Pre-release checks | ⭐⭐⭐⭐ |
| [12. Emergency Recovery](#12-emergency-contacts--recovery) | Disaster recovery | ⭐⭐⭐⭐ |
| [13. Version History](#13-version-history) | Release log | ⭐ |
| [14. Quick Reference](#14-quick-reference) | File paths | ⭐⭐ |

---

## � 1. Firebase Configuration

### 1.1 Android - `google-services.json`

**Location:** `android/app/google-services.json`

**Current Project:**
```json
{
  "project_info": {
    "project_number": "_______________",
    "project_id": "fitx-_________",
    "storage_bucket": "fitx-_________.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:__________:android:__________",
        "android_client_info": {
          "package_name": "com.example.fitx"
        }
      },
      "api_key": [
        {
          "current_key": "____________________"
        }
      ]
    }
  ]
}
```

**Backup Status:** ☐ تم النسخ الاحتياطي ☐ محفوظ في: ________________

---

### 1.2 iOS - `GoogleService-Info.plist`

**Location:** `ios/Runner/GoogleService-Info.plist`

**Key Values:**
```xml
<key>API_KEY</key>
<string>____________________</string>
<key>GCM_SENDER_ID</key>
<string>__________</string>
<key>PROJECT_ID</key>
<string>fitx-_________</string>
<key>BUNDLE_ID</key>
<string>com.example.fitx</string>
```

**Backup Status:** ☐ تم النسخ الاحتياطي ☐ محفوظ في: ________________

---

### 1.3 Firebase Web (لو فيه Admin Panel)

**API Key:** `____________________`  
**Auth Domain:** `fitx-_________.firebaseapp.com`  
**Database URL:** `https://fitx-_________.firebaseio.com`  
**Project ID:** `fitx-_________`

---

## 🔑 2. Android Keystore (Critical!)

### 2.1 Keystore File Details

**File Name:** `fitx-release-key.jks`  
**Location:** `android/app/`

**Keystore Properties (`android/key.properties`):**
```properties
storePassword=____________________
keyPassword=____________________
keyAlias=fitx
storeFile=fitx-release-key.jks
```

### 2.2 Keystore Backup Locations

**Copy 1:** ☐ Cloud Drive: ________________  
**Copy 2:** ☐ External Hard Drive: ________________  
**Copy 3:** ☐ Password Manager: ________________

### 2.3 Keystore Fingerprint

```bash
# Run this to get fingerprint:
cd android/app
keytool -list -v -keystore fitx-release-key.jks -alias fitx
```

**SHA-1:** `____________________`  
**SHA-256:** `____________________`  
**MD5:** `____________________`

⚠️ **تحذير:** لو ضاع الـ Keystore ده، مش هتقدر ترفع updates للـ app على Play Store!

---

## 🍎 3. iOS Certificates & Provisioning

### 3.1 Apple Developer Account

**Account Email:** `____________________`  
**Team ID:** `____________________`  
**Bundle ID:** `com.example.fitx`

### 3.2 Certificates

**Distribution Certificate:**  
- Serial: `____________________`  
- Expiry: `____/____/____`  
- Location: ☐ ________________

**Provisioning Profile (App Store):**  
- UUID: `____________________`  
- Expiry: `____/____/____`

---

## 🛡️ 4. Firebase Security Rules (Production)

### 4.1 Firestore Rules

**File:** `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users - only owner can read/write
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User profiles - same as users
    match /userProfiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Link requests - involved parties only
    match /linkRequests/{requestId} {
      allow read: if request.auth != null && 
        (resource.data.trainerId == request.auth.uid || 
         resource.data.traineeId == request.auth.uid);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.trainerId == request.auth.uid || 
         resource.data.traineeId == request.auth.uid);
    }
    
    // Tasks - owner or trainer
    match /tasks/{taskId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         resource.data.trainerId == request.auth.uid);
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         resource.data.trainerId == request.auth.uid);
    }
    
    // Daily stats - owner only
    match /users/{userId}/daily_stats/{date} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Exercise history - owner only
    match /users/{userId}/exerciseHistory/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Exercise stats - owner only
    match /users/{userId}/exerciseStats/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // K-NN data - read only for authenticated users
    match /knnProfiles/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Deployed:** ☐ Yes ☐ No  
**Last Updated:** ____/____/____

---

### 4.2 Storage Rules

**File:** `storage.rules`

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile photos - owner only
    match /profilePhotos/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Progress photos - owner only
    match /progressPhotos/{userId}/{allPaths=**} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Exercise GIFs - public read
    match /exercises/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

---

## 🔐 5. API Keys & Third-Party Services

### 5.1 Google Services

**Maps API Key:** `____________________` (لو بيستخدم خرائط)  
**Places API Key:** `____________________`

### 5.2 Payment (لو فيه subscriptions)

**Stripe Publishable Key:** `pk_live_____________________`  
**Stripe Secret Key:** `sk_live_____________________` ⛔ Server only!

### 5.3 Analytics

**Google Analytics ID:** `G-____________________`  
**Firebase App ID:** `1:__________:android:__________`

### 5.4 Push Notifications (FCM)

**Server Key:** `____________________` (legacy)  
**VAPID Key:** `____________________` (web push)

---

## 👤 6. Admin Accounts

### 6.1 Firebase Console Owner

**Email:** `____________________`  
**Recovery Email:** `____________________`  
**2FA:** ☐ Enabled ☐ App: ________________

### 6.2 Apple Developer Account

**Email:** `____________________`  
**2FA:** ☐ Enabled

### 6.3 Google Play Console

**Email:** `____________________`  
**2FA:** ☐ Enabled

---

## 💾 6.5 Database Backup Scripts (NEW)

**Location:** `.windsurf/scripts/`

### ⚡ Quick Start (Windows):

```powershell
# PowerShell (Recommended)
cd .windsurf\scripts
.\backup_fixed.ps1

# Or Batch (Simplest)
cd .windsurf\scripts
.\backup.bat
```

### Manual Methods:

3. **Node.js Script** (Cross-platform)
   ```bash
   cd .windsurf/scripts
   npm install firebase-admin  # First time only
   node backup_database.js
   ```

4. **Dart Script** (Flutter SDK)
   ```bash
   cd .windsurf/scripts
   dart backup_database.dart
   ```

### Pre-requisites:
- ☐ `serviceAccountKey.json` in `.windsurf/scripts/`
- ☐ Node.js installed (https://nodejs.org)
- ☐ Run `npm install firebase-admin` (first time only)

### Service Account Key:
**Download from:** Firebase Console > Project Settings > Service Accounts > Generate New Private Key

**File:** `.windsurf/scripts/serviceAccountKey.json` ⭐⭐⭐

⚠️ **WARNING:** This key has ADMIN access to your entire Firebase project!

### Backup Output:
```
backup_2024-01-15/
├── users/              # All user data + subcollections
├── linkRequests/       # Trainer-trainee connections
├── tasks/             # Workout/nutrition tasks
├── workouts/          # Workout templates
├── exercises/         # Exercise library
├── metadata.json      # Backup info
└── REPORT.txt         # Human-readable summary
```

---

## �� 7. App Configuration

### 7.1 pubspec.yaml

```yaml
name: fitx
version: 1.0.0+1  # [version]+[build number]

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
```

### 7.2 Build Configurations

**Min Android SDK:** 21 (Android 5.0)  
**Target Android SDK:** 34 (Android 14)  
**Min iOS:** 12.0  

**Compile SDK:** 34  
**NDK Version:** `____________________`

---

## 🎨 8. Brand Assets

### 8.1 App Icons

**Android Adaptive Icon:**  
- Foreground: `assets/icon/icon_foreground.png` (432x432)  
- Background: `assets/icon/icon_background.png` (432x432)

**iOS Icon:**  
- Source: `assets/icon/ios_icon.png` (1024x1024)

**Status:** ☐ تم النسخ الاحتياطي

### 8.2 Feature Graphic (Play Store)

**Dimensions:** 1024x500  
**Location:** `assets/store/feature_graphic.png`  
**Status:** ☐ Done

### 8.3 Screenshots

**Phone (9:16):**  
- ☐ Home Screen  
- ☐ Statistics  
- ☐ Workouts  
- ☐ Trainer Dashboard

**Tablet (16:9):**  
- ☐ Same screens as above

---

## 🔧 9. Deployment Commands

### 9.1 Android Release Build

```bash
# Build app bundle (for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab

# Build APK (for testing/distribution)
flutter build apk --release --split-per-abi

# Output: build/app/outputs/apk/release/
```

### 9.2 iOS Release Build

```bash
# Build iOS
flutter build ios --release

# Then open in Xcode
open ios/Runner.xcworkspace

# Archive and upload via Xcode
```

---

## 📊 10. Database Schema Reference

### 10.1 Collections Structure

```
users/
  ├── {userId}/
  │   ├── daily_stats/{date}
  │   ├── exerciseHistory/{docId}
  │   ├── exerciseStats/{exerciseId}
  │   └── progressPhotos/{photoId}
  │
linkRequests/{requestId}
tasks/{taskId}
workouts/{workoutId}
exercises/{exerciseId}
```

### 10.2 Important Indexes

**Firestore Indexes Needed:**
```
Collection: linkRequests
  - Fields: trainerId (Ascending), createdAt (Descending)
  - Fields: traineeId (Ascending), createdAt (Descending)
  - Fields: status (Ascending), createdAt (Descending)

Collection: tasks
  - Fields: userId (Ascending), status (Ascending)
  - Fields: trainerId (Ascending), status (Ascending)
```

---

## ⚠️ 11. Security Checklist

### Before Every Release:

- [ ] `flutter analyze` - 0 errors, 0 warnings
- [ ] `flutter test` - all tests pass
- [ ] Keystore backed up in 3 locations
- [ ] Firebase rules tested on emulator
- [ ] No hardcoded API keys in code
- [ ] No `print()` statements with sensitive data
- [ ] `minifyEnabled true` in release build
- [ ] `shrinkResources true` in release build
- [ ] ProGuard rules configured
- [ ] No debug logs in production

---

## 📞 12. Emergency Contacts & Recovery

### Account Recovery

**Firebase Support:** https://support.google.com/firebase  
**Apple Developer Support:** https://developer.apple.com/support  
**Google Play Support:** https://support.google.com/googleplay/android-developer

### If Keystore is Lost:

**Android:**  
- Contact Google Play Support with package name
- May need to create new app listing (data loss!)

**iOS:**  
- Generate new certificate in Apple Developer portal
- Revoke old certificate

---

## 📝 13. Version History

| Version | Date | Changes | Build # |
|---------|------|---------|---------|
| 1.0.0 | ____/____/____ | Initial release | 1 |
| 1.0.1 | ____/____/____ | Bug fixes | 2 |
| 1.1.0 | ____/____/____ | New features | 3 |

---

## 🎯 14. Quick Reference

### Important File Paths:

```
📁 Project Root
├── 📁 android/
│   ├── 📄 app/google-services.json ⭐
│   ├── 📄 app/fitx-release-key.jks ⭐⭐⭐
│   ├── 📄 key.properties ⭐⭐⭐
│   └── 📁 app/src/main/
│       └── 📄 AndroidManifest.xml
│
├── 📁 ios/
│   ├── 📄 Runner/GoogleService-Info.plist ⭐
│   └── 📁 Runner/
│       └── 📄 Info.plist
│
├── 📁 lib/
│   └── [Source code]
│
├── 📄 pubspec.yaml ⭐
├── 📄 firebase.json (if using Firebase CLI)
└── 📁 .windsurf/security/
    └── 📄 APP_SECRETS_BACKUP.md ⭐⭐⭐ (This file!)
```

---

**Last Updated:** ____/____/____  
**Next Review:** ____/____/____  
**Backup Verified:** ☐ Yes ☐ No

---

> 🔒 **Remember:** Security is not a feature, it's a process. Review this file monthly and update after every major release.
