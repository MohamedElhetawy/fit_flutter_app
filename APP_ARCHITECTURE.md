# 🏋️ FitX App Architecture Documentation

## Overview
FitX is a modern, fully dynamic fitness tracking application built with Flutter and Firebase. The app follows a **layered architecture pattern** with **GoRouter** for navigation and **Riverpod** for state management.

---

## 📱 App Structure

### **Root Entry Point**
- **`lib/main.dart`** — Firebase initialization and app launch
- **`lib/src/app.dart`** — Main app configuration with theme loading
- **`lib/constants.dart`** — Global colors, fonts, spacing constants

---

## 🎨 Theme System

### **Modern Glassmorphism Design**
Location: `lib/theme/`

**Key Features:**
- **Dark Theme** — Premium deep black (#0A0A0C) with lime-green accents (#CDDC39)
- **Glassmorphism Effects** — Frosted glass containers with backdrop blur
- **Responsive Typography** — Grandis Extended for display text, Plus Jakarta for body
- **Utility Functions:**
  - `AppTheme.buildGlassmorphicContainer()` — Creates frosted glass UI
  - `AppTheme.buildPremiumGradient()` — Premium gradient backgrounds
  - `AppTheme.buildRadialGradient()` — Ambient glow effects

**Files:**
- `app_theme.dart` — Main theme configuration
- `button_theme.dart` — Elevated, Outlined, Text button styles
- `input_decoration_theme.dart` — Form field styling
- `checkbox_themedata.dart` — Custom checkbox design
- `theme_data.dart` — Typography and spacing constants

---

## 🔐 Authentication Flow

### **Routes:**
```
/login          → LoginScreen
/signup         → SignUpScreen  
/role-selection → RoleSelectionScreen
```

### **Modern Login Screen** (`lib/screens/auth/views/login_screen.dart`)
✨ **Features:**
- **Smooth Animations** — FadeIn, SlideIn, ScaleTransition effects
- **Glassmorphic Form Container** — Modern frosted glass design
- **Social Login** — Google & Apple sign-in buttons (mobile)
- **Email/Password Validation** — Real-time form validation
- **Loading States** — Animated spinner during authentication
- **Responsive Layout** — Adapts to all screen sizes

**Components:**
- `login_form.dart` — Email/Password input fields with icons
- `signup_form.dart` — Registration form

### **Auth State Management**
- `authStateProvider` — Watches current user authentication state
- `currentUserRoleProvider` — Tracks user role for conditional routing
- `authControllerProvider` — Handles sign-in/sign-up logic

---

## 🏠 Dashboard Shell & Navigation

### **Main Dashboard** (`lib/src/features/dashboard/presentation/dashboard_shell.dart`)

**Modern Bottom Navigation Bar:**
```
┌─────────────────────────────────────┐
│  🏠 Home  │  📊 Stats  │  💪 Workout  │  👤 Profile  │
└─────────────────────────────────────┘
```

**Features:**
- **Frosted Glass Design** — Glassmorphism with backdrop blur
- **Smooth Page Transitions** — PageView with animation
- **Active Tab Indicators** — Animated background highlight
- **Responsive Spacing** — Accounts for safe areas and notches

**Navigation Items:**
1. **Home Tab** — `FitXHomeScreen` (Dashboard with quick stats)
2. **Stats Tab** — `StatisticsScreen` (Progress tracking & charts)
3. **Workout Tab** — `WorkoutsScreen` (Routine & exercise library)
4. **Profile Tab** — `ProfileScreenFitX` (User settings & data)

### **Routing Architecture** (`lib/src/core/routing/app_router.dart`)

```dart
// Redirect Logic:
NOT_LOGGED_IN → /login
LOGGED_IN_NO_ROLE → /role-selection
LOGGED_IN_WITH_ROLE → /dashboard (or stay on current route)
FROM_AUTH_TO_DASHBOARD → Automatic redirect
```

---

## 🎯 Feature Modules

### **1. Home** (`lib/src/features/home/`)
**Purpose:** Main dashboard overview
- Welcome message with user's name
- Running workout indicator
- Health metrics cards
- Recommended workouts carousel

### **2. Workouts** (`lib/src/features/workouts/`)
**Purpose:** Exercise library and routine management
- Browse exercises by category
- Create custom routines
- Track workout history
- Super admin CMS for managing exercises

### **3. Nutrition** (`lib/src/features/nutrition/`)
**Purpose:** Meal tracking and nutritional guidance
- Log meals and track calories
- Nutritional dashboard with charts
- Meal recommendations
- Nutrition catalog manager

### **4. Statistics** (`lib/src/features/statistics/`)
**Purpose:** Progress tracking and analytics
- Weight & body measurements trends
- Workout volume charts
- Calorie burn analytics
- Performance metrics

### **5. Profile** (`lib/src/features/profile/`)
**Purpose:** User account and preferences
- Edit profile information
- Settings (Notifications, Theme, Units)
- Linked devices
- Logout

---

## 🔗 Data Flow & Real Data Integration

### **State Management: Riverpod**

**Providers Used:**
- `ConsumerWidget` / `ConsumerStatefulWidget` — Consume providers in UI
- `ref.watch()` — Listen to provider changes
- `ref.read()` — One-time read without listening
- `ref.watch(authControllerProvider)` — Current auth state

**Real Data Sources:**
1. **Firebase Authentication** — User login/signup
2. **Cloud Firestore** — User profiles, workouts, nutrition logs
3. **Firebase Storage** — User profile images, exercise videos
4. **Health API** — Step count, heart rate, calories

### **Example: Getting Real Workout Data**
```dart
// In any ConsumerWidget:
final workouts = ref.watch(getWorkoutsProvider); // Listens to real data updates

workouts.when(
  data: (workoutList) => ListView.builder(
    itemCount: workoutList.length,
    itemBuilder: (context, i) => WorkoutCard(workout: workoutList[i]),
  ),
  loading: () => const LoadingShimmer(),
  error: (err, stk) => ErrorWidget(error: err),
);
```

---

## 🧭 Navigation Examples

### **Programmatic Navigation**
```dart
import 'package:go_router/go_router.dart';

// Navigate to route
context.go('/dashboard');
context.go('/role-selection');

// Navigate with state
context.go('/dashboard', extra: userData);

// Pop back
context.pop();
```

### **Named Routes (Type-safe)**
```dart
GoRoute(
  path: '/dashboard',
  name: 'dashboard',  // Enable by name
  builder: (context, state) => const DashboardShell(),
);

// Usage:
context.pushNamed('dashboard');
```

---

## 📦 Project Dependencies

### **Core**
- `flutter_riverpod: ^2.6.1` — State management
- `go_router: ^14.8.1` — Navigation routing
- `firebase_core: ^3.13.0` — Firebase setup

### **UI/UX**
- `flutter_svg: ^2.0.10+1` — SVG assets
- `animations: ^2.0.11` — Built-in animations
- `cached_network_image: ^3.2.0` — Image caching

### **Fitness Features**
- `health: ^12.2.1` — Health data (steps, heart rate)
- `sensors_plus: ^6.1.1` — Device sensors
- `permission_handler: ^11.3.1` — Permission management
- `fl_chart: ^0.69.0` — Charts & graphs

### **Data & Auth**
- `firebase_auth: ^5.5.2` — Authentication
- `cloud_firestore: ^5.6.6` — Database
- `google_sign_in: ^6.3.0` — Google Sign-In
- `firebase_storage: ^12.4.5` — File storage

---

## 🎬 Getting Started

### **1. Build & Run**
```bash
flutter pub get
flutter run
```

### **2. Hot Restart**
After seeing the new UI with animations:
```
Press 'R' in terminal for hot restart
```

### **3. Test Navigation**
- ✅ Login with email/password
- ✅ Tap social login buttons (Google/Apple)
- ✅ Verify bottom nav tabs scroll smoothly
- ✅ Check animations on all screens

---

## ✨ Modern Features Implemented

### **UI/UX**
- ✅ Glassmorphism containers with backdrop blur
- ✅ Smooth fade-in and slide animations
- ✅ Responsive bottom navigation bar
- ✅ Premium color scheme (Lime-green on deep dark)
- ✅ Custom typography with Grandis Extended

### **Authentication**
- ✅ Email/password validation
- ✅ Google & Apple sign-in
- ✅ Role-based routing
- ✅ Persistent session management

### **Navigation**
- ✅ GoRouter with proper redirects
- ✅ Type-safe named routes
- ✅ State restoration support
- ✅ Deep linking ready

### **Data**
- ✅ Real Firebase integration
- ✅ Riverpod state management
- ✅ Firestore database connectivity
- ✅ Health API integration ready

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     User Action (Tap)                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│          UI Widget (LoginScreen / DashboardShell)           │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│   Riverpod Provider (authControllerProvider, etc.)          │
│   ● Handles business logic                                  │
│   ● Notifies listeners of data changes                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│            Firebase Services (Auth, Firestore)              │
│   ● Authenticates user credentials                          │
│   ● Fetches/Updates user data                               │
│   ● Syncs with backend                                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│     Response → Provider → UI Update (Automatic with         │
│     ref.watch() and UI rebuilds)                            │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Next Steps

### **Recommended Enhancements:**
1. **Offline Support** — Add Hive local caching
2. **Notifications** — Firebase Cloud Messaging
3. **Analytics** — Firebase Analytics tracking
4. **Premium Features** — In-app purchases
5. **Social Sharing** — Share workouts and achievements
6. **Personal Trainer** — AI-powered workout recommendations

---

## 📞 Support & Contacts

- **Firebase Console:** https://firebase.google.com/
- **Flutter Docs:** https://flutter.dev/docs
- **GoRouter Guide:** https://pub.dev/packages/go_router
- **Riverpod Docs:** https://riverpod.dev

---

**Last Updated:** April 10, 2026  
**FitX Version:** 1.0.0  
**Built with:** Flutter 3.2+ | Firebase | Riverpod
