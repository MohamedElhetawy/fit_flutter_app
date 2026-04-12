# FitX — UI/UX Specification

**Version:** 1.0.0  
**Design Philosophy:** Apple's polish × Google's creativity — for Egypt's streets

---

## 1. Design Philosophy

### Core Principles

**1. Clarity Over Cleverness**  
Every screen does one thing well. No cluttered dashboards. Users should never think — they should feel.

**2. Energy Without Noise**  
The app feels energetic and motivating without being loud or overwhelming. Color and motion are used purposefully, not decoratively.

**3. Culturally Authentic**  
Egyptian Arabic, Egyptian food, Egyptian streets. Nothing that feels copy-pasted from a Western app. Local idioms, not translations.

**4. Earned Trust**  
Every feature that claims to help (AI coach, nutrition advice) must deliver visibly. Trust is built by doing what we said we'd do, precisely and reliably.

**5. Speed as a Feature**  
Every interaction must feel instant. No user should ever wait for something and wonder if it's working.

---

## 2. Navigation Architecture

### Tab Bar (Bottom Navigation — RTL)

```
[🏠 الرئيسية] [💪 التمرين] [🥗 التغذية] [🗺️ عروض] [👥 مجتمع]
```

### Navigation Patterns

- **Push** for drill-down (Home → Workout → Exercise Detail)
- **Modal** for contextual actions (Food log, QR code, Achievement)
- **Bottom Sheet** for merchant cards, meal suggestions
- **Full-screen** for active workout session (no distractions)

---

## 3. Interaction Patterns

### Gesture Vocabulary

| Gesture | Action |
|---------|--------|
| Swipe right | Go back |
| Swipe up | Expand bottom sheet |
| Swipe down | Dismiss modal |
| Long press | Quick actions menu |
| Double tap | Like / favorite |
| Pull to refresh | Refresh feed content |

### Feedback States

Every action has 3 feedback states:

1. **In-progress** — Loading skeleton or spinner
2. **Success** — Green micro-animation + haptic
3. **Error** — Red inline message + shake animation

### Micro-interactions

- "Done" tap on set → Checkmark morphs + confetti burst + haptic
- Streak counter → Flame animates when incremented
- Points awarded → Number counts up with ease-out
- Level up → Full-screen celebration with particle effect

---

## 4. Typography

### Font Family

**Arabic:** Cairo (Google Fonts) — covers all weight needs, excellent Arabic/Latin mix  
**Latin (fallback):** SF Pro (iOS) / Roboto (Android) — system fonts

### Type Scale

| Name | Size | Weight | Usage |
|------|------|--------|-------|
| Display | 32sp | Bold | Screen titles |
| Headline 1 | 24sp | SemiBold | Section headers |
| Headline 2 | 20sp | SemiBold | Card titles |
| Body Large | 16sp | Regular | Primary body text |
| Body | 14sp | Regular | Secondary body |
| Caption | 12sp | Regular | Labels, hints |
| Badge | 10sp | Bold | Numeric badges |

### Line Heights

- Arabic: 1.6× font size (Arabic needs more vertical space)
- Latin: 1.4× font size

---

## 5. Color System

### Primary Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `primary-500` | `#00C8A0` | Primary CTAs, active states |
| `primary-400` | `#33D4B4` | Hover states, highlights |
| `primary-600` | `#009980` | Pressed states |
| `primary-50` | `#E6FBF7` | Light backgrounds |

### Secondary Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `secondary-500` | `#FF6B35` | Energy accents, streaks |
| `secondary-400` | `#FF8A5C` | Warm highlights |
| `secondary-600` | `#E55A24` | Pressed warm states |

### Neutral Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `neutral-900` | `#0D1117` | Primary text |
| `neutral-700` | `#3D4550` | Secondary text |
| `neutral-400` | `#9099A6` | Placeholder text |
| `neutral-100` | `#F2F4F7` | Background surfaces |
| `neutral-50` | `#F8F9FA` | Card backgrounds |
| `white` | `#FFFFFF` | Base background |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#22C55E` | Completion, positive states |
| `error` | `#EF4444` | Errors, warnings |
| `warning` | `#F59E0B` | Caution states |
| `info` | `#3B82F6` | Informational |

### Dark Mode

All tokens have dark mode equivalents. Background inverts to `#0D1117`; surfaces become `#1A2030`; text inverts accordingly.

---

## 6. Spacing System

Base unit: **4dp**

| Token | Value | Usage |
|-------|-------|-------|
| `space-1` | 4dp | Micro spacing (icon padding) |
| `space-2` | 8dp | Tight spacing |
| `space-3` | 12dp | Component internal |
| `space-4` | 16dp | Standard padding |
| `space-5` | 20dp | Medium gaps |
| `space-6` | 24dp | Section spacing |
| `space-8` | 32dp | Large sections |
| `space-12` | 48dp | Screen top padding |

Screen horizontal padding: **20dp** (consistent across all screens)

---

## 7. Component Specifications

### 7.1 Primary Button

```
Height: 56dp
Border radius: 16dp
Background: primary-500
Text: 16sp, SemiBold, White
Padding: 16dp horizontal
Active state: scale(0.97) + darker background
Disabled: 40% opacity
Loading: Replace text with spinner (same color as text)
```

### 7.2 Secondary Button

```
Height: 56dp
Border radius: 16dp
Background: Transparent
Border: 2dp, primary-500
Text: 16sp, SemiBold, primary-500
```

### 7.3 Card

```
Background: White (dark: neutral-800)
Border radius: 20dp
Padding: 20dp
Shadow: 0 4dp 16dp rgba(0,0,0,0.06)
Border: 1dp neutral-100 (subtle)
```

### 7.4 Bottom Tab Bar

```
Height: 80dp (includes safe area)
Background: White / dark surface
Active icon: primary-500, filled
Inactive icon: neutral-400, outlined
Label: 10sp, Cairo
Active label: primary-500, Bold
Indicator: 4dp × 24dp pill above active icon
```

### 7.5 Progress Ring

```
Size: configurable (56dp, 80dp, 120dp variants)
Track: neutral-100
Fill: Gradient (primary-400 → primary-600)
Animation: ease-in-out, 600ms on data load
Center: Text label (number + unit)
```

### 7.6 Macro Card (Nutrition)

```
3-column layout, equal width
Protein: primary-500 ring
Carbs: secondary-500 ring
Fat: #F59E0B ring
Each card: ring + grams + "g" unit + goal beneath
```

### 7.7 Workout Exercise Card

```
Left: Exercise illustration (80×80dp, rounded corners)
Right: Exercise name (Arabic, 16sp Bold) + sets/reps label
Bottom: Muscle group tags (chip components)
Pro badge: Top-right if Pro-only
```

---

## 8. Animation & Motion

### Timing Standards

| Type | Duration | Easing |
|------|----------|--------|
| Micro (tap feedback) | 100ms | ease-out |
| Standard transition | 300ms | ease-in-out |
| Page transition | 350ms | spring (damping 0.8) |
| Celebration | 600ms | custom spring |
| Loading skeleton | Loop, 1.5s | linear |

### Reduced Motion

If user has "Reduce Motion" enabled in OS settings:

- Disable particle effects
- Replace spring animations with instant transitions
- Keep skeleton loading (opacity fade only)

### Key Animations

- **Workout completion:** Confetti burst (duration 800ms, then auto-dismiss)
- **Badge unlock:** Scale from 0→1.1→1.0 with glow pulse
- **Streak increment:** Flame scale up + orange glow ring
- **Points counter:** Number increments with ease-out

---

## 9. RTL (Right-to-Left) Specifications

- All layouts use **logical properties** (start/end, not left/right)
- Navigation: Back button on right, title centered or right-aligned
- Icons: All directional icons (arrows, chevrons) are mirrored automatically
- Text: All Arabic text right-aligned; numbers can be left or right based on context
- Progress bars: Fill from right to left
- Sliders: Drag from right (min) to left (max)
- Swipe gestures: Swipe left = forward, swipe right = back (matches Arabic reading direction)

---

## 10. Accessibility

- Minimum color contrast ratio: 4.5:1 for body text (WCAG AA)
- All interactive elements: minimum 44×44pt tap target
- All images: meaningful alt text in Arabic
- Screen reader: Full VoiceOver (iOS) + TalkBack (Android) support
- Font scaling: Layout must not break at 200% font scale
- Focus indicators: Visible 3dp outline in primary-500
