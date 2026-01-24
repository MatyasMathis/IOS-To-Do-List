# UI/UX Redesign: "Whoop Inspired" - Athletic Performance Tracker

## 🎯 Design Philosophy
Clean, data-driven, performance-focused design inspired by Whoop's approach to tracking and habits. Emphasizes achievement, streaks, and daily consistency with bold minimalism.

**Key Principle**: Keep current implementation and features - only update the visual design and user experience.

---

## 🎨 Color Scheme

### Primary Colors
- **Brand Black**: `#0A0A0A` (Deep, rich black for backgrounds)
- **Pure White**: `#FFFFFF` (High contrast text)
- **Recovery Green**: `#2DD881` (Success, completion, positive actions)
- **Strain Red**: `#FF4444` (Alerts, delete actions)
- **Performance Purple**: `#7B61FF` (Recurring tasks, premium feel)

### Supporting Colors
- **Dark Gray 1**: `#1A1A1A` (Card backgrounds)
- **Dark Gray 2**: `#2A2A2A` (Elevated surfaces)
- **Medium Gray**: `#808080` (Secondary text)
- **Light Gray**: `#E0E0E0` (Borders, dividers)

### Category Colors (Bold & Saturated)
- **Work**: `#4A90E2` (Electric Blue)
- **Personal**: `#F5A623` (Vibrant Orange)
- **Health**: `#2DD881` (Recovery Green - matches completion)
- **Shopping**: `#BD10E0` (Magenta)
- **Other**: `#808080` (Neutral Gray)

### Theme Support
- **Dark Mode**: Primary (default experience)
- **Light Mode**: Inverted with white backgrounds, black text, same accent colors

---

## 📱 Screen-by-Screen Redesign

### 1. Today's Task View (TaskListView)

#### Layout Changes
```
┌─────────────────────────────────┐
│ ◀ Today            Jan 24 🔥3   │ ← Navigation bar with streak
├─────────────────────────────────┤
│ ┌─────────────────────────────┐ │
│ │ DAILY PROGRESS              │ │ ← Stats card
│ │ 4/8 completed   50%         │ │
│ │ ████████░░░░░░░░             │ │ ← Progress bar
│ └─────────────────────────────┘ │
│                                 │
│ ┌───────────────────────────┐   │
│ │ ○ Morning Workout        >│   │ ← Task card
│ │   HEALTH                   │   │
│ └───────────────────────────┘   │
│                                 │
│ ┌───────────────────────────┐   │
│ │ ✓ Team Meeting           >│   │ ← Completed (strikethrough)
│ │   WORK • 🔄 DAILY         │   │
│ └───────────────────────────┘   │
│                                 │
│              [+]                │ ← Floating action button
└─────────────────────────────────┘
```

#### Component Details

**Header/Navigation**
- Left: Back arrow (if needed) + "Today" in SF Pro Display Bold
- Center: None (left-aligned title)
- Right: Current date + streak flame icon with number (3-day streak)
- Background: Blur effect over content
- Height: 60pt

**Daily Progress Card** (NEW FEATURE)
- Card style: Rounded rectangle (16pt radius)
- Background: Dark Gray 1 with subtle gradient
- Padding: 20pt all sides
- Content:
  - "DAILY PROGRESS" label (SF Pro Text Semibold, 12pt, uppercase, Medium Gray)
  - "4/8 completed" (SF Pro Display Bold, 28pt, White)
  - "50%" (SF Pro Display Bold, 28pt, Recovery Green)
  - Progress bar: 8pt height, Recovery Green fill, Dark Gray 2 background
  - Animation: Smooth fill animation on completion
- Shadow: Subtle (0, 4, 12, rgba(0,0,0,0.3))

**Task Card**
- Card style: Rounded rectangle (12pt radius)
- Background: Dark Gray 2
- Padding: 16pt horizontal, 14pt vertical
- Spacing between cards: 8pt
- Border: None (elevation through shadow)
- Shadow: (0, 2, 8, rgba(0,0,0,0.2))
- Hover/Press: Scale 0.98, increased shadow

**Task Card Layout**
```
┌─────────────────────────────────┐
│ ○  Task Title               > │
│    CATEGORY • 🔄 DAILY         │
└─────────────────────────────────┘
```

- Checkbox: 24pt circle (stroke 2pt)
  - Unchecked: White stroke
  - Checked: Recovery Green fill with white checkmark
  - Animation: Scale bounce + haptic
- Title: SF Pro Display Medium, 17pt, White
  - Completed: 60% opacity + strikethrough
- Chevron: 16pt, Medium Gray (indicates swipe actions)
- Badges row: HStack with 6pt spacing
  - Category badge: Capsule, category color background (20% opacity), category color text, 11pt
  - Recurring badge: "🔄 DAILY" with Performance Purple color
- Swipe Actions:
  - Left: Complete (Recovery Green background, checkmark icon)
  - Right: Delete (Strain Red background, trash icon)

**Empty State**
- Large icon: Checklist icon (80pt, Medium Gray)
- Title: "Ready to Crush Today?" (SF Pro Display Bold, 24pt)
- Subtitle: "Add your first task to start building your streak" (SF Pro Text, 16pt, Medium Gray)
- CTA Button: "Add Task" (Recovery Green, rounded 12pt)

**Floating Action Button (FAB)**
- Position: Bottom right, 24pt from edges
- Size: 56pt diameter
- Background: Gradient (Recovery Green to lighter green)
- Icon: Plus sign (White, 24pt, bold)
- Shadow: (0, 6, 16, rgba(45,216,129,0.4))
- Animation: Bounce on tap, slight rotation on list scroll

---

### 2. Add Task Sheet (AddTaskSheet)

#### Layout Changes
```
┌─────────────────────────────────┐
│          Add New Task       ✕   │ ← Handle + close
├─────────────────────────────────┤
│                                 │
│ TASK NAME                       │
│ ┌─────────────────────────────┐ │
│ │ Enter task name...          │ │ ← Input field
│ └─────────────────────────────┘ │
│                                 │
│ CATEGORY                        │
│ ┌───┐ ┌───┐ ┌───┐ ┌───┐ ┌───┐ │
│ │💼 │ │🏠 │ │💚 │ │🛒 │ │⚪ │ │ ← Icon buttons
│ └───┘ └───┘ └───┘ └───┘ └───┘ │
│ Work  Pers. Health Shop  Other │
│                                 │
│ FREQUENCY                       │
│ ┌─────────────────────────────┐ │
│ │ ○ One Time                  │ │ ← Radio buttons
│ │ ● Daily Recurring   🔄      │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │     Create Task             │ │ ← CTA button
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

#### Component Details

**Sheet Presentation**
- Style: Medium detent sheet (half screen)
- Background: Dark Gray 1
- Corner radius: 20pt (top corners only)
- Drag handle: White, centered, 40pt wide, 4pt tall

**Header**
- "Add New Task" centered (SF Pro Display Bold, 20pt)
- Close button (X icon, 16pt, top right)

**Input Sections**
- Label style: SF Pro Text Semibold, 12pt, uppercase, Medium Gray
- Spacing between sections: 28pt

**Task Name Input**
- Background: Dark Gray 2
- Border: 2pt, transparent (Recovery Green when focused)
- Padding: 16pt
- Font: SF Pro Display Medium, 17pt
- Placeholder: Medium Gray
- Corner radius: 12pt

**Category Selector**
- Grid layout: 5 columns, equal width
- Button style:
  - Size: 60pt x 70pt
  - Background: Dark Gray 2 (selected: category color at 30% opacity)
  - Border: 2pt (selected: category color, unselected: transparent)
  - Corner radius: 12pt
  - Icon: 28pt emoji/SF Symbol
  - Label: 11pt, Medium Gray (selected: category color)

**Frequency Selector**
- Radio button style:
  - 20pt circle with 2pt stroke
  - Selected: Recovery Green fill with white center dot
  - Label: SF Pro Display Medium, 16pt
  - Spacing: 16pt between options
- Background: Dark Gray 2, 12pt radius, 16pt padding

**Create Button**
- Full width, 54pt height
- Background: Recovery Green (disabled: Medium Gray)
- Text: White, SF Pro Display Semibold, 17pt
- Corner radius: 12pt
- Shadow: (0, 4, 12, rgba(45,216,129,0.4))
- Animation: Scale 0.96 on press

---

### 3. History View (HistoryView)

#### Layout Changes
```
┌─────────────────────────────────┐
│ History          📊 Stats       │ ← Navigation
├─────────────────────────────────┤
│ TODAY                           │ ← Section header
│ ┌─────────────────────────────┐ │
│ │ ✓ Morning Workout      2:30p│ │
│ │   HEALTH                    │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ ✓ Team Meeting         10:00a│ │
│ │   WORK • 🔄              │ │
│ └─────────────────────────────┘ │
│                                 │
│ YESTERDAY                       │
│ ┌─────────────────────────────┐ │
│ │ ✓ Evening Run          6:45p│ │
│ │   HEALTH • 🔄              │ │
│ └─────────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

#### Component Details

**Navigation**
- Title: "History" (SF Pro Display Bold, 34pt, left-aligned)
- Right button: "📊 Stats" (Medium Gray, 16pt) - future feature placeholder

**Section Headers**
- Text: TODAY, YESTERDAY, or "JAN 23, 2026" (uppercase, SF Pro Text Bold, 13pt)
- Color: Medium Gray
- Background: Slight Dark Gray 1 tint
- Padding: 12pt horizontal, 8pt vertical
- Sticky headers

**History Card**
- Same style as task card
- Checkmark: Recovery Green, 24pt, filled circle with check
- Time badge:
  - Position: Top right
  - Text: "2:30p" format (SF Pro Text Medium, 14pt, Medium Gray)
  - No background (just text)
- Title: No strikethrough (always shows completed)
- Opacity: 100% (not dimmed)

**Empty State**
- Icon: Chart/trophy icon (80pt, Medium Gray)
- Title: "No Wins Yet" (SF Pro Display Bold, 24pt)
- Subtitle: "Complete tasks to build your history" (SF Pro Text, 16pt, Medium Gray)

---

### 4. Tab Bar

#### Redesign
```
┌─────────────────────────────────┐
│  ✓     Today         History   │
│  ━                              │ ← Active indicator
└─────────────────────────────────┘
```

- Background: Dark Gray 1 with blur effect
- Height: 60pt (safe area + 50pt)
- Border: 1pt top border, Dark Gray 2
- Shadow: (0, -2, 8, rgba(0,0,0,0.3))

**Tab Items**
- Icons: 24pt SF Symbols
  - Today: Checkmark.circle (Recovery Green when active)
  - History: Clock.arrow.circlepath (Recovery Green when active)
- Labels: 11pt, SF Pro Text Medium
  - Active: White
  - Inactive: Medium Gray
- Active indicator: 3pt line underneath (Recovery Green)
- Animation: Smooth transition, haptic feedback on switch

---

## 🔤 Typography System

### Font Family
- **Primary**: SF Pro Display (headings, titles, important text)
- **Secondary**: SF Pro Text (body, labels, descriptions)
- **Monospace**: SF Mono (stats, numbers, time)

### Type Scale
| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| **H1** | SF Pro Display | 34pt | Bold | Screen titles |
| **H2** | SF Pro Display | 28pt | Bold | Stats, numbers |
| **H3** | SF Pro Display | 20pt | Bold | Sheet headers |
| **H4** | SF Pro Display | 17pt | Medium | Task titles |
| **Body** | SF Pro Text | 16pt | Regular | Descriptions |
| **Label** | SF Pro Text | 12pt | Semibold | Section labels (uppercase) |
| **Caption** | SF Pro Text | 11pt | Medium | Badges, small text |
| **Time** | SF Mono | 14pt | Medium | Timestamps |

### Text Colors
- **Primary**: `#FFFFFF` (100% opacity)
- **Secondary**: `#808080` (Medium Gray)
- **Tertiary**: `#E0E0E0` (Light Gray)
- **Disabled**: `#FFFFFF` (30% opacity)

---

## 🎭 Logo Design - "Whoop Inspired"

### Logo Concept 1: "Daily Pulse" ⭐ RECOMMENDED
```
     ━━━━━✓━━━━━
     ▔▔▔▔▔▔▔▔▔▔▔
        DAILY
```
- **Icon**: Checkmark integrated into a performance graph/pulse line
- **Style**: Minimal line art, single color (Recovery Green)
- **Variations**:
  - **App Icon**: Green checkmark pulse on black background, rounded square
  - **Wordmark**: "DAILY" in SF Pro Display Black, 40pt, uppercase, below the pulse
  - **Monogram**: "D" with pulse line through it

**Rationale**: Clean, minimal, instantly recognizable. The pulse line evokes performance tracking like Whoop, while the checkmark clearly indicates task completion. Works perfectly at all sizes.

### Logo Concept 2: "Streak Flame"
```
        🔥
        ✓
      DAILY
```
- **Icon**: Flame icon above checkmark (representing streak/consistency)
- **Style**: Gradient from Strain Red (top) to Recovery Green (bottom)
- **Variations**:
  - **App Icon**: Gradient flame-check hybrid on black background
  - **Wordmark**: "DAILY" with subtitle "Build Your Streak"
  - **Icon only**: For small sizes (tab bar, etc.)

### Logo Concept 3: "Progress Ring"
```
      ◐◓
       ✓
     DAILY
```
- **Icon**: Circular progress ring (like Activity rings) with checkmark in center
- **Style**: Gradient ring (Performance Purple to Recovery Green), white checkmark
- **Variations**:
  - **App Icon**: Animated ring that fills throughout the day
  - **Wordmark**: "DAILY" in SF Pro Display
  - **Badge**: Mini version for notifications

---

## 🎨 Visual Design Elements

### Spacing System
- **4pt grid**: All spacing based on multiples of 4
- **Padding scale**: 8pt, 12pt, 16pt, 20pt, 24pt
- **Component spacing**: 8pt between related items, 16pt between sections

### Corner Radius
- **Cards**: 12pt
- **Buttons**: 12pt
- **Inputs**: 12pt
- **Badges**: Capsule (height/2)
- **Sheet**: 20pt (top only)

### Shadows & Depth
- **Level 1 (Cards)**: `0, 2, 8, rgba(0,0,0,0.2)`
- **Level 2 (FAB)**: `0, 6, 16, rgba(45,216,129,0.4)` (colored shadow)
- **Level 3 (Sheets)**: `0, 8, 24, rgba(0,0,0,0.4)`

### Animations
- **Duration**: 0.3s standard, 0.2s quick, 0.5s slow
- **Easing**: `easeInOut` standard, `spring` for interactive elements
- **Haptics**:
  - Light impact: Navigation
  - Medium impact: Task completion
  - Success: Task creation
  - Warning: Delete action

---

## 📐 Component Library

### Buttons
1. **Primary Button**: Recovery Green background, white text, 54pt height
2. **Secondary Button**: Dark Gray 2 background, white text, 54pt height
3. **Destructive Button**: Strain Red background, white text, 54pt height
4. **Ghost Button**: Transparent, colored text, 44pt height

### Cards
1. **Task Card**: Dark Gray 2, 12pt radius, 16pt padding, shadow level 1
2. **Stats Card**: Dark Gray 1, 16pt radius, 20pt padding, gradient background, shadow level 1
3. **Empty State Card**: Centered, no background, icon + text

### Inputs
1. **Text Field**: Dark Gray 2, 12pt radius, 16pt padding, 2pt border on focus
2. **Toggle**: Performance Purple when on, Dark Gray 2 when off
3. **Checkbox**: Circle, 24pt, 2pt stroke, Recovery Green when checked

### Badges
1. **Category Badge**: Capsule, category color at 20% opacity background, category color text
2. **Recurring Badge**: "🔄 DAILY" text, Performance Purple
3. **Time Badge**: Clock icon + time text, no background, Medium Gray

---

## 🔄 Interactions & Microanimations

### Task Completion
1. Tap checkbox → Scale bounce (0.8 → 1.1 → 1.0) over 0.3s
2. Checkmark draws in (stroke animation)
3. Haptic success feedback
4. Progress bar fills smoothly
5. Card fades out and slides left (0.5s delay)
6. Remaining cards slide up to fill gap

### Task Creation
1. FAB tap → Scale down + rotation
2. Sheet slides up from bottom (spring animation)
3. Input field auto-focus with keyboard
4. Create button scales on tap
5. Success haptic + sheet dismiss
6. New task card animates in from top

### Swipe Actions
1. Card translates horizontally with finger
2. Background color revealed (green left, red right)
3. Icon scales in at 30% swipe
4. Haptic at 50% swipe (commit point)
5. Full swipe executes action
6. Card animates out

---

## 📊 Additional Visual Enhancements

### Streak Counter (NEW FEATURE)
- Display in navigation bar: "🔥3" (flame + number)
- Increments with consecutive days of task completion
- Animation: Flame grows larger with longer streaks
- Reset logic: Breaks if no tasks completed for a day

### Progress Bar (NEW FEATURE)
- Shows completion percentage for the day
- Smooth fill animation
- Color gradient option for higher percentages
- Displayed in Daily Progress Card

---

## 🎯 Implementation Roadmap

### Phase 1: Foundation
1. Create `ColorPalette.swift` with Whoop theme colors
2. Create `Typography.swift` with text styles
3. Create `Spacing.swift` with spacing constants
4. Set up asset catalog with app icon
5. Design and export app icon (1024x1024) - "Daily Pulse" logo

### Phase 2: Component Library
1. Create reusable badge components (CategoryBadge, RecurringBadge)
2. Create custom button styles (Primary, Secondary, Destructive, Ghost)
3. Create custom card/container styles (TaskCard, StatsCard)
4. Create shadow ViewModifiers (Level 1, 2, 3)
5. Create animation helpers

### Phase 3: Screen Redesign
1. Redesign TaskRow with new card styling
2. Add Daily Progress Card to TaskListView
3. Add Streak Counter to navigation
4. Redesign AddTaskSheet with new UI
5. Redesign HistoryView and HistoryRow
6. Redesign TabBar with active indicator

### Phase 4: Polish
1. Add microanimations (checkbox bounce, card swipe, etc.)
2. Implement haptic feedback throughout
3. Test accessibility (VoiceOver, Dynamic Type, High Contrast)
4. Optimize performance
5. Dark mode refinement (test all colors)

### Phase 5: Testing & Iteration
1. Internal testing on multiple devices (iPhone SE, Pro, Pro Max)
2. Gather feedback
3. Refine colors/spacing based on real usage
4. A/B test specific elements if needed
5. Final polish

---

## 🔧 SwiftUI Implementation Notes

### Colors
```swift
// ColorPalette.swift
extension Color {
    static let brandBlack = Color(hex: "#0A0A0A")
    static let recoveryGreen = Color(hex: "#2DD881")
    static let strainRed = Color(hex: "#FF4444")
    static let performancePurple = Color(hex: "#7B61FF")
    static let darkGray1 = Color(hex: "#1A1A1A")
    static let darkGray2 = Color(hex: "#2A2A2A")
    static let mediumGray = Color(hex: "#808080")

    // Category colors
    static let workBlue = Color(hex: "#4A90E2")
    static let personalOrange = Color(hex: "#F5A623")
    static let healthGreen = Color(hex: "#2DD881")
    static let shoppingMagenta = Color(hex: "#BD10E0")
}
```

### Shadow Modifiers
```swift
// ShadowModifiers.swift
extension View {
    func shadowLevel1() -> some View {
        self.shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 2)
    }

    func shadowLevel2() -> some View {
        self.shadow(color: Color.recoveryGreen.opacity(0.4), radius: 16, x: 0, y: 6)
    }

    func shadowLevel3() -> some View {
        self.shadow(color: Color.black.opacity(0.4), radius: 24, x: 0, y: 8)
    }
}
```

### Spacing Constants
```swift
// Spacing.swift
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
}
```

---

## ✅ Accessibility Considerations

### Dynamic Type Support
- All text scales appropriately
- Minimum 11pt font size with scaling
- Test with largest accessibility sizes

### VoiceOver
- All interactive elements have clear labels
- Badge content is combined into single announcement
- Progress information announced clearly

### High Contrast Mode
- Borders added to cards in high contrast
- Text meets WCAG AA standards (4.5:1 minimum)
- Icons remain visible with increased contrast

### Reduced Motion
- Disable complex animations
- Use simple fades instead of scale/rotation
- Respect `UIAccessibility.isReduceMotionEnabled`

### Color Blindness
- Don't rely solely on color (use icons + text)
- Test with color blindness simulators
- Sufficient contrast between all color pairs

---

**Ready to implement!** This design will transform your app into a modern, performance-focused task tracker while maintaining all existing functionality.
