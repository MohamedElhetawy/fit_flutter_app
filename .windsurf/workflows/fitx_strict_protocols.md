# FitX Strict Development Protocols

## 🎯 الهدف: آيب مترابط 100% - بيانات حقيقية - تصميم موحد

---

## 📋 القوانين الأساسية (Core Rules)

### 1. **قانون البيانات (Data Law)** ⭐⭐⭐⭐⭐
```
❌ ممنوع: Placeholder, Mock, Dummy, Static Values
✅ لازم: بيانات حقيقية من Firebase أو Hardware
```

### 2. **قانون التصميم (Design Law)** ⭐⭐⭐⭐⭐
```
❌ ممنوع: Colors.grey/blue/red - Material Card - AppBar عادي
✅ لازم: surfaceColor, surfaceBorder, FitXCard, CustomScrollView
```

### 3. **قانون اللغة (Language Law)** ⭐⭐⭐⭐⭐
```
❌ ممنوع: أي نص إنجليزي في UI (Errors, Labels, Buttons)
✅ لازم: كل النصوص عربي 100%
```

### 4. **قانون الـ Architecture (Architecture Law)** ⭐⭐⭐⭐⭐
```
❌ ممنوع: Navigator.push - State محلي فقط - Coupling عالي
✅ لازم: GoRouter - Riverpod - Repository Pattern - Loose Coupling
```

---

## 🔒 بروتوكولات الصرامة (Strict Protocols)

### **البروتوكول 1: قبل أي تعديل (Pre-Edit Protocol)**

قبل ما أعدل أي ملف:

1. **اقرأ الملف كامل** (أول 50 سطر + آخر 50 سطر)
2. **افحص الـ Imports** (كلهم used؟ فيه duplicates؟)
3. **افحص الـ TODOs** (امسحها أو حولها لـ GitHub Issues)
4. **افحص الألوان** (فيها Colors.grey/blue/red/white/black؟)
5. **افحص النصوص** (فيها إنجليزي؟)

### **البروتوكول 2: أثناء التعديل (Edit Protocol)**

كل تعديل لازم:

1. **يستخدم Constants فقط** (bgColor, textPrimary, surfaceColor)
2. **يستخدم Shared Widgets** (FitXCard, SectionHeader, FitXShimmer)
3. **يتبع نفس الـ Pattern** (CustomScrollView, Slivers)
4. **يحافظ على RTL** (Arabic text direction)
5. **يضيف Error Handling** (AsyncValue.error handling)

### **البروتوكول 3: بعد التعديل (Post-Edit Protocol)**

بعد كل تعديل:

1. **افحص Lint Errors** (flutter analyze)
2. **افحص الـ Imports** (unused imports)
3. **افحص الـ Const** (const constructors where possible)
4. **تأكد من الـ Flow** (البيانات تجي من فين؟)
5. **تأكد من الـ Arabic** (كل النصوص عربي؟)

### **البروتوكول 4: الـ Data Flow Protocol**

```
Hardware/External → Local Storage → Cloud (Firestore) → UI
         ↓                    ↓              ↓            ↓
   (Pedometer)       (SharedPrefs)     (Firebase)   (Riverpod)
```

كل Feature لازم يتبع:
1. **Source** (Hardware: Pedometer, Camera, GPS)
2. **Local Cache** (SharedPreferences, Hive, SQLite)
3. **Cloud Sync** (Firestore with merge: true)
4. **UI Provider** (Riverpod StreamProvider)

### **البروتوكول 5: الـ Naming Protocol**

| المكان | الـ Pattern | مثال |
|--------|-------------|------|
| Files | snake_case | `unified_steps_service.dart` |
| Classes | PascalCase | `UnifiedStepsService` |
| Providers | lowerCamelCase + Provider | `unifiedStepsProvider` |
| Constants | UPPER_SNAKE_CASE | `PRIMARY_COLOR` |
| Functions | lowerCamelCase | `calculateVolumePercentile` |
| Widgets Private | _PascalCase | `_MetricCard` |

### **البروتوكول 6: الـ Repository Protocol**

كل Repository لازم:

```dart
class XxxRepository extends BaseRepository {
  // Constructor Injection
  const XxxRepository({required FirebaseFirestore firestore})
      : super(firestore: firestore);

  // 1. Watch (Real-time Stream)
  Stream<T> watchXxx(...) { }

  // 2. Get (One-time Future)
  Future<T> getXxx(...) { }

  // 3. Create
  Future<String> createXxx(...) { }

  // 4. Update
  Future<void> updateXxx(...) { }

  // 5. Delete
  Future<void> deleteXxx(...) { }
}
```

### **البروتوكول 7: الـ Provider Protocol**

كل Provider لازم:

```dart
// 1. Service Provider
final xxxServiceProvider = Provider<XxxService>((ref) {
  final service = XxxService();
  ref.onDispose(() => service.dispose());
  return service;
});

// 2. Stream Provider (Real-time)
final xxxStreamProvider = StreamProvider<T>((ref) {
  final service = ref.watch(xxxServiceProvider);
  return service.xxxStream;
});

// 3. Value Provider
final xxxProvider = Provider<T>((ref) {
  final async = ref.watch(xxxStreamProvider);
  return async.when(data: ..., loading: ..., error: ...);
});

// 4. Notifier Provider (Operations)
final xxxNotifierProvider = StateNotifierProvider<XxxNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(xxxServiceProvider);
  return XxxNotifier(service);
});
```

### **البروتوكول 8: الـ Screen Protocol**

كل Screen لازم:

```dart
class XxxScreen extends ConsumerWidget {  // ConsumerWidget مش StatelessWidget
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: bgColor,  // ✅ لازم
      body: SafeArea(
        child: CustomScrollView(  // ✅ لازم
          slivers: [
            // Header
            SliverPadding(...)
            // Content
            SliverList(...)
            // Bottom Padding
            SliverToBoxAdapter(child: SizedBox(height: 100))
          ],
        ),
      ),
    );
  }
}
```

### **البروتوكول 9: الـ Color Protocol**

❌ **ممنوع نهائياً:**
- `Colors.grey[200]`, `Colors.grey[600]`, `Colors.grey[700]`
- `Colors.blue`, `Colors.red`, `Colors.green`, `Colors.orange`
- `Colors.white`, `Colors.black`

✅ **لازم نستخدم:**
```dart
// Backgrounds
bgColor           // Color(0xFF0A0A0A)
surfaceColor      // Color(0xFF141414)
surfaceColorLight // Color(0xFF1E1E1E)

// Text
textPrimary       // Colors.white
textSecondary     // Colors.white70
textTertiary      // Colors.white38

// Accents
primaryColor      // Color(0xFFD4FF00)
successColor      // Colors.green
colorError        // Colors.red

// Borders
surfaceBorder     // Color(0xFF2A2A2A)
```

### **البروتوكول 10: الـ Text Protocol**

❌ **ممنوع:**
```dart
'Error'        // ❌
'Loading...'   // ❌
'Steps'        // ❌
'Calories'     // ❌
```

✅ **لازم:**
```dart
'خطأ'           // ✅
'جاري التحميل...' // ✅
'الخطوات'        // ✅
'السعرات'        // ✅
```

---

## 🚨 قائمة الأخطاء الممنوعة (Prohibited Errors)

### **خطأ 1: استخدام `context.push` من غير GoRouter Import**
```dart
// ❌ WRONG
import 'package:flutter/material.dart';
...
context.push('/route');  // Error!

// ✅ CORRECT
import 'package:go_router/go_router.dart';
...
context.go('/route');    // GoRouter method
```

### **خطأ 2: استخدام `MaterialPageRoute`**
```dart
// ❌ WRONG
Navigator.push(context, MaterialPageRoute(...));

// ✅ CORRECT
context.go('/route');
// أو
context.push('/route');
```

### **خطأ 3: Placeholder Data**
```dart
// ❌ WRONG
return '75';  // Static value

// ✅ CORRECT
return calculateFromBackend(session);
```

### **خطأ 4: Missing Error Handling**
```dart
// ❌ WRONG
final data = await ref.watch(provider);

// ✅ CORRECT
final dataAsync = ref.watch(provider);
dataAsync.when(
  data: (data) => ...,
  loading: () => FitXShimmerCard(...),
  error: (e, _) => Text('خطأ: $e'),
);
```

### **خطأ 5: Missing const**
```dart
// ❌ WRONG
const SizedBox(height: spaceMd),  // ❌ constant value in non-const

// ✅ CORRECT
const SizedBox(height: 16),  // ✅ const with literal
// أو
SizedBox(height: spaceMd),   // ✅ non-const with variable
```

---

## ✅ قائمة المراجعة (Review Checklist)

قبل ما أقول "تم":

- [ ] كل الـ imports used ومش duplicates
- [ ] كل النصوص عربي
- [ ] كل الألوان من constants.dart
- [ ] مش فيه `TODO`, `FIXME`, `HACK` في الـ production code
- [ ] كل الـ data coming من real source (Firebase/Hardware)
- [ ] Error handling موجود في كل async operations
- [ ] CustomScrollView used في كل screens
- [ ] const used where possible
- [ ] 100px bottom padding for all screens
- [ ] GoRouter used for navigation

---

## 🎯 الأولويات (Priorities)

### P0 (Critical) - يوقف الـ Release
1. بيانات وهمية (Placeholder data)
2. Crashes أو Errors
3. Auth/Security issues

### P1 (High) - لازم يتصلح
1. نصوص إنجليزية
2. ألوان غير موحدة
3. Missing error handling

### P2 (Medium) - ممكن ينتظر
1. UI Polish
2. Animations
3. Performance optimization

### P3 (Low) - Nice to have
1. Comments
2. Extra features
3. Refactoring

---

## 🚫 ما أعملوش أبداً (Never Do)

1. ❌ ما أضيفش feature جديد قبل ما أصلح البوظ القديم
2. ❌ ما أستخدمش `print()` - استخدم `debugPrint()` أو Logging
3. ❌ ما أعملش copy-paste من Stack Overflow من غير فهم
4. ❌ ما أعدلش في 3+ files في نفس الوقت (One file at a time)
5. ❌ ما أدفعش code من غير test على device حقيقي

---

## ✅ اللي لازم أعمله (Always Do)

1. ✅ Test كل feature على device حقيقي
2. ✅ Check Flutter analyze before commit
3. ✅ One task at a time (Focus)
4. ✅ Document any new patterns
5. ✅ Keep TODOs in GitHub Issues, not code

---

**اتفاقية:**
أنا الـ AI هلتزم بالبروتوكولات دي 100%. لو خالفت أي بروتوكول، المستخدم يصححني فوراً.

**Protocol Version:** 1.0
**Last Updated:** Today
**Status:** ACTIVE
