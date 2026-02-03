# Task Recurrence Customization - Implementation Plan

## Overview

Add custom recurrence options to tasks and enable task editing after creation.

### User Requirements
1. **Weekly recurrence** = Select specific days of the week (e.g., Mon, Wed, Fri means task appears 3 times per week)
2. **Monthly recurrence** = Select specific dates (1st, 15th, etc.)
3. **No end dates** for now
4. **Edit tasks** by tapping the task row

---

## Features

### 1. Custom Recurrence Patterns
- **One Time**: Task disappears after completion (existing)
- **Daily**: Task reappears every day (existing)
- **Weekly**: Task reappears on selected weekdays (e.g., Mon, Wed, Fri)
- **Monthly**: Task reappears on selected dates (e.g., 1st, 15th)

### 2. Task Editing
- Tap any task row to open edit sheet
- Edit title, category, and recurrence settings
- Save or cancel changes

---

## Implementation Phases

### Phase 1: Data Model Extension [COMPLETED]

**File**: `Shared/Models/TodoTask.swift`

New properties added to TodoTask:
```swift
// New enum for recurrence types
enum RecurrenceType: String, Codable, CaseIterable {
    case none, daily, weekly, monthly
}

// New stored properties (strings for SwiftData)
var recurrenceTypeRaw: String?
var selectedWeekdaysRaw: String?      // "2,4,6" = Mon, Wed, Fri
var selectedMonthDaysRaw: String?     // "1,15" = 1st and 15th

// Computed properties
var recurrenceType: RecurrenceType    // Get/set recurrence type
var selectedWeekdays: [Int]           // 1=Sun, 2=Mon, ..., 7=Sat
var selectedMonthDays: [Int]          // 1-31

// Helper methods
func shouldShowToday() -> Bool        // Check if task appears today
var recurrenceDisplayString: String   // "MON, WED, FRI" for badges
```

---

### Phase 2: RecurrenceSelector Component [COMPLETED]

**File**: `dailytodolist/Components/RecurrenceSelector.swift` (NEW)

Create a new recurrence selection UI:

```
+------------------------------------------+
|  FREQUENCY                               |
|  +--------------------------------------+|
|  | ( ) One Time                         ||
|  |     Task disappears after completion ||
|  +--------------------------------------+|
|  | ( ) Daily            [repeat icon]   ||
|  |     Task reappears every day         ||
|  +--------------------------------------+|
|  | (o) Weekly           [repeat icon]   ||
|  |     Task reappears on selected days  ||
|  +--------------------------------------+|
|  | ( ) Monthly          [repeat icon]   ||
|  |     Task reappears on selected dates ||
|  +--------------------------------------+|
+------------------------------------------+

(If Weekly selected, show day picker):
+------------------------------------------+
|  SELECT DAYS                             |
|  [S] [M] [T] [W] [T] [F] [S]            |
|   o   *   o   *   o   *   o             |
+------------------------------------------+

(If Monthly selected, show date grid):
+------------------------------------------+
|  SELECT DATES                            |
|  [ 1] [ 2] [ 3] [ 4] [ 5] [ 6] [ 7]     |
|  [ 8] [ 9] [10] [11] [12] [13] [14]     |
|  [15] [16] [17] [18] [19] [20] [21]     |
|  [22] [23] [24] [25] [26] [27] [28]     |
|  [29] [30] [31]                          |
+------------------------------------------+
```

---

### Phase 3: Update AddTaskSheet [COMPLETED]

**File**: `dailytodolist/Views/AddTaskSheet.swift`

Changes:
1. Replace `@State private var isRecurring: Bool` with:
   - `@State private var recurrenceType: RecurrenceType = .none`
   - `@State private var selectedWeekdays: [Int] = []`
   - `@State private var selectedMonthDays: [Int] = []`

2. Replace `FrequencySelector` with new `RecurrenceSelector`

3. Update `saveTask()` to pass recurrence settings to TaskService

---

### Phase 4: Create EditTaskSheet [COMPLETED]

**File**: `dailytodolist/Views/EditTaskSheet.swift` (NEW)

Similar to AddTaskSheet but:
- Takes existing task as parameter
- Pre-fills all fields with current values
- Has "Save Changes" button instead of "Create"
- Updates existing task instead of creating new

---

### Phase 5: Update TaskRow for Edit Navigation [COMPLETED]

**Files**:
- `dailytodolist/Views/TaskRow.swift`
- `dailytodolist/Components/ReorderableTaskList.swift`
- `dailytodolist/Views/TaskListView.swift`

Changes:
1. Add `onEdit` callback to TaskRow
2. Make entire row tappable (except checkbox)
3. ReorderableTaskList passes edit callback to TaskRow
4. TaskListView presents EditTaskSheet when task is tapped

---

### Phase 6: Update TaskService [COMPLETED]

**File**: `dailytodolist/Services/TaskService.swift`

Changes:
1. Update `createTask()` to accept recurrence parameters
2. Add `updateTask()` method for editing
3. Update filtering in `fetchTodayTasks()` to use `shouldShowToday()`

---

### Phase 7: Update RecurringBadge [COMPLETED]

**File**: `dailytodolist/Components/Badges.swift`

Update RecurringBadge to show pattern:
- "DAILY" for daily tasks
- "MON, WED, FRI" for weekly tasks
- "1ST, 15TH" for monthly tasks

---

## File Changes Summary

| File | Action | Status |
|------|--------|--------|
| `Shared/Models/TodoTask.swift` | MODIFY | DONE |
| `dailytodolist/Components/RecurrenceSelector.swift` | CREATE | DONE |
| `dailytodolist/Views/AddTaskSheet.swift` | MODIFY | DONE |
| `dailytodolist/Views/EditTaskSheet.swift` | CREATE | DONE |
| `dailytodolist/Views/TaskRow.swift` | MODIFY | DONE |
| `dailytodolist/Components/ReorderableTaskList.swift` | MODIFY | DONE |
| `dailytodolist/Views/TaskListView.swift` | MODIFY | DONE |
| `dailytodolist/Services/TaskService.swift` | MODIFY | DONE |
| `dailytodolist/Components/Badges.swift` | MODIFY | DONE |
| `dailytodolist/Views/HistoryRow.swift` | MODIFY | DONE |

---

## UI/UX Design Details

### Weekday Selector
- 7 circular buttons: S M T W T F S
- Unselected: dark gray background, medium gray text
- Selected: green background (recoveryGreen), white text
- Tap to toggle selection

### Month Day Selector
- 7x5 grid of circular buttons (1-31)
- Same styling as weekday selector
- Last row only shows 29, 30, 31

### Recurrence Type Options
- Radio button style (existing FrequencyOption design)
- Show/hide day/date selector based on type

### Edit Task Sheet
- Same layout as AddTaskSheet
- Title: "Edit Task" instead of "Add New Task"
- Button: "Save Changes" instead of "Create Task"
- Pre-fill all fields with current values

---

## Validation Rules

1. **Weekly**: At least one weekday must be selected
2. **Monthly**: At least one date must be selected
3. **Title**: Cannot be empty (existing rule)
4. **Category**: Optional (existing rule)

---

## Backward Compatibility

- Existing `isRecurring: Bool` field is kept and synced
- Old daily recurring tasks continue to work
- Widget code remains compatible
- Tasks without recurrenceTypeRaw default to `isRecurring ? .daily : .none`

---

## Testing Checklist

### Recurrence Creation
- [ ] Create one-time task
- [ ] Create daily recurring task
- [ ] Create weekly task with Mon, Wed, Fri
- [ ] Create monthly task with 1st and 15th

### Task Display
- [ ] One-time tasks show no badge
- [ ] Daily tasks show "DAILY" badge
- [ ] Weekly tasks show "MON, WED, FRI" badge
- [ ] Monthly tasks show "1ST, 15TH" badge

### Task Filtering
- [ ] Weekly tasks only appear on selected days
- [ ] Monthly tasks only appear on selected dates
- [ ] Test by changing device date

### Task Editing
- [ ] Tap task row opens edit sheet
- [ ] All fields pre-filled correctly
- [ ] Can change title, category, recurrence
- [ ] Save persists changes
- [ ] Cancel discards changes

### Backward Compatibility
- [ ] Existing daily recurring tasks still work
- [ ] Existing one-time tasks still work
