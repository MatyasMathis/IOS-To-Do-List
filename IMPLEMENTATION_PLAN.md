# Implementation Plan: Daily To-Do List App with Recurring Tasks

## Overview
This implementation plan breaks down the development into **5 testable phases**. After each phase, the app will be runnable in the iOS Simulator with working features.

**IMPORTANT**: After completing each phase, **all new functions must be well-documented** with clear comments explaining:
- What the function does
- Why it exists
- How it works
- Any important edge cases

This ensures developers can understand the codebase and maintain it effectively.

---

## Phase 1: Foundation & Data Models
**Goal**: Set up SwiftData models and app structure
**Duration**: 2-3 hours
**Testable Outcome**: App launches with empty screen, data models are ready

### Tasks
1. ✅ Create `Task.swift` model with all properties
2. ✅ Create `TaskCompletion.swift` model
3. ✅ Configure SwiftData container in `dailytodolistApp.swift`
4. ✅ Create basic `TaskListView.swift` (empty state)
5. ✅ Create `HistoryView.swift` (empty state)
6. ✅ Set up tab navigation in `MainTabView.swift`

### Files to Create/Modify
- `/dailytodolist/Models/Task.swift` (new)
- `/dailytodolist/Models/TaskCompletion.swift` (new)
- `/dailytodolist/dailytodolistApp.swift` (modify)
- `/dailytodolist/Views/TaskListView.swift` (new)
- `/dailytodolist/Views/HistoryView.swift` (new)
- `/dailytodolist/Views/MainTabView.swift` (new)

### Testing in Simulator
1. Run the app
2. Verify app launches without crashes
3. Verify two tabs appear: "Today" and "History"
4. Verify both tabs show empty states
5. Check console for SwiftData initialization success

### Documentation Requirements
- **Task.swift**: Document each property and the `isCompletedToday()` method
- **TaskCompletion.swift**: Explain the relationship to Task
- **dailytodolistApp.swift**: Comment the ModelContainer setup
- All view files: Add header comments explaining the view's purpose

---

## Phase 2: Add Tasks & Display Today's List
**Goal**: Create tasks and display them in today's list
**Duration**: 3-4 hours
**Testable Outcome**: Can add tasks (both regular and recurring) and see them in today's list

### Tasks
1. ✅ Create `TaskService.swift` with basic CRUD operations
2. ✅ Create `AddTaskSheet.swift` with form (title, category, recurring toggle)
3. ✅ Update `TaskListView.swift` to display tasks
4. ✅ Create `TaskRow.swift` component
5. ✅ Implement "Add Task" button and sheet presentation
6. ✅ Implement basic delete functionality (swipe to delete)

### Files to Create/Modify
- `/dailytodolist/Services/TaskService.swift` (new)
- `/dailytodolist/Views/AddTaskSheet.swift` (new)
- `/dailytodolist/Views/TaskRow.swift` (new)
- `/dailytodolist/Views/TaskListView.swift` (modify)

### Testing in Simulator
1. Launch app and tap "+" button
2. Add a regular task (e.g., "Buy groceries")
3. Add a recurring task (e.g., "Meditation") - toggle "Recurring Daily"
4. Verify both tasks appear in today's list
5. Verify task details show correctly (title, category)
6. Verify recurring badge appears on recurring tasks
7. Swipe to delete a task and verify it's removed
8. Close and reopen app - verify tasks persist

### Documentation Requirements
- **TaskService.swift**:
  - Document `createTask()` - explain parameters and what it does
  - Document `fetchActiveTasks()` - explain filtering logic
  - Document `fetchTodayTasks()` - explain difference between recurring and non-recurring filtering
- **AddTaskSheet.swift**:
  - Document form validation logic
  - Explain recurring toggle behavior
- **TaskRow.swift**:
  - Document how task data is displayed
  - Explain recurring badge logic

---

## Phase 3: Task Completion & Recurring Logic
**Goal**: Complete tasks and verify recurring tasks reappear next day
**Duration**: 3-4 hours
**Testable Outcome**: Can check/uncheck tasks, recurring tasks work correctly

### Tasks
1. ✅ Implement completion toggle in `TaskService.swift`
2. ✅ Update `TaskRow.swift` to show checkbox and handle taps
3. ✅ Implement completion state updates (visual feedback)
4. ✅ Test recurring task behavior:
   - Complete today → disappears from today's list
   - Change device date to tomorrow → verify it reappears
5. ✅ Test non-recurring task behavior:
   - Complete → disappears and doesn't return

### Files to Modify
- `/dailytodolist/Services/TaskService.swift` (modify)
- `/dailytodolist/Views/TaskRow.swift` (modify)
- `/dailytodolist/Views/TaskListView.swift` (modify)

### Testing in Simulator
1. Launch app with tasks from Phase 2
2. Tap checkbox on "Meditation" (recurring)
   - Verify it disappears from today's list immediately
3. Tap checkbox on "Buy groceries" (regular)
   - Verify it disappears from today's list
4. **Test recurring behavior**:
   - Go to Settings > General > Date & Time
   - Disable "Set Automatically"
   - Change date to tomorrow
   - Return to app (may need to force quit and reopen)
   - Verify "Meditation" reappears unchecked
   - Verify "Buy groceries" does NOT reappear
5. Change date back to today
6. Test unchecking (tap completed task in same day before it disappears)

### Documentation Requirements
- **TaskService.swift**:
  - Document `toggleTaskCompletion()` - explain the logic for checking if already completed today
  - Document `completeTask()` - explain TaskCompletion creation
  - Document `uncompleteTask()` - explain deletion of completion record
  - Add detailed comments explaining the recurring vs non-recurring filtering logic
- **TaskRow.swift**:
  - Document `toggleCompletion()` method
  - Document `updateCompletionStatus()` method
  - Explain why isCompleted is @State and how it syncs with Task model

---

## Phase 4: History View Implementation
**Goal**: Display completed tasks in history grouped by date
**Duration**: 2-3 hours
**Testable Outcome**: Completed tasks appear in history, grouped by date

### Tasks
1. ✅ Implement history fetching in `TaskService.swift`
2. ✅ Update `HistoryView.swift` to display grouped completions
3. ✅ Create `HistoryRow.swift` component
4. ✅ Add date grouping and sorting logic
5. ✅ Style history to differentiate from today's list

### Files to Create/Modify
- `/dailytodolist/Services/TaskService.swift` (modify)
- `/dailytodolist/Views/HistoryView.swift` (modify)
- `/dailytodolist/Views/HistoryRow.swift` (new)

### Testing in Simulator
1. Complete several tasks on "today"
2. Switch to "History" tab
3. Verify completed tasks appear under today's date
4. Verify tasks show completion time
5. Verify recurring tasks show recurring badge
6. **Test multi-day history**:
   - Change device date to tomorrow
   - Complete "Meditation" again
   - Check history shows "Meditation" under both dates
7. Verify history is sorted by date (newest first)
8. Verify empty state shows when no history exists

### Documentation Requirements
- **TaskService.swift**:
  - Document `fetchHistory(for:)` - explain date range filtering
  - Document `fetchHistoryGroupedByDate()` - explain grouping logic and Dictionary creation
  - Add comments about date comparison using Calendar.startOfDay
- **HistoryView.swift**:
  - Document data loading and grouping logic
  - Explain sorted dates array creation
- **HistoryRow.swift**:
  - Document how completion data is displayed
  - Explain relationship between TaskCompletion and Task

---

## Phase 5: Drag-and-Drop Reordering & Polish
**Goal**: Allow task reordering and add final polish
**Duration**: 2-3 hours
**Testable Outcome**: Fully functional app with all features

### Tasks
1. ✅ Implement reordering in `TaskService.swift`
2. ✅ Add `.onMove()` modifier to task list
3. ✅ Add EditButton to enable/disable reordering mode
4. ✅ Add animations and haptic feedback
5. ✅ Add pull-to-refresh on both screens
6. ✅ Polish UI (colors, spacing, fonts)
7. ✅ Add empty state messages
8. ✅ Test all edge cases

### Files to Modify
- `/dailytodolist/Services/TaskService.swift` (modify)
- `/dailytodolist/Views/TaskListView.swift` (modify)
- `/dailytodolist/Views/TaskRow.swift` (modify - animations)

### Testing in Simulator
1. Launch app with multiple tasks
2. Tap "Edit" button in navigation bar
3. Verify drag handles appear on task rows
4. Drag a task to reorder it
5. Verify new order persists after closing edit mode
6. Verify new order persists after closing and reopening app
7. **Test mixed task types**:
   - Reorder with both recurring and non-recurring tasks
   - Complete a task in middle of list
   - Verify remaining tasks maintain order
8. Test pull-to-refresh on both tabs
9. Test all animations are smooth
10. Verify haptic feedback on task completion (if implemented)

### Documentation Requirements
- **TaskService.swift**:
  - Document `reorderTasks()` - explain how sortOrder is updated
  - Add comments about transaction safety and bulk updates
- **TaskListView.swift**:
  - Document reordering implementation
  - Explain EditButton integration
  - Document refresh logic
- Add final overview comments at top of each major file explaining how it fits in the architecture

---

## Testing Checklist (After Phase 5)

### Core Functionality
- [ ] Can add regular tasks
- [ ] Can add recurring tasks
- [ ] Regular tasks disappear after completion and don't return
- [ ] Recurring tasks disappear after completion but return next day
- [ ] Can delete tasks
- [ ] Can reorder tasks
- [ ] Task order persists

### History
- [ ] Completed tasks appear in history
- [ ] History grouped by date correctly
- [ ] Recurring tasks can appear on multiple dates
- [ ] Non-recurring tasks appear only once

### Data Persistence
- [ ] Tasks persist after app restart
- [ ] Completions persist after app restart
- [ ] Task order persists after app restart

### Edge Cases
- [ ] Empty state shows correctly when no tasks
- [ ] Empty state shows correctly when no history
- [ ] App handles midnight date transitions (test by changing device date)
- [ ] Can't add task with empty title
- [ ] Deleting a task removes it from history (if not completed)
- [ ] Deleting a completed task keeps history intact

### UI/UX
- [ ] All text is readable
- [ ] Buttons are tappable (44x44 minimum)
- [ ] Category badges show correctly
- [ ] Recurring badge shows on recurring tasks
- [ ] Animations are smooth
- [ ] Pull-to-refresh works

---

## Code Documentation Standards

After each phase, ensure all new code includes:

### 1. File Header Comments
```swift
//
//  FileName.swift
//  dailytodolist
//
//  Purpose: Brief description of what this file does
//  Key responsibilities: List 2-3 main responsibilities
//

```

### 2. Function Documentation
```swift
/// Brief description of what this function does
///
/// Longer explanation if needed, including:
/// - How it works
/// - Why certain decisions were made
/// - Any important edge cases
///
/// - Parameters:
///   - param1: Description
///   - param2: Description
/// - Returns: Description of return value
/// - Throws: What errors can be thrown and why
func exampleFunction(param1: String, param2: Int) throws -> Bool {
    // Implementation
}
```

### 3. Complex Logic Comments
```swift
// MARK: - Task Filtering Logic
// Recurring tasks: Show if NOT completed today (will reappear tomorrow)
// Non-recurring tasks: Show if NEVER completed (one-time tasks)
let filteredTasks = tasks.filter { task in
    // Inline comments for tricky parts
}
```

### 4. Property Documentation
```swift
/// The user-visible title of the task
/// Limited to 100 characters in the UI
var title: String

/// Flag indicating if this task repeats daily
/// When true, task reappears every day even after completion
var isRecurring: Bool
```

---

## Architecture Overview (Reference for All Phases)

### Data Flow
```
User Action (View)
    ↓
TaskService (Business Logic)
    ↓
SwiftData ModelContext (Persistence)
    ↓
@Query / ObservableObject (Reactive Updates)
    ↓
View Updates Automatically
```

### Key Architectural Decisions

1. **Dual-Model Approach**
   - `Task`: Template for the task (persists forever)
   - `TaskCompletion`: Record of each completion (one per day)
   - Why: Enables recurring tasks to track completion history

2. **TaskService Layer**
   - Why: Separates business logic from views
   - Benefit: Easier to test and maintain

3. **SwiftData with @Query**
   - Why: Automatic UI updates when data changes
   - Benefit: Less boilerplate than manual observation

4. **Date Handling with Calendar**
   - Always use `Calendar.current.startOfDay(for:)` for date comparisons
   - Why: Handles timezones and DST correctly

---

## Estimated Total Time

- **Phase 1**: 2-3 hours
- **Phase 2**: 3-4 hours
- **Phase 3**: 3-4 hours
- **Phase 4**: 2-3 hours
- **Phase 5**: 2-3 hours

**Total**: 12-17 hours of focused development

---

## Tips for Success

1. **Test frequently**: After each small change, run in simulator
2. **Commit after each phase**: Use git to save progress
3. **Don't skip documentation**: Write comments as you code, not after
4. **Use previews**: SwiftUI previews speed up development significantly
5. **Handle errors gracefully**: Add try-catch blocks and user-friendly error messages
6. **Read the plan**: Before starting each phase, re-read what needs to be done

---

## Next Steps

1. Start with Phase 1
2. After completing each phase:
   - Test in simulator
   - Document all new functions
   - Commit changes to git
   - Take a short break
3. Move to next phase

Good luck! 🚀
