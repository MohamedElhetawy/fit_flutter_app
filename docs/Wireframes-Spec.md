# FitX — Wireframes & User Flows Specification

**Version:** 1.0.0  
**Status:** Approved for MVP  
**Target Architecture:** Cross-Platform Mobile (React Native / Flutter)

---

## 1. Global Navigation Architecture

### 1.1 Bottom Tab Bar (RTL)

The standard navigation spine for the app.

```text
[🏠 الرئيسية]  [💪 التمرين]  [🥗 التغذية]  [🗺️ عروض]  [👥 مجتمع]
```

### 1.2 Global Header

- **Top Right:** User Avatar (Tap to open Profile & Settings).
- **Top Left:** 🔥 Streak Counter (e.g., "14 يوم").
- **Center:** Total Points & Level Shield.
- *(Scroll behavior: Header collapses into a minimal pill on scroll down, expands on scroll up).*

---

## 2. Screen Detail: Home (الرئيسية)

**Goal:** The morning briefing. Action-oriented, visual, and motivating.

### Anatomy (Top to Bottom)

1. **Dynamic Greeting:** "صباح الفل يا بطل!" (Morning) or "هنكسر الجيم امتى؟" (Evening).
2. **Current State (Daily Rings):**
   - Three large concentric rings dominating the top third of the screen:
   - 🔵 Activity (Steps/Workout) | 🟢 Protein | 🟠 Calories
3. **Emergency Quick Actions (Horizontal scrollable large buttons):**
   - ⚡ **تمرين الطوارئ (15 Min HIIT):** "وقتك ضيق؟ العب 15 دقيقة تعرق فيهم!"
   - 🥶 **منقذ الثلاجة (Fridge Rescue):** "جعان بليل؟ افتح الكاميرا."
   - 📸 **تصوير وجبة (Snap Food):** Camera icon to instantly log Koshary/Egg.
4. **Today's Mission:**
   - A bold card showing the scheduled workout (e.g., "أكتاف وتراي - مستوى متقدم").
   - A bold card for the next scheduled or suggested meal based on the budget planner.

---

## 3. Screen Detail: Workout (التمرين)

**Goal:** Distraction-free tracking, injury prevention, adaptive coaching.

### 3.1 Session Setup (Pre-Workout)

- Pop-up modal: "عاش يا وحش! من 1 لـ 10، حاسس بتعب إيه النهاردة؟" (Fatigue Slider).
- If slider > 8: System suggests swapping Heavy Squats for Recovery stretches.

### 3.2 Active Session (Full-Screen Mode)

- **Top Strip:** Title of exercise (e.g., "بار بنش بريس ضيق") + Interactive 3D muscle heatmap.
- **Center Viewport:**
  - **Pro Users:** Live Camera Feed with colored skeleton overlay. Red lines indicate poor form.
  - **Free Users:** High-quality looped 3D animation of the correct form.
- **Bottom Panel (The Log):**
  - Inputs for Sets, Reps, Weight (e.g., [ 1 ] [ 12 reps ] [ 50 kg ]).
  - Massive **[ ✅ تمت ]** (Done) button. Haptic feedback and confetti burst upon tap.
- **Floating Audio Toggle:** Small icon to enable/disable the Egyptian AI voice coach ("عاش يا بطل! كوعك لجوه!").

---

## 4. Screen Detail: Nutrition (التغذية)

**Goal:** Make logging food frictionless and planning cheap.

### Anatomy (Top to Bottom)

1. **The Magic Scanner:** A massive floating action button centered at the top: `[ 📸 الكاميرا الذكية ]`.
2. **Budget Planner Card ("خطة بروتين على قد جيبك"):**
   - Input field: "ميزانيتك للأسبوع ده كام؟" (e.g., 300 EGP).
   - Generated result standard view: "كرتونة بيض، نص كيلو قريش، كيلو فراخ مخلية." (Swipe to save to grocery list).
3. **Timeline Day View:**
   - Blocks for "الفطار" (Breakfast), "الغدا" (Lunch), "العشا" (Dinner).
   - Tap simple `[ + ]` to text-search or rescan. Fast autocomplete with local Egyptian foods (حواوشي، كشري، طعمية).

---

## 5. Screen Detail: Deals & Marketplace (عروض)

**Goal:** Direct connection with local butchers and gym merchants.

### Anatomy (Top to Bottom)

1. **Smart Butcher Map ("دليل الجزار الذكي"):**
   - Google Maps SDK embedded.
   - Pins show verified local protein sources (Butchers, Supermarkets) and Gyms.
   - Red pins = Active flash deal.
2. **Category Chips:** `[لحوم] [مكملات] [جيمات] [وجبات صحية]`
3. **Flash Deals Feed (Vertical Scroll):**
   - e.g., Card: "خصم 15% على صدور الفراخ من جزارة الحيطاوي - صالح لمدة ساعتين!"
   - Countdown timer on the card.
4. **Floating Action Button: `[ استكان الـ QR ]`**
   - Opens the camera instantly to scan the merchant's code at the checkout counter to apply the discount.

---

## 6. Screen Detail: Community (مجتمع)

**Goal:** Gamify fitness and build local tribes.

### Anatomy (Top to Bottom)

1. **Gym Mayor Leaderboard ("عمدة الجيم"):**
   - Auto-detects the user's primary gym based on GPS history.
   - Podium view of the Top 3 members this month.
   - Progress bar showing what it takes to dethrone the current Alpha.
2. **Virtual Map Challenge ("امشي كأنك بتسافر"):**
   - A beautiful vector map of Egypt. A line traces the user's total steps.
   - "أنت دلوقتي عديت كوبري ستانلي! فاضلك 20 ألف خطوة على الساحل."
3. **Workout Buddy Matcher ("صاحب الجيم"):**
   - A carousel of local users looking for training partners.
   - Shows: Name, Goal ("تنشيف", "ضخامة"), Preferred Workout Time (6 AM / 9 PM).
   - Simple `[ 👍 ابعت دعوة ]` button.

---

## 7. App Flow: Merchant Dashboard (لوحة تحكم الشركاء)

**Target:** Web / iPad View for Gym Owners & Shop Managers.

### Anatomy

1. **Main Stats Dashboard:**
   - Total FitX scans today, estimated revenue from FitX users, average merchant rating.
2. **Create New Offer (Modal):**
   - Title, Description, Discount (%), Expiration Date.
   - Action: "Publish to nearby 5km radius."
3. **QR Code Generator:**
   - Full-screen dynamically refreshing QR code for cashiers to display on a tablet or print.
4. **Review Disputes:**
   - Interface to respond to customer ratings or flag bad actors.
