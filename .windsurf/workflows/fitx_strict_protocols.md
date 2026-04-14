# 🚀 FitX Development Protocols v2.0

**Production-Ready • Scalable • Performance-Aware**

---

# 🎯 الهدف

بناء تطبيق:

* سريع (60 FPS)
* قابل للتوسع (Scalable)
* مستقر (Production-grade)
* سهل الصيانة (Maintainable)

---

# 🧠 Core Philosophy

> **مش كل Rule يتطبق حرفيًا — الذكاء في اختيار الصح حسب السياق**

---

# 📋 القوانين الأساسية (Core Rules)

## 1. Data Law ⭐⭐⭐⭐⭐

```diff
❌ ممنوع: Placeholder في production
✅ مسموح: Mock data في dev فقط
```

```dart
if (kDebugMode) {
  return mockData;
}
```

---

## 2. Design Law ⭐⭐⭐⭐

```diff
❌ UI عشوائي / ألوان مباشرة
✅ Design System موحد (constants + shared widgets)
```

* استخدم:

  * `surfaceColor`
  * `FitXCard`
  * `Spacing system`

---

## 3. Language Law ⭐⭐⭐⭐

```diff
❌ نصوص إنجليزي في UI النهائي
✅ عربي بالكامل (مع دعم localization مستقبلاً)
```

---

## 4. Architecture Law ⭐⭐⭐⭐⭐

```diff
❌ Tight coupling / random state
✅ Clean Architecture:
   - Riverpod
   - Repository Pattern
   - Loose Coupling
```

---

# 🚀 Performance Protocol (NEW - CRITICAL)

## ❌ ممنوع نهائيًا:

* BackdropFilter (blur)
* Heavy logic داخل `build()`
* أكثر من 3 Streams في نفس الشاشة
* rebuilding كامل UI بسبب state صغير

---

## ✅ لازم:

### 1. Lazy Loading

```dart
List<Widget?> _pages = List.filled(5, null);
```

---

### 2. Const Optimization

```dart
const SizedBox(height: 16);
```

---

### 3. Image Optimization

```dart
Image.network(
  url,
  cacheWidth: 400,
)
```

---

### 4. Debounce Inputs

```dart
Timer? _debounce;
```

---

### 5. Move heavy work خارج build

```diff
❌ jsonEncode داخل build
✅ initState / provider
```

---

# 🔄 Data Flow Protocol

```text
Source → Local Cache → Cloud → UI
```

## Layers:

1. **Source**

   * Sensors / APIs

2. **Local**

   * Hive / SharedPrefs

3. **Cloud**

   * Firestore

4. **UI**

   * Riverpod

---

# 🧱 Architecture Rules

## Repository Pattern (مرن)

```dart
class UserRepository {
  Stream<User> watchUser();
  Future<User> getUser();
}
```

> ❗ مش لازم 5 methods لو مش محتاجهم

---

## Provider Strategy (Flexible)

### استخدم حسب الحالة:

| الحالة         | الحل           |
| -------------- | -------------- |
| simple data    | StreamProvider |
| business logic | Notifier       |
| static         | Provider       |

---

# 🧩 Widget Rules

## ❌ غلط:

```dart
class Screen extends ConsumerWidget
```

## ✅ صح:

```dart
StatelessWidget → default
ConsumerWidget → عند الحاجة
```

---

# 📱 UI Protocol

## استخدم حسب الحاجة:

| الحالة        | Widget           |
| ------------- | ---------------- |
| simple scroll | ListView         |
| complex UI    | CustomScrollView |
| static        | Column           |

---

# 🎨 Color System

## ❌ ممنوع:

```dart
Colors.blue مباشرة
```

## ✅ مسموح:

```dart
primaryColor
textPrimary
```

> ✔️ مسموح باستخدام `Colors.white/black` داخل constants فقط

---

# ⚠️ Build Rules

## ❌ ممنوع:

```dart
build() {
  jsonEncode(data);
  heavyCalculation();
}
```

## ✅:

```dart
initState() أو Provider
```

---

# 🧠 State Management Rules

## ❌:

```dart
ref.watch في كل حاجة
```

## ✅:

```dart
ref.watch → UI
ref.listen → side effects
```

---

# 🚨 Error Handling Protocol (NEW)

## ❌:

```dart
Text('خطأ')
```

## ✅:

```dart
FitXErrorWidget(
  message: 'حدث خطأ',
  onRetry: retry,
)
```

---

# 📊 Logging Protocol (NEW)

## ❌:

```dart
print("error");
```

## ✅:

```dart
debugPrint("error");
```

أو Logging service:

```dart
logger.error(e);
```

---

# 🔍 Pre-Edit Protocol

قبل أي تعديل:

* اقرأ الملف
* راجع imports
* افحص TODOs
* افحص الألوان
* افحص النصوص

---

# ✏️ Edit Protocol

أثناء التعديل:

* استخدم constants
* reuse widgets
* حافظ على consistency
* أضف error handling

---

# ✅ Post-Edit Protocol

بعد التعديل:

* `flutter analyze`
* remove unused imports
* check const usage
* test على device حقيقي

---

# 🧪 Testing Protocol

## لازم:

* تجربة على:

  * device حقيقي
  * network ضعيف
  * offline mode

---

# 🚫 Anti-Patterns

## ممنوع:

* Copy-paste بدون فهم
* Features قبل إصلاح bugs
* Over-engineering
* Streams كتير بدون داعي

---

# ⚡ Performance Checklist

قبل release:

* [ ] مفيش blur
* [ ] مفيش heavy build logic
* [ ] lazy loading موجود
* [ ] الصور optimized
* [ ] streams قليلة

---

# 📦 Development Workflow

## الصح:

```text
Fix → Test → Optimize → Add Feature
```

---

# 🎯 Priorities

## P0

* crashes
* data غلط
* security

## P1

* performance
* UX

## P2

* UI polish

---

# 💣 Golden Rules

1. الأداء أهم من الشكل
2. البساطة أهم من التعقيد
3. الكود اللي بيتقري أهم من الكود اللي “شكله جامد”
4. أي حاجة بتتعمل كل frame = خطر

---

# 🧠 الخلاصة

ده نظام:

✔ Production-ready
✔ scalable
✔ performance-aware
✔ مرن (مش متشدد زيادة)

---

**Version:** 2.0
**Status:** READY FOR PRODUCTION
