# FitX — Design System

**Version:** 1.0.0  
**Name:** FitX Spark Design System

---

## 1. Overview

The FitX Spark Design System is the single source of truth for all visual and interaction design decisions across the FitX mobile app, partner dashboard, and admin panel.

**Guiding Metaphor:** FitX is like a spark — it ignites motivation, lights up potential, and energizes without burning out. Every design decision reflects this: warm, energetic, precise, and reliable.

---

## 2. Brand Identity

### Logo Usage

- Primary: Wordmark "FitX" with the X rendered in primary-500 (teal)
- Icon variant: "FX" monogram for app icon, favicons
- Minimum size: 80dp width for wordmark, 32dp for icon
- Clear space: Minimum 1× icon height on all sides
- Never stretch, rotate, or recolor the logo outside the approved palette

### Brand Voice (Arabic Copy Guidelines)

- **Tone:** Older brother/sister who cares — warm, direct, humorous
- **Language:** Egyptian colloquial Arabic (عامية), never formal MSA for UI copy
- **Prohibited:** Formal academic language, excessive religious phrases, anglicized Arabic
- **Examples:**
  - ✅ "يلا نبدأ يا بطل!"
  - ❌ "مرحباً بك في تطبيق FitX. يرجى اتباع التعليمات."

---

## 3. Token Reference

### Color Tokens (Full List)

#### Primary (Teal Energy)

```
primary-50:  #E6FBF7
primary-100: #B3F0E5
primary-200: #80E5D3
primary-300: #4DD9C1
primary-400: #33D4B4  ← Hover
primary-500: #00C8A0  ← Primary (Main brand color)
primary-600: #009980  ← Pressed
primary-700: #007060
primary-800: #004840
primary-900: #002820
```

#### Secondary (Flame Orange)

```
secondary-50:  #FFF1EC
secondary-100: #FFD5C2
secondary-200: #FFB999
secondary-300: #FF9D6F
secondary-400: #FF8A5C  ← Hover
secondary-500: #FF6B35  ← Streak/Energy accent
secondary-600: #E55A24  ← Pressed
secondary-700: #CC4913
secondary-800: #B23802
secondary-900: #992700
```

#### Neutral (Gray Scale)

```
neutral-0:   #FFFFFF
neutral-50:  #F8F9FA
neutral-100: #F2F4F7
neutral-200: #E5E9F0
neutral-300: #CDD3DE
neutral-400: #9099A6
neutral-500: #6B7585
neutral-600: #4F5A6A
neutral-700: #3D4550
neutral-800: #2A3142
neutral-900: #0D1117
```

---

## 4. Component Library

### Atoms

#### Button Variants

| Variant | Background | Text | Border | Use Case |
|---------|-----------|------|--------|----------|
| Primary | primary-500 | White | None | Main actions |
| Secondary | Transparent | primary-500 | primary-500, 2dp | Secondary actions |
| Ghost | Transparent | neutral-700 | None | Tertiary |
| Danger | error (#EF4444) | White | None | Delete/suspend |
| Loading | primary-500 | — | None | Async actions |
| Disabled | neutral-200 | neutral-400 | None | Unavailable |

#### Icon Sizes

```
xs:  16dp (inline with text)
sm:  20dp (compact UI)
md:  24dp (standard)
lg:  32dp (emphasis)
xl:  40dp (feature icons)
2xl: 48dp (empty states, onboarding)
```

#### Input Fields

```
Height: 56dp
Border radius: 14dp
Border: 1.5dp neutral-200 (default) / primary-500 (focused) / error (error)
Background: neutral-50
Label: 12sp, neutral-600, positioned above (floating label)
Placeholder: neutral-400
Input text: neutral-900, 16sp
Helper text: 12sp below field
Error text: 12sp, error color, with ⚠ icon
```

#### Chips / Tags

```
Height: 32dp
Border radius: 8dp (or full-pill for selected state)
Padding: 8dp horizontal
States: Default (neutral-100 bg) / Selected (primary-50 bg, primary-500 border + text)
Text: 12sp, SemiBold
```

### Molecules

#### Workout Card

```
┌────────────────────────────────────────┐
│  [Exercise Image 80×80]  Exercise Name │
│                          Sets × Reps   │
│                          [Muscle Tags] │
│                          [Pro Badge?]  │
└────────────────────────────────────────┘
Height: auto (min 96dp)
Border radius: 20dp
Padding: 16dp
```

#### Merchant Card (Map Bottom Sheet)

```
Drag handle at top center
Merchant name: 20sp Bold
Rating: ⭐ X.X (XX ratings)
Distance: X km
Category badge
Offers: Scrollable horizontal list of offer chips
[استلم الخصم] Primary CTA button
```

#### Macro Ring Card

```
3-column grid
Each column:
  - Progress ring (60dp)
  - Value (16sp Bold, macro color)
  - Label (12sp, neutral-500)
  - Goal (12sp, neutral-400)
```

#### Notification Item

```
Left: Icon (40dp circle, colored bg)
Center: Title (14sp Bold) + Body (13sp neutral-600)
Right: Timestamp (11sp neutral-400)
Unread indicator: 8dp circle in primary-500 on right
Tap: Opens relevant screen
```

### Organisms

#### Home Dashboard

- Header: greeting + date + notification bell
- Daily Nutrition Ring (large, centered)
- Today's Workout Card (tap to start)
- Streak + Rank row
- Quick Actions (3 items)
- Bottom Tab Bar

#### Workout Execution Screen

- Progress bar (top)
- Exercise illustration (fills upper 40%)
- Set counter + rep target
- Weight input
- Done button (large, full-width)
- AI Coach FAB (Pro users)
- Skip + End Early (secondary, bottom)

#### Achievement Celebration (Modal)

- Background blur + dark overlay
- Badge icon (scale-in animation)
- Badge name + description
- Confetti particles (800ms)
- "مبروك يا بطل! 🎉" headline
- Points awarded counter animation
- Share + Dismiss CTAs

---

## 5. Iconography

### Icon Library

Use **Phosphor Icons** (supports Arabic/RTL mirror flag):

- Consistent weight: Regular (default), Bold (emphasis)
- All icons available in outlined and filled variants
- Switch to filled for active states

### Custom FitX Icons

| Icon | Description |
|------|-------------|
| Gym Mayor Crown | Crown with "M" monogram for Mayor badge |
| EGP Symbol | Egyptian pound symbol for budget screens |
| Map Challenge | Footstep + map pin composite |
| Fridge Rescue | Fridge + lightning bolt |
| Voice Coach | Microphone + sound waves |

---

## 6. Illustration Style

- Style: Semi-flat with subtle shadows; warm, friendly
- Characters: Diverse Egyptian body types; modest but athletic attire
- Color: Uses brand palette (primary teal + secondary orange accents)
- Usage: Onboarding screens, empty states, achievement modals
- Tool: Produced in Figma using vector components

---

## 7. Grid System

### Mobile Grid

```
Columns: 4
Gutter: 16dp
Margin: 20dp (horizontal)
```

### 12-Column System (for complex screens)

```
Columns: 12
Gutter: 8dp  
Margin: 20dp
```

---

## 8. Elevation System

| Level | Shadow | Usage |
|-------|--------|-------|
| 0 | None | Flat backgrounds |
| 1 | 0 2dp 4dp rgba(0,0,0,0.05) | Cards, inputs |
| 2 | 0 4dp 12dp rgba(0,0,0,0.08) | Bottom sheets, dropdowns |
| 3 | 0 8dp 24dp rgba(0,0,0,0.12) | Floating buttons, modals |
| 4 | 0 16dp 40dp rgba(0,0,0,0.16) | Dialogs, full overlays |

---

## 9. Dark Mode Specifications

| Element | Light | Dark |
|---------|-------|------|
| Background | #FFFFFF | #0D1117 |
| Surface (cards) | #F8F9FA | #1A2030 |
| Elevated surface | #FFFFFF | #252D40 |
| Primary text | #0D1117 | #F2F4F7 |
| Secondary text | #3D4550 | #9099A6 |
| Primary color | #00C8A0 | #00C8A0 (unchanged) |
| Borders | #E5E9F0 | #2A3142 |

---

## 10. Design Handoff Checklist

Before any design is handed to engineering:

- [ ] All components use Design System tokens (no hardcoded hex values)
- [ ] RTL version exported alongside LTR
- [ ] All states defined: default, hover, active, disabled, loading, error, empty
- [ ] Dark mode version included
- [ ] Accessibility annotations added (roles, labels, focus order)
- [ ] Motion specs documented (duration, easing, trigger)
- [ ] Assets exported at 1×, 2×, 3× for iOS; 1×, 1.5×, 2×, 3×, 4× for Android
