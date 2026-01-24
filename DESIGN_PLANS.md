# UI/UX Redesign Plans - Daily To-Do List App

## Current State Summary
- **Architecture**: SwiftUI with SwiftData
- **Screens**: 2 main tabs (Today, History)
- **Features**: Task creation, recurring tasks, categories, completion tracking
- **Current Design**: Minimal iOS native design with system colors and SF Symbols

---

# Design Plan A: "Whoop Inspired" - Athletic Performance Tracker

## 🎯 Design Philosophy
Clean, data-driven, performance-focused design inspired by Whoop's approach to tracking and habits. Emphasizes achievement, streaks, and daily consistency with bold minimalism.

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

**Daily Progress Card**
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
- Right button: "📊 Stats" (Medium Gray, 16pt) - future feature

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

## 🎭 Logo Design - Option A: "Whoop Inspired"

### Logo Concept 1: "Daily Pulse"
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

### Recommended: Concept 1 "Daily Pulse"
**Rationale**: Clean, minimal, instantly recognizable. The pulse line evokes performance tracking like Whoop, while the checkmark clearly indicates task completion. Works perfectly at all sizes.

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

## 📊 Additional Screens (Future Enhancements)

### Stats Dashboard
- Weekly completion rate chart
- Category breakdown pie chart
- Longest streak tracker
- Total completions counter
- Best days heatmap

### Settings
- Theme toggle (dark/light)
- Notification preferences
- Category customization
- Data export
- About/credits

---

## 🎯 Design System Implementation Notes

### SwiftUI Components Mapping
- Colors: Create `ColorPalette.swift` with static colors
- Typography: Create `Typography.swift` with text styles
- Spacing: Create `Spacing.swift` with constants
- Shadows: ViewModifiers for shadow levels
- Animations: Custom timing curves

### Assets Needed
- App icon (1024x1024)
- Tab bar icons (SF Symbols - already available)
- Empty state illustrations
- Loading states
- Success/error animations (optional Lottie)

### Accessibility
- Dynamic Type support (all text scales)
- VoiceOver labels on all interactive elements
- High contrast mode adjustments
- Reduced motion alternatives for animations
- Minimum 44pt touch targets

---

# Design Plan B: "Notebook Inspired" - Analog Warmth Meets Digital

## 🎯 Design Philosophy
Bring the tactile, comforting experience of a physical notebook into the digital realm. Warm paper textures, handwritten accents, and skeuomorphic details create a familiar, approachable interface that feels personal and organic.

## 🎨 Color Scheme

### Primary Colors
- **Paper Cream**: `#FFF8E7` (Warm off-white background, like aged paper)
- **Ink Black**: `#2C2416` (Deep brown-black for text, like fountain pen ink)
- **Leather Brown**: `#8B6F47` (Accents, borders, notebook binding)
- **Red Pen**: `#D32F2F` (Highlights, important tasks, errors)
- **Blue Pen**: `#1976D2` (Links, recurring tasks, secondary actions)

### Supporting Colors
- **Ruled Lines**: `#E8DCC8` (Subtle notebook lines)
- **Margin Red**: `#FFC9C9` (Faint red margin line)
- **Highlight Yellow**: `#FFF59D` (Text highlighting, like marker)
- **Green Checkmark**: `#43A047` (Completion, success)
- **Pencil Gray**: `#757575` (Secondary text, notes)

### Category Colors (Muted, Pen-like)
- **Work**: `#1976D2` (Blue ink)
- **Personal**: `#F57C00` (Orange highlighter)
- **Health**: `#43A047` (Green pen)
- **Shopping**: `#8E24AA` (Purple ink)
- **Other**: `#757575` (Pencil gray)

### Texture & Patterns
- **Paper Grain**: Subtle noise texture overlay (5% opacity)
- **Coffee Stains**: Random subtle brown circles on empty states (3% opacity)
- **Torn Edge**: Rough edge effect on cards (ripped paper look)
- **Spiral Binding**: Left edge has hole punches or spiral visual

### Theme Support
- **Light Mode**: Primary (default experience with paper texture)
- **Dark Mode**: "Night Notebook" - dark brown background (`#3E2723`), cream text, softer textures

---

## 📱 Screen-by-Screen Redesign

### 1. Today's Task View (TaskListView)

#### Layout Changes
```
┌─────────────────────────────────┐
│  ●●●  Today's Tasks  Jan 24    │ ← Binding holes + title
│                                 │
│  ┌──────────────────────────┐  │
│  │ Tasks Done: 4/8          │  │ ← Header card
│  │ ████████░░░░░░░░          │  │
│  └──────────────────────────┘  │
│                                 │
│  Morning Routine                │ ← Section header (handwritten style)
│  ─────────────────────────────  │ ← Ruled line
│                                 │
│  ☐ Morning Workout              │ ← Task item
│     💚 Health                    │
│  ─────────────────────────────  │
│                                 │
│  ☑ Team Meeting                 │ ← Completed
│     💼 Work • Daily 🔄          │
│  ─────────────────────────────  │
│                                 │
│                      [✎]        │ ← Floating pen button
└─────────────────────────────────┘
```

#### Component Details

**Background**
- Base color: Paper Cream (`#FFF8E7`)
- Texture: Paper grain noise overlay (subtle, 5% opacity)
- Margin line: Vertical red line 40pt from left edge (Margin Red, 1pt, dashed)
- Ruled lines: Horizontal lines every task row (Ruled Lines color)

**Header/Title Area**
- Background: Slightly darker Paper Cream with shadow (torn paper effect)
- Left: 3 binding holes (dark brown circles, 8pt diameter, 12pt apart)
- Title: "Today's Tasks" in handwritten font (Bradley Hand / Chalkduster, 24pt, Ink Black)
- Date: "Jan 24" (SF Pro Text, 16pt, Pencil Gray, right-aligned)
- Height: 70pt
- Shadow: Subtle bottom shadow like paper lifting

**Progress Card**
- Style: Index card on notebook
- Background: Slightly lighter cream with subtle shadow
- Border: Dashed line (Leather Brown, 1pt, dashed)
- Corner: Slightly curled corner (bottom right)
- Padding: 16pt
- Content:
  - "Tasks Done: 4/8" (handwritten font, 18pt, Ink Black)
  - Progress bar: Hand-drawn style (rough edges), Green Checkmark fill, Ruled Lines background
  - Height: 8pt with slight irregularity
- Position: Pinned look with shadow underneath

**Task Item**
- No card background (directly on notebook paper)
- Ruled line above and below (Ruled Lines color, 1pt)
- Padding: 12pt vertical, 16pt horizontal
- Layout:
  ```
  ☐ Task Title
     Badge  Badge
  ─────────────────
  ```

**Checkbox**
- Style: Hand-drawn square (20pt, slight rotation/imperfection)
- Unchecked: Ink Black stroke (2pt), empty
- Checked: Green Checkmark inside, filled
- Animation: Hand-drawn checkmark animates in (stroke draws)

**Task Title**
- Font: SF Pro Display (readable, but can use marker-style for special tasks)
- Size: 17pt
- Color: Ink Black
- Completed: Ink Black with hand-drawn strikethrough (Red Pen color, 2pt, slightly wavy)
- Spacing: 12pt from checkbox

**Badges**
- Style: Handwritten tags on washi tape
- Background: Category color at 40% opacity, torn edge effect
- Border: None
- Text: Category name in script font (11pt)
- Icon: Small emoji or hand-drawn icon (14pt)
- Padding: 6pt horizontal, 3pt vertical
- Spacing: 6pt between badges

**Recurring Badge**
- Text: "Daily 🔄" in Blue Pen color
- Background: Light blue washi tape effect (torn edges)
- Font: Script/casual style

**Section Headers** (if grouping by time of day)
- Text: "Morning Routine", "Afternoon Tasks" (handwritten font, 16pt, Pencil Gray)
- Underline: Hand-drawn wavy line (Leather Brown, 1.5pt)
- Spacing: 24pt above, 12pt below

**Empty State**
- Icon: Empty notebook page illustration (line art, 100pt)
- Title: "A Fresh Page Awaits" (handwritten font, 28pt, Ink Black)
- Subtitle: "Grab your pen and jot down your first task" (SF Pro Text, 16pt, Pencil Gray)
- Background: Subtle coffee ring stain (3% opacity, brown circle)

**Floating Action Button (Pen Button)**
- Position: Bottom right, 24pt from edges
- Size: 64pt diameter
- Style: Realistic pen icon (not flat - 3D rendered pen lying on notebook)
- Color: Blue Pen barrel with silver tip
- Shadow: Paper-on-paper shadow (0, 4, 8, rgba(0,0,0,0.15))
- Animation: Pen rolls slightly on tap, ink dot appears

---

### 2. Add Task Sheet (AddTaskSheet)

#### Layout Changes
```
┌─────────────────────────────────┐
│     ─ New Task ─           ✕   │ ← Torn paper edge
├─────────────────────────────────┤
│                                 │
│ What's on your mind?            │ ← Prompt
│ ┌─────────────────────────────┐ │
│ │ _________________________  │ │ ← Lined paper input
│ │ _________________________  │ │
│ └─────────────────────────────┘ │
│                                 │
│ Tag it:                         │
│ [💼] [🏠] [💚] [🛒] [⚪]        │ ← Washi tape buttons
│ Work  Pers  Hlth  Shop  Other   │
│                                 │
│ How often?                      │
│ ○ One-time task                 │ ← Radio circles
│ ● Every day (recurring)         │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  ✓ Add to Today's List     │ │ ← Button (sticky note style)
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

#### Component Details

**Sheet Presentation**
- Style: Sheet that looks like a torn notebook page
- Background: Paper Cream with grain texture
- Top edge: Torn/ripped paper effect (irregular edge)
- Corner radius: 0 (sharp corners, like real paper)
- Shadow: Deep shadow underneath like floating paper (0, 8, 20, rgba(0,0,0,0.2))

**Header**
- Text: "New Task" (handwritten font, 22pt, Ink Black)
- Underline: Hand-drawn double line (Ink Black, 1pt each)
- Close button: Hand-drawn X (Ink Black, top right)
- Decoration: Small doodle corner (optional - star, heart, etc.)

**Prompt Text**
- "What's on your mind?" (handwritten font, 14pt, Pencil Gray, casual)
- Position: Above input field

**Task Name Input**
- Style: Lined paper (3 horizontal lines)
- Line color: Ruled Lines
- Line spacing: 28pt between lines
- Text: Handwritten font or SF Pro Display (17pt, Ink Black)
- Cursor: Pencil Gray blinking line
- Background: Transparent (shows paper)
- Padding: 12pt horizontal

**Category Selector**
- Label: "Tag it:" (handwritten font, 14pt, Pencil Gray)
- Style: Washi tape strips (colored rectangles with torn edges)
- Layout: Horizontal scroll or wrap
- Button:
  - Size: 60pt x 50pt
  - Background: Category color at 60% opacity with texture
  - Icon: 24pt emoji on tape
  - Label: 10pt below tape (handwritten font)
  - Selected: Tape has shadow + slightly lifted (0, 2, 4)
  - Unselected: Flat on paper
- Top edge: Torn/irregular (SVG path)
- Spacing: 8pt between tapes

**Frequency Selector**
- Label: "How often?" (handwritten font, 14pt, Pencil Gray)
- Style: Hand-drawn radio circles (20pt, Ink Black stroke 2pt)
- Selected: Filled circle inside (Blue Pen)
- Labels: SF Pro Text, 16pt, Ink Black
- Spacing: 16pt between options
- Background: None (on paper)

**Add Button**
- Style: Sticky note (yellow Highlight Yellow background)
- Size: Full width minus 32pt margin, 60pt height
- Background: Gradient yellow with texture
- Border: None
- Text: "✓ Add to Today's List" (handwritten font, 18pt, Ink Black)
- Shadow: Sticky note shadow (0, 3, 6, rgba(0,0,0,0.1))
- Top edge: Slightly peeling effect (subtle 3D curl)
- Animation: Sticky note lifts on press (increase shadow, slight translate up)

**Overall Decorations**
- Small doodles in corners (stars, hearts, checkmarks - 8pt, Pencil Gray, 20% opacity)
- Slight rotation on whole sheet (0.5 degrees) for organic feel

---

### 3. History View (HistoryView)

#### Layout Changes
```
┌─────────────────────────────────┐
│  ●●●  Completed Tasks           │ ← Binding + title
│      ─────────────────          │
│                                 │
│  ╔═══════════════════════════╗  │ ← Flip calendar style
│  ║  Today - Jan 24           ║  │
│  ╚═══════════════════════════╝  │
│                                 │
│  ─────────────────────────────  │
│  ☑ Morning Workout       2:30p  │ ← Completed task
│     💚 Health                    │
│  ─────────────────────────────  │
│  ☑ Team Meeting         10:00a  │
│     💼 Work • Daily 🔄          │
│  ─────────────────────────────  │
│                                 │
│  ╔═══════════════════════════╗  │
│  ║  Yesterday - Jan 23       ║  │
│  ╚═══════════════════════════╝  │
│                                 │
│  ─────────────────────────────  │
│  ☑ Evening Run           6:45p  │
│  ─────────────────────────────  │
└─────────────────────────────────┘
```

#### Component Details

**Background**
- Same notebook paper as Today view
- Ruled lines throughout
- Margin line on left

**Header**
- Title: "Completed Tasks" (handwritten font, 24pt, Ink Black)
- Subtitle: "Your achievements" (script font, 12pt, Pencil Gray, italic)
- Binding holes on left

**Date Section Headers**
- Style: Flip calendar page
- Background: White with subtle shadow
- Border: Leather Brown, 2pt, rounded corners (8pt)
- Text: "Today - Jan 24" (SF Pro Display Semibold, 16pt, Ink Black)
- Spiral binding visual: Small circles at top (Dark brown, 6pt)
- Shadow: (0, 2, 6, rgba(0,0,0,0.15))
- Spacing: 20pt above, 12pt below

**History Task Item**
- Same as Today view task, but always checked
- Checkmark: Always Green Checkmark filled
- No strikethrough (completed is normal state here)
- Time badge:
  - Style: Handwritten circle around time (Pencil Gray, 1pt stroke)
  - Text: "2:30p" (SF Mono, 13pt, Pencil Gray)
  - Position: Right-aligned
  - Background: Slight yellow highlight oval (3% opacity)

**Completed Task Styling**
- Normal opacity (not faded)
- Green checkmark with hand-drawn style
- Badges same as Today view

**Empty State**
- Icon: Empty archive box (line drawing, 100pt, Pencil Gray)
- Title: "Nothing Yet!" (handwritten font, 28pt, Ink Black)
- Subtitle: "Completed tasks will appear here like memories" (SF Pro Text, 16pt, Pencil Gray, centered)
- Decoration: Small vintage stamp in corner (optional)

**Pull-to-Refresh**
- Spinner: Rotating pen icon (Blue Pen color)
- Text: "Refreshing..." (handwritten font, 14pt)

---

### 4. Tab Bar

#### Redesign
```
┌─────────────────────────────────┐
│  ◀  [Today]      [History]  ▶  │ ← Bookmark tabs
└─────────────────────────────────┘
```

- Style: Bookmark/tab dividers in notebook
- Background: Darker Paper Cream with texture
- Height: 65pt (includes safe area)
- Border top: Leather Brown, 2pt, stitching pattern (dashed)

**Tab Items**
- Style: Bookmark tabs sticking up from notebook
- Shape: Rounded top rectangle (tab shape)
- Active tab:
  - Background: Paper Cream (matches page)
  - Height: 55pt (extends above bar)
  - Shadow: Paper on paper
  - Text: Ink Black, handwritten font, 15pt
- Inactive tab:
  - Background: Darker cream (Leather Brown at 30%)
  - Height: 45pt
  - Text: Pencil Gray, handwritten font, 15pt
- Icons: Hand-drawn style SF Symbols (18pt)
  - Today: Checkmark in circle
  - History: Clock with circular arrow
- Spacing: 8pt between tabs
- Animation: Tab lifts up when becoming active (spring)

**Decorative Elements**
- Stitch marks along top border (Leather Brown dots, 2pt, 8pt apart)
- Slight paper texture on tabs

---

## 🔤 Typography System

### Font Families
- **Handwritten Headers**: Bradley Hand / Chalkduster / Noteworthy (iOS system)
- **Body/Readable**: SF Pro Display and SF Pro Text
- **Script/Casual**: Snell Roundhand / Marker Felt (special accents)
- **Monospace**: SF Mono (times, numbers)

### Type Scale
| Style | Font | Size | Weight | Usage |
|-------|------|------|--------|-------|
| **H1 Handwritten** | Bradley Hand | 28pt | Regular | Main titles |
| **H2 Handwritten** | Bradley Hand | 22pt | Regular | Sheet titles |
| **H3 Handwritten** | Bradley Hand | 18pt | Regular | Section headers |
| **H4** | SF Pro Display | 17pt | Medium | Task titles |
| **Body** | SF Pro Text | 16pt | Regular | Descriptions |
| **Script** | Marker Felt | 16pt | Thin | Special labels |
| **Label Handwritten** | Bradley Hand | 14pt | Regular | Prompts, hints |
| **Caption** | SF Pro Text | 11pt | Regular | Small text, badges |
| **Time** | SF Mono | 13pt | Regular | Timestamps |

### Text Colors
- **Primary (Ink)**: `#2C2416` (Ink Black)
- **Secondary (Pencil)**: `#757575` (Pencil Gray)
- **Accent (Blue Pen)**: `#1976D2`
- **Accent (Red Pen)**: `#D32F2F`
- **Success (Green)**: `#43A047`

---

## 🎭 Logo Design - Option B: "Notebook Inspired"

### Logo Concept 1: "Daily Notebook"
```
   ┌─────────┐
   │ ● ● ●   │
   │ ✓ Daily │
   │─────────│
   └─────────┘
```
- **Icon**: Spiral notebook with checkmark on cover
- **Style**: Skeuomorphic, leather-bound notebook
- **Colors**: Leather Brown cover, Paper Cream pages, Green checkmark
- **Variations**:
  - **App Icon**: 3D notebook at slight angle, spiral on left, embossed "✓"
  - **Wordmark**: "Daily" in embossed lettering on notebook cover
  - **Flat version**: Simplified notebook outline for small sizes

### Logo Concept 2: "Pen & Check"
```
      ✓
     /
    /═══ Pen
   Daily
```
- **Icon**: Fountain pen drawing a checkmark
- **Style**: Hand-drawn illustration style
- **Colors**: Blue Pen barrel, Ink Black tip, Green checkmark stroke
- **Variations**:
  - **App Icon**: Close-up of pen nib with checkmark ink stroke
  - **Wordmark**: "Daily" in handwritten font below pen
  - **Animated**: Pen draws checkmark on app launch

### Logo Concept 3: "Sticky Note Stack"
```
   ┌─────┐
   │  ✓  │
  ┌┴────┐│
  │  ✓  ││
 ┌┴────┐││
 │Daily│┘│
 └─────┘ ┘
```
- **Icon**: Stack of sticky notes with checkmarks
- **Style**: Colorful, playful, slightly overlapped
- **Colors**: Highlight Yellow, green, blue, pink sticky notes
- **Variations**:
  - **App Icon**: 3 sticky notes stacked, slight rotation, top one has "✓"
  - **Wordmark**: "Daily" handwritten on bottom sticky note
  - **Icon only**: Single sticky note with checkmark for small sizes

### Recommended: Concept 1 "Daily Notebook"
**Rationale**: Perfectly aligns with the notebook theme. Familiar, warm, approachable. The 3D notebook instantly communicates organization and daily tracking. Works well at all sizes and is unique in the productivity app space.

---

## 🎨 Visual Design Elements

### Spacing System
- **4pt grid**: All spacing based on multiples of 4
- **Organic variance**: ±2pt randomness on some elements for hand-drawn feel
- **Padding scale**: 8pt, 12pt, 16pt, 20pt, 24pt

### Corner Radius
- **Cards/Buttons**: 8pt (softer than Whoop, more organic)
- **Sticky notes**: 2pt (slight rounding)
- **Washi tape**: 4pt
- **Notebook pages**: 0pt (sharp corners)
- **Badges**: Capsule with torn edges (irregular)

### Shadows & Depth
- **Paper on notebook**: `0, 2, 6, rgba(44,36,22,0.15)` (warm shadow)
- **Floating paper**: `0, 4, 12, rgba(44,36,22,0.2)`
- **Sticky note**: `0, 3, 8, rgba(44,36,22,0.1)` (softer)
- **Depth illusion**: Slight shadows even in flat design to mimic paper layers

### Textures & Patterns
- **Paper grain**: SVG noise texture overlay (5% opacity, brown tint)
- **Ruled lines**: Repeating horizontal lines (1pt, `#E8DCC8`)
- **Margin line**: Vertical dashed line (1pt, `#FFC9C9`)
- **Torn edges**: SVG irregular paths for paper tear effect
- **Coffee stains**: Circular gradient spots (3% opacity, brown)
- **Ink bleed**: Slight blur/spread on checkmarks (1pt)

### Animations
- **Duration**: 0.4s standard (slightly slower than Whoop for organic feel)
- **Easing**: `easeInOut` and custom bounces for spring-like effects
- **Hand-drawn reveals**: Stroke animations for checkmarks, lines (0.6s)
- **Haptics**:
  - Light: Page turn
  - Medium: Checkbox
  - Success: Task completion
  - No haptic for soft interactions (respects analog feel)

### Hand-Drawn Effects
- **Checkmark**: SVG path with slight irregularity, animates with stroke
- **Lines**: Slightly wavy, not perfectly straight (0.5pt deviation)
- **Shapes**: Circles/squares with subtle wobble/rotation
- **Strikethrough**: Wavy line, not perfectly horizontal (2-3 degree variance)

---

## 📐 Component Library

### Buttons
1. **Primary (Sticky Note)**: Highlight Yellow, handwritten text, 60pt height, shadow lift
2. **Secondary (Washi Tape)**: Category color, torn edges, 50pt height
3. **Destructive (Red Pen Mark)**: Red Pen text, circled, 50pt height
4. **Ghost (Pencil)**: Transparent, Pencil Gray text, underline on press

### Cards
1. **Index Card**: Lighter cream, dashed border, slight corner curl, shadow
2. **Sticky Note**: Yellow, small, shadow, top edge curl
3. **Notebook Page**: Transparent, ruled lines, no border
4. **Calendar Page**: White, border, spiral holes, shadow

### Inputs
1. **Lined Text Field**: Transparent with ruled lines, handwritten cursor
2. **Checkbox**: Hand-drawn square, stroke animation on check
3. **Radio**: Hand-drawn circle, filled circle inside when selected

### Badges
1. **Category Badge**: Washi tape style, torn edges, category color background (40%)
2. **Recurring Badge**: Blue tape, "Daily 🔄" text
3. **Time Badge**: Handwritten circle around time text

### Decorative Elements
1. **Binding Holes**: Dark brown circles (8pt) on left edge, 12pt apart
2. **Margin Line**: Red dashed vertical line 40pt from left
3. **Ruled Lines**: Horizontal lines across page (Ruled Lines color)
4. **Coffee Stain**: Circular gradient (brown, 3% opacity, random placement)
5. **Doodles**: Small stars, hearts, arrows in corners (Pencil Gray, 20% opacity)
6. **Torn Edge**: SVG irregular path for ripped paper effect
7. **Spiral Binding**: Top edge of sheets, small circles (6pt) every 20pt

---

## 🔄 Interactions & Microanimations

### Task Completion
1. Tap checkbox → Hand-drawn checkmark animates in (stroke draws, 0.6s)
2. Green ink fills checkbox square
3. Haptic medium feedback
4. Task title gets red pen strikethrough (wavy line draws across, 0.4s)
5. Slight fade to 70% opacity
6. Task stays visible (doesn't remove immediately - more natural)

### Task Creation
1. Pen button tap → Pen rolls slightly, ink dot appears
2. Torn paper sheet slides up from bottom (0.5s ease-out)
3. Input field auto-focus, handwritten cursor blinks
4. Sticky note button lifts on tap (shadow increases, 2pt translate up)
5. Success: Sticky note crumples slightly, sheet tears down (0.4s)
6. New task appears with ink fade-in effect (0.5s)

### Swipe Actions
1. Task row translates with finger
2. Ruled line stretches/compresses (organic effect)
3. Background: Left = Green checkmark appears, Right = Red X appears
4. Haptic at 50% swipe
5. Full swipe: Task gets checked or deleted with pen strike-through
6. Row animates out with paper crumple effect

### Page Navigation
1. Tab switch: Bookmark tab lifts up (spring animation, 0.4s)
2. Content: Page turn effect (optional - 3D flip, or simple cross-fade)
3. Haptic light feedback
4. New page fades in with subtle slide

---

## 📊 Additional Screens (Future Enhancements)

### Monthly View
- Calendar grid on notebook page
- Dots on days with completed tasks (green ink dots)
- Hand-drawn month header

### Task Details/Edit
- Full page with task title at top
- Editable fields on ruled lines
- Notes section (handwritten font)
- Delete button (red pen circle with X)

### Settings
- Notebook cover page design
- Toggle for handwritten fonts vs. readable fonts
- Paper texture intensity slider
- Dark mode: "Night Notebook" toggle
- Export as PDF (looks like scanned notebook pages)

---

## 🎯 Design System Implementation Notes

### SwiftUI Components Mapping
- Colors: `ColorPalette.swift` with notebook theme colors
- Typography: `Typography.swift` with handwritten + readable styles
- Textures: `TextureOverlay` ViewModifier for paper grain
- Shapes: Custom `TornEdge`, `HandDrawnRectangle`, `WashiTape` shapes
- Animations: Custom timing curves for organic feel

### Assets Needed
- **App Icon**: 3D rendered notebook (1024x1024)
- **Textures**:
  - Paper grain PNG (tileable, 512x512)
  - Ruled line pattern PNG
  - Coffee stain PNGs (various sizes)
- **SVG Shapes**:
  - Torn edge paths (top, bottom, left, right)
  - Hand-drawn checkbox
  - Hand-drawn checkmark
  - Wavy strikethrough line
- **Fonts**: Bradley Hand, Marker Felt (system fonts - no import needed)
- **Decorative**: Doodle SVGs (stars, hearts, arrows)

### Accessibility
- **Dynamic Type**: Support for larger text (careful with handwritten fonts - fallback to SF Pro)
- **VoiceOver**: All decorative elements hidden, clear labels on interactive elements
- **Reduce Motion**: Disable paper animations, use simple fades
- **High Contrast**: Option to disable textures and use solid colors
- **Minimum Touch Targets**: 44pt (even with hand-drawn shapes)
- **Alternative**: "Simple Mode" toggle to switch to cleaner, less textured design

### Performance Considerations
- **Texture Optimization**: Use small, tileable textures (not full-screen images)
- **SVG vs. PNG**: Use SVG for shapes when possible (scalable, smaller file size)
- **Animation**: Limit simultaneous animations, use `.drawingGroup()` for complex shapes
- **Dark Mode Assets**: Separate darker textures for Night Notebook theme

---

## 🆚 Comparison: Whoop vs. Notebook

| Aspect | Whoop Inspired | Notebook Inspired |
|--------|----------------|-------------------|
| **Mood** | Modern, focused, performative | Warm, personal, reflective |
| **Colors** | Dark, high contrast, bold accents | Light, warm, muted earth tones |
| **Typography** | Clean sans-serif, bold weights | Handwritten + readable hybrid |
| **Interactions** | Fast, precise, data-driven | Organic, tactile, forgiving |
| **Target User** | Achievement-oriented, tech-savvy | Creatives, journalers, casual users |
| **Complexity** | Moderate (stats, graphs) | Simple (familiar metaphor) |
| **Differentiation** | Unique in to-do space | Very unique, nostalgic appeal |
| **Implementation** | Easier (standard UI patterns) | Harder (custom textures, shapes) |
| **Scalability** | Easier to add features | Harder (must maintain metaphor) |
| **Accessibility** | Better (high contrast) | Moderate (texture can hinder) |

---

## ✅ Recommended Next Steps (After Decision)

### Phase 1: Foundation
1. Create `ColorPalette.swift` with chosen theme colors
2. Create `Typography.swift` with text styles
3. Create `Spacing.swift` with spacing constants
4. Set up asset catalog with required images/textures
5. Design and export app icon (1024x1024)

### Phase 2: Component Library
1. Create reusable badge components
2. Create custom button styles
3. Create custom card/container styles
4. Create shadow ViewModifiers
5. Create animation helpers

### Phase 3: Screen Redesign
1. Redesign TaskRow with new styling
2. Redesign TaskListView with new layout
3. Redesign AddTaskSheet with new UI
4. Redesign HistoryView and HistoryRow
5. Redesign TabBar

### Phase 4: Polish
1. Add microanimations
2. Implement haptic feedback
3. Test accessibility
4. Optimize performance
5. Dark mode refinement

### Phase 5: Testing & Iteration
1. Internal testing on multiple devices
2. Gather feedback
3. Refine colors/spacing
4. A/B test specific elements
5. Final polish

---

**Ready for your decision!** Both designs maintain your app's structure while offering distinctly different user experiences. Choose based on your target audience and brand personality.

**Whoop = Modern achiever | Notebook = Thoughtful planner**
