# 🔐 FitX Database Backup System

> **ملفات الأرشفة الكاملة لـ FitX** - احفظ البيانات كلها بأمان

---

## ⚡ Quick Start (ابدأ هنا!)

### للمستخدمين على Windows (أسهل طريقة):

```powershell
# 1. دخول على المجلد
cd .windsurf\scripts

# 2. تشغيل الباكب
.\backup_fixed.ps1
```

### أو استخدم Batch (أبسط):

```batch
cd .windsurf\scripts
.\backup.bat
```

**⚠️ متطلبات:**
- Node.js مثبت (https://nodejs.org)
- ملف `serviceAccountKey.json` موجود في نفس المجلد
  - حمله من: Firebase Console > Settings > Service Accounts

---

## 📁 الملفات المتوفرة

```
.windsurf/scripts/
├── 📄 backup_database.dart          # سكريبت Dart (Flutter/Firebase SDK)
├── 📄 backup_database.js            # سكريبت Node.js (Firebase Admin)
├── 📄 backup.ps1                    # سكريبت PowerShell (Windows)
├── 📄 restore_database.js           # سكريبت استعادة (تحت التطوير)
└── 📄 README_BACKUP.md              # هذا الملف
```

---

## 🚀 طرق الـ Backup المتاحة

### الطريقة 1: PowerShell Script (الأسهل على Windows) ⭐

**للـ Users على Windows - أسهل طريقة**

```powershell
# فتح PowerShell كـ Administrator
# دخول على مجلد السكريبتات
cd .windsurf\scripts

# تشغيل الـ backup المبسط (موصى به)
.\backup_fixed.ps1

# أو تشغيل الـ batch file (الأسهل)
.\backup.bat
```

**ملاحظة:** لازم تستخدم ` .\ ` قبل اسم الملف في PowerShell!

---

### الطريقة 2: Node.js Script (الأكثر مرونة)

**أفضل للـ Developers**

```bash
# دخول على المجلد
cd .windsurf/scripts

# تحميل الـ dependencies
npm install firebase-admin

# لازم يكون عندك serviceAccountKey.json
# حمله من: Firebase Console > Settings > Service Accounts > Generate Key

# تشغيل الـ backup
node backup_database.js
```

**الناتج:**
```
backup_2024-01-15/
├── users/
│   ├── userId1/
│   │   ├── profile.json
│   │   ├── daily_stats.json
│   │   ├── exerciseHistory.json
│   │   └── exerciseStats.json
│   └── userId2/
│       └── ...
├── linkRequests/
│   └── linkRequests.json
├── tasks/
│   └── tasks.json
├── workouts/
│   └── workouts.json
├── exercises/
│   └── exercises.json
├── metadata.json
└── REPORT.txt
```

---

### الطريقة 3: Dart Script (للـ Flutter Developers)

```bash
# دخول على المجلد
cd .windsurf/scripts

# تشغيل
flutter pub get
dart backup_database.dart
```

---

## 📋 الخطوات قبل الاستخدام

### 1️⃣ Firebase Service Account Key

**لازم تتحمل مرة واحدة:**

1. روح [Firebase Console](https://console.firebase.google.com)
2. اختار مشروع FitX
3. Settings (الجرار) ⚙️ > Project Settings
4. Service Accounts tab
5. Click "Generate new private key"
6. حمل الملف وخلي اسمه `serviceAccountKey.json`
7. حطه في نفس المجلد `.windsurf/scripts/`

⚠️ **تحذير:** الملف ده فيه صلاحيات Admin! احفظه في مكان آمن ومتعملهوش push على Git!

---

### 2️⃣ تثبيت المتطلبات

**لـ Node.js:**
```bash
# في المجلد .windsurf/scripts
npm install firebase-admin
```

**لـ PowerShell (Windows):**
```powershell
# Automatic - هيتثبت لوحده
```

---

## 📊 Collections اللي بتتعملها Backup

| Collection | Subcollections | Priority |
|------------|----------------|----------|
| **users** | daily_stats, exerciseHistory, exerciseStats, progressPhotos, nutritionLogs | 🔴 Critical |
| **linkRequests** | - | 🔴 Critical |
| **tasks** | - | 🟡 High |
| **workouts** | - | 🟡 High |
| **exercises** | - | 🟢 Medium |
| **muscleGroups** | - | 🟢 Medium |
| **foodItems** | - | 🟢 Medium |
| **mealLogs** | - | 🟡 High |

**إجمالي:** 8 Collections + 5 Subcollections

---

## 🔄 زمن Backup

| Method | Time (1000 users) | Time (10,000 users) |
|--------|-------------------|---------------------|
| PowerShell (Firebase) | ~5 min | ~30 min |
| Node.js | ~10 min | ~1 hour |
| Dart | ~15 min | ~1.5 hours |

**ملاحظة:** الوقت بيعتمد على:
- عدد المستخدمين
- حجم البيانات (صور، سجلات)
- سرعة الانترنت

---

## 💾 حفظ الـ Backup

### أماكن محفوظة (مفروض تكون كده):

```
📁 Backup Locations
├── 💻 Local
│   ├── C:\Backups\FitX\
│   └── D:\Archive\FitX\
│
├── ☁️  Cloud
│   ├── Google Drive\FitX-Backups\
│   ├── Dropbox\FitX-Backups\
│   └── OneDrive\FitX-Backups\
│
└── 🗄️  External
    └── External HDD\FitX-Backups\
```

### تسمية الملفات:

```
backup_2024-01-15/              # Daily
backup_2024-01-15_weekly/      # Weekly
backup_2024-01_monthly/        # Monthly
backup_2024-01-15_pre-release/  # Pre-release
```

---

## 🔒 أمان الـ Backup

### ✅ DO:
- [ ] استخدم encryption (BitLocker, VeraCrypt)
- [ ] احفظ في 3+ أماكن مختلفة
- [ ] خلي نسخة offline (HDD مش متصل)
- [ ] اختبر الـ restore كل 3 شهور
- [ ] سجل متى عملت backup و فين

### ❌ DON'T:
- [ ] مترفعش الـ backup على GitHub
- [ ] متشاركهوش في cloud public
- [ ] متحتفظش بس في مكان واحد
- [ ] متنساش الـ password لو مشفر

---

## 🆘 استعادة البيانات (Restore)

**لو حصل كارثة وعايز ترجع البيانات:**

### Manual Restore:
```bash
# 1. امسح الـ Firestore الحالي (CAUTION!)
firebase firestore:delete --all-collections --project=fitx-app

# 2. رفع الـ backup
firebase firestore:import backup_2024-01-15/firestore_export/
```

### ⚠️ تحذيرات:
- جرب الـ restore في **development environment** الأول
- اعمل backup للبيانات الحالية قبل الـ restore
- Restore بيمسح البيانات الحالية!

---

## 📆 جدول الـ Backup

### Pre-Release (قبل كل نشر):
```bash
# قبل ما ترفع version جديد:
.\backup.ps1 -Method node -Compress -OutputPath backup_pre_v1.2.0
```

### Daily (Automatic - مستحسن):
```bash
# Windows Task Scheduler:
# - Run: powershell.exe
# - Arguments: -File "D:\Fit_Flutter\.windsurf\scripts\backup.ps1" -Method node
# - Schedule: Daily at 2:00 AM
```

### Monthly (Deep Archive):
```bash
# نهاية كل شهر
.\backup.ps1 -Method firebase -IncludeStorage -Compress
```

---

## 🐛 Troubleshooting

### مشكلة: "Error: Cannot find module 'firebase-admin'"
**الحل:**
```bash
cd .windsurf/scripts
npm install firebase-admin
```

### مشكلة: "Permission denied on Firestore"
**الحل:**
- تأكد إن `serviceAccountKey.json` صحيح
- تأكد إن الـ account عنده صلاحيات "Firestore Admin"

### مشكلة: "Backup is too slow"
**الحل:**
- استخدم `firebase export` بدل Node.js script
- اعمل backup في وقت الليل (less traffic)

### مشكلة: "Out of memory"
**الحل:**
- زود RAM أو
- افصل الـ backup لأجزاء (by date ranges)

---

## 📞 دعم فني

لو فيه مشكلة:

1. افحص الـ logs في console
2. تأكد من Firebase Console (Firestore usage)
3. اتأكد إن الـ billing شغال (مش free tier limit)

---

## 📊 Backup Report Example

```
╔════════════════════════════════════════════════════════════════╗
║           FitX Database Backup Report                          ║
╚════════════════════════════════════════════════════════════════╝

Backup Date: 15/01/2024, 02:30:45
Project: fitx-app
Duration: 00:05:32

SUMMARY
───────
Total Documents: 15,234
Collections: 8

DETAILS
───────
  • users: 1,234
  • linkRequests: 456
  • tasks: 3,210
  • workouts: 2,100
  • exercises: 850
  • muscleGroups: 45
  • foodItems: 2,300
  • mealLogs: 5,039

SECURITY NOTES
──────────────
• Keep this backup secure and encrypted
• Do not commit to version control
• Store in multiple secure locations

Generated by: FitX Backup Script v1.0
```

---

**تم إنشاء هذا الملف:** 2024  
**آخر تحديث:** 2024  
**النسخة:** 1.0  
**الحالة:** ✅ Ready for Production
