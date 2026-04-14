# 🔥 FitX Firebase Firestore Schema

## 📋 المخطط المطلوب

### Collection: `users`

```javascript
users/{userId} {
  // Basic Info
  uid: string,
  email: string,
  name: string,
  role: "trainee" | "trainer" | "gym" | "admin" | "superAdmin",
  
  // For ALL users
  createdAt: timestamp,
  lastLoginAt: timestamp,
  
  // For TRAINER & GYM ( generated automatically )
  accessCode: "123456",        // 6-digit random
  qrData: "fitx:trainer:123456", // for QR scanning
  codeGeneratedAt: timestamp,
  
  // For TRAINEE ( linked to gym/trainer )
  gymId: string,               // reference to gyms/{gymId}
  gymName: string,
  trainerId: string,           // reference to users/{trainerId}
  trainerName: string,
  linkedAt: timestamp,
  linkedToTrainerAt: timestamp,
  
  // Stats
  profileComplete: boolean,
  avatarUrl: string,
}
```

### Collection: `gyms`

```javascript
gyms/{gymId} {
  // Basic Info
  name: "Gold's Gym",
  location: "المهندسين، الجيزة",
  description: string,
  
  // Access Control
  accessCode: "GOLD2024",      // Admin created
  isActive: true,
  
  // Contact
  phone: "+20 2 1234 5678",
  email: "cairo@golds.com",
  
  // Stats (auto-updated)
  traineeCount: number,
  trainerCount: number,
  activeSubscriptionCount: number,
  totalRevenue: number,
  monthlyRevenue: number,
  
  // Timestamps
  createdAt: timestamp,
  updatedAt: timestamp,
}
```

### Subcollection: `users/{trainerId}/trainees`

```javascript
trainees/{traineeId} {
  // Link Info
  linkedAt: timestamp,
  status: "active" | "inactive" | "removed",
  
  // Cached trainee data (for quick display)
  traineeName: string,
  traineeEmail: string,
  traineeAvatar: string,
  
  // Stats
  lastWorkoutDate: timestamp,
  totalSessions: number,
}
```

### Subcollection: `gyms/{gymId}/activities`

```javascript
activities/{activityId} {
  type: "new_trainee" | "new_trainer" | "subscription" | "payment",
  message: "انضم محمد كمتدرب جديد",
  userId: string,
  userName: string,
  timestamp: timestamp,
  metadata: {
    // additional data based on type
  }
}
```

### Collection: `subscriptions`

```javascript
subscriptions/{subscriptionId} {
  userId: string,              // reference to users/{userId}
  gymId: string,              // reference to gyms/{gymId}
  
  plan: "monthly" | "quarterly" | "yearly",
  status: "active" | "expired" | "cancelled",
  
  startDate: timestamp,
  endDate: timestamp,
  
  price: number,
  paidAmount: number,
  
  createdAt: timestamp,
  updatedAt: timestamp,
}
```

## 🔗 Relationships

```
┌─────────────┐         ┌─────────────┐
│   users     │         │    gyms     │
│  (trainee)  │────────▶│   (gym)     │
│             │ gymId   │             │
└─────────────┘         └─────────────┘
       │
       │ trainerId
       ▼
┌─────────────┐
│   users     │
│  (trainer)  │
└─────────────┘
       │
       │ subcollection
       ▼
┌─────────────┐
│   trainees  │
│  (linked)   │
└─────────────┘
```

## 📊 Required Indexes

### 1. For Linking (Gym Code)
```
Collection: gyms
Fields:    accessCode (Ascending)
           isActive (Ascending)
```

### 2. For Linking (Trainer Code)
```
Collection: users
Fields:    accessCode (Ascending)
           role (Ascending)
```

### 3. For Gym Dashboard
```
Collection: users
Fields:    gymId (Ascending)
           role (Ascending)
```

### 4. For Activities
```
Collection: gyms/{gymId}/activities
Fields:    timestamp (Descending)
```

## 🔐 Security Rules (مقترحة)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Gyms - public read for active gyms
    match /gyms/{gymId} {
      allow read: if resource.data.isActive == true;
      allow write: if false; // Only via Admin SDK
    }
    
    // Trainees subcollection - only trainer can read
    match /users/{trainerId}/trainees/{traineeId} {
      allow read: if request.auth != null && request.auth.uid == trainerId;
    }
  }
}
```

## 🛠️ إنشاء الـ Indexes

روح على:
```
Firebase Console → Firestore Database → Indexes → Composite
```

أضف الـ indexes دي:

| Collection | Fields | Query Scope |
|------------|--------|-------------|
| gyms | accessCode Asc, isActive Asc | Collection |
| users | accessCode Asc, role Asc | Collection |
| users | gymId Asc, role Asc | Collection |
| gyms/{gymId}/activities | timestamp Desc | Collection Group |

## 📝 ملاحظات

1. **accessCode** يتعمل تلقائي في `RoleSelectionScreen._generateAccessCode()`
2. **linkedAt** يتحدث لما المتدرب يدخل كود الجيم/المدرب
3. **trainees subcollection** بتتعمل تلقائي في `TrainerCodeScreen`
4. كل الـ stats بتتحدث عبر Cloud Functions (لازم نضيفها)

## ✅ التحقق

شغل السكريبت ده:
```bash
cd d:\Fit_Flutter\tools
node verify_firebase_schema.js
```
